#import "YubikitManagement.h"

@implementation YubikitManagement

RCT_EXPORT_MODULE(YubikitManagement)

- (void)getDeviceInfo:(NSString *)deviceHandle
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"MANAGEMENT_ERROR", @"Not implemented on iOS", nil);
}

- (void)updateDeviceConfig:(NSString *)deviceHandle
                    config:(JS::NativeYubikitManagement::DeviceConfig &)config
                    reboot:(BOOL)reboot
           currentLockCode:(NSString *)currentLockCode
               newLockCode:(NSString *)newLockCode
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  reject(@"MANAGEMENT_ERROR", @"Not implemented on iOS", nil);
}

- (void)setMode:(NSString *)deviceHandle
           mode:(NSString *)mode
chalrespTimeout:(double)chalrespTimeout
autoejectTimeout:(double)autoejectTimeout
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  reject(@"MANAGEMENT_ERROR", @"Not implemented on iOS", nil);
}

- (void)deviceReset:(NSString *)deviceHandle
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  reject(@"MANAGEMENT_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitManagementSpecJSI>(params);
}

@end
