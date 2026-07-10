#import "YubikitCore.h"
#import "YubikitManager.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitCore

RCT_EXPORT_MODULE(YubikitCore)

- (void)startUsbDiscovery:(JS::NativeYubikitCore::UsbConfiguration &)config {
  [[YubikitManager shared] startUsbDiscovery];
}

- (void)stopUsbDiscovery {
  [[YubikitManager shared] stopUsbDiscovery];
}

- (void)startNfcDiscovery:(JS::NativeYubikitCore::NfcConfiguration &)config {
  [[YubikitManager shared] startNfcDiscovery];
}

- (void)stopNfcDiscovery {
  [[YubikitManager shared] stopNfcDiscovery];
}

- (void)requestConnection:(NSString *)deviceHandle
           connectionType:(NSString *)connectionType
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }
  resolve(deviceHandle);
}

- (void)sendApdu:(NSString *)connectionHandle
             apdu:(NSString *)apdu
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:connectionHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }

  NSData *apduData = [[NSData alloc] initWithBase64EncodedString:apdu options:0];
  if (apduData == nil) {
    reject(@"APDU_ERROR", @"Invalid base64 APDU", nil);
    return;
  }

  YKFAPDU *command = [[YKFAPDU alloc] initWithData:apduData];
  if (command == nil) {
    reject(@"APDU_ERROR", @"Invalid APDU", nil);
    return;
  }

  YKFSmartCardInterface *interface = connection.smartCardInterface;
  if (interface == nil) {
    reject(@"APDU_ERROR", @"Smart card interface not available", nil);
    return;
  }

  [interface executeCommand:command completion:^(NSData * _Nullable response, NSError * _Nullable error) {
    if (error) {
      reject(@"APDU_ERROR", error.localizedDescription, error);
      return;
    }
    resolve([response base64EncodedStringWithOptions:0]);
  }];
}

- (void)closeConnection:(NSString *)connectionHandle {
  [[YubikitManager shared] removeConnectionForHandle:connectionHandle];
}

- (NSArray<NSDictionary *> *)getDiscoveredDevices {
  return [[YubikitManager shared] listDevices];
}

- (void)addListener:(NSString *)eventName {
  // Required for NativeEventEmitter
}

- (void)removeListeners:(double)count {
  // Required for NativeEventEmitter
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitCoreSpecJSI>(params);
}

@end
