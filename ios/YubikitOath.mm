#import "YubikitOath.h"

@implementation YubikitOath

RCT_EXPORT_MODULE(YubikitOath)

- (void)getDeviceId:(NSString *)deviceHandle
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)isAccessKeySet:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)isLocked:(NSString *)deviceHandle
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)unlockWithPassword:(NSString *)deviceHandle
                  password:(NSString *)password
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)unlockWithAccessKey:(NSString *)deviceHandle
                  accessKey:(NSString *)accessKey
                    resolve:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)setPassword:(NSString *)deviceHandle
           password:(NSString *)password
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)setAccessKey:(NSString *)deviceHandle
           accessKey:(NSString *)accessKey
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteAccessKey:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)getCredentials:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)calculateCodes:(NSString *)deviceHandle
             timestamp:(NSNumber *)timestamp
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)calculateResponse:(NSString *)deviceHandle
             credentialId:(NSString *)credentialId
                challenge:(NSString *)challenge
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)calculateCode:(NSString *)deviceHandle
         credentialId:(NSString *)credentialId
            timestamp:(NSNumber *)timestamp
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)putCredential:(NSString *)deviceHandle
       credentialData:(JS::NativeYubikitOath::CredentialData &)credentialData
         requireTouch:(BOOL)requireTouch
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteCredential:(NSString *)deviceHandle
          credentialId:(NSString *)credentialId
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (void)renameCredential:(NSString *)deviceHandle
           credentialId:(NSString *)credentialId
         newAccountName:(NSString *)newAccountName
              newIssuer:(NSString *)newIssuer
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"OATH_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitOathSpecJSI>(params);
}

@end
