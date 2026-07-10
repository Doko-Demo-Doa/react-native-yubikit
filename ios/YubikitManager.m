#import "YubikitManager.h"

@interface YubikitManager ()
@property(nonatomic, strong) NSMutableDictionary<NSString *, id<YKFConnectionProtocol>> *connections;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *deviceTransports;
@property(nonatomic, assign) BOOL usbActive;
@property(nonatomic, assign) BOOL nfcActive;
@end

@implementation YubikitManager

+ (instancetype)shared {
  static YubikitManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[self alloc] init];
  });
  return shared;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _connections = [NSMutableDictionary dictionary];
    _deviceTransports = [NSMutableDictionary dictionary];
    _usbActive = NO;
    _nfcActive = NO;
  }
  return self;
}

- (void)startUsbDiscovery {
  if (self.usbActive) return;
  self.usbActive = YES;
  [YubiKitManager shared].delegate = self;
  [[YubiKitManager shared] startAccessoryConnection];
  if (@available(iOS 16.0, *)) {
    [[YubiKitManager shared] startSmartCardConnection];
  }
}

- (void)stopUsbDiscovery {
  if (!self.usbActive) return;
  self.usbActive = NO;
  [[YubiKitManager shared] stopAccessoryConnection];
  if (@available(iOS 16.0, *)) {
    [[YubiKitManager shared] stopSmartCardConnection];
  }
}

- (void)startNfcDiscovery {
  if (self.nfcActive) return;
  self.nfcActive = YES;
  [YubiKitManager shared].delegate = self;
  [[YubiKitManager shared] startNFCConnection];
}

- (void)stopNfcDiscovery {
  if (!self.nfcActive) return;
  self.nfcActive = NO;
  [[YubiKitManager shared] stopNFCConnection];
}

- (nullable id<YKFConnectionProtocol>)connectionForHandle:(NSString *)handle {
  return self.connections[handle];
}

- (void)removeConnectionForHandle:(NSString *)handle {
  [self.connections removeObjectForKey:handle];
}

- (NSArray<NSDictionary *> *)listDevices {
  NSMutableArray<NSDictionary *> *result = [NSMutableArray array];
  [self.connections enumerateKeysAndObjectsUsingBlock:^(NSString *handle, id<YKFConnectionProtocol> connection, BOOL *stop) {
    NSString *transport = self.deviceTransports[handle] ?: @"usb";
    NSMutableArray<NSString *> *supportedConnections = [NSMutableArray array];
    if ([connection isKindOfClass:[YKFSmartCardConnection class]] || [connection conformsToProtocol:@protocol(YKFConnectionProtocol)]) {
      [supportedConnections addObject:@"SmartCardConnection"];
    }
    [result addObject:@{
      @"handle": handle,
      @"transport": transport,
      @"supportedConnections": supportedConnections
    }];
  }];
  return result;
}

#pragma mark - YKFManagerDelegate

- (void)didConnectNFC:(YKFNFCConnection *)connection {
  NSString *handle = [[NSUUID UUID] UUIDString];
  self.connections[handle] = connection;
  self.deviceTransports[handle] = @"nfc";
}

- (void)didDisconnectNFC:(YKFNFCConnection *)connection error:(NSError *)error {
  [self removeConnectionForConnection:connection];
}

- (void)didConnectAccessory:(YKFAccessoryConnection *)connection {
  NSString *handle = [[NSUUID UUID] UUIDString];
  self.connections[handle] = connection;
  self.deviceTransports[handle] = @"usb";
}

- (void)didDisconnectAccessory:(YKFAccessoryConnection *)connection error:(NSError *)error {
  [self removeConnectionForConnection:connection];
}

- (void)didConnectSmartCard:(YKFSmartCardConnection *)connection API_AVAILABLE(ios(16.0)) {
  NSString *handle = [[NSUUID UUID] UUIDString];
  self.connections[handle] = connection;
  self.deviceTransports[handle] = @"usb";
}

- (void)didDisconnectSmartCard:(YKFSmartCardConnection *)connection error:(NSError *)error API_AVAILABLE(ios(16.0)) {
  [self removeConnectionForConnection:connection];
}

- (void)didFailConnectingSmartCard:(NSError *)error {
}

- (void)didFailConnectingNFC:(NSError *)error {
}

#pragma mark - Private

- (void)removeConnectionForConnection:(id<YKFConnectionProtocol>)connection {
  NSArray<NSString *> *keys = [self.connections allKeysForObject:connection];
  for (NSString *key in keys) {
    [self.connections removeObjectForKey:key];
    [self.deviceTransports removeObjectForKey:key];
  }
}

@end
