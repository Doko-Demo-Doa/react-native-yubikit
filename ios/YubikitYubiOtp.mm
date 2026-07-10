#import "YubikitYubiOtp.h"
#import "YubikitManager.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitYubiOtp

#pragma mark - Helpers

- (id<YKFConnectionProtocol>)connectionForHandle:(NSString *)deviceHandle
                                           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
  }
  return connection;
}

- (YKFSlot)slotFromString:(NSString *)slot {
  return [slot isEqualToString:@"TWO"] ? YKFSlotTwo : YKFSlotOne;
}

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
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *challengeData = [[NSData alloc] initWithBase64EncodedString:challenge options:0];
  if (challengeData == nil) {
    reject(@"YUBIOTP_ERROR", @"Invalid base64 challenge", nil);
    return;
  }

  [connection challengeResponseSession:^(YKFChallengeResponseSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"YUBIOTP_ERROR", error ? error.localizedDescription : @"Challenge-response session not available", error);
      return;
    }
    [session sendChallenge:challengeData
                       slot:[self slotFromString:slot]
                 completion:^(NSData *_Nullable response, NSError *_Nullable error) {
      if (error) {
        reject(@"YUBIOTP_ERROR", error.localizedDescription, error);
        return;
      }
      resolve([response base64EncodedStringWithOptions:0]);
    }];
  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitYubiOtpSpecJSI>(params);
}

@end
