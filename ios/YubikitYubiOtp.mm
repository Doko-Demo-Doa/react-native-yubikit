#import "YubikitYubiOtp.h"

@implementation YubikitYubiOtp

RCT_EXPORT_MODULE(YubikitYubiOtp)

- (void)getConfigurationState:(NSString *)deviceHandle
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getVersion:(NSString *)deviceHandle
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getSerialNumber:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)swapConfigurations:(NSString *)deviceHandle
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteConfiguration:(NSString *)deviceHandle
                       slot:(NSString *)slot
          currentAccessCode:(NSString *)currentAccessCode
                    resolve:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)putConfiguration:(NSString *)deviceHandle
                    slot:(NSString *)slot
           configuration:(JS::NativeYubikitYubiOtp::OtpSlotConfiguration &)configuration
              accessCode:(NSString *)accessCode
       currentAccessCode:(NSString *)currentAccessCode
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)updateConfiguration:(NSString *)deviceHandle
                       slot:(NSString *)slot
              configuration:(JS::NativeYubikitYubiOtp::OtpSlotConfiguration &)configuration
                 accessCode:(NSString *)accessCode
          currentAccessCode:(NSString *)currentAccessCode
                    resolve:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)setNdefConfiguration:(NSString *)deviceHandle
                        slot:(NSString *)slot
                         uri:(NSString *)uri
           currentAccessCode:(NSString *)currentAccessCode
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (void)calculateHmacSha1:(NSString *)deviceHandle
                     slot:(NSString *)slot
                challenge:(NSString *)challenge
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  reject(@"YUBIOTP_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitYubiOtpSpecJSI>(params);
}

@end
