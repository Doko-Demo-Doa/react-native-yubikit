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
  reject(@"APDU_ERROR", @"sendApdu is not yet implemented on iOS", nil);
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
