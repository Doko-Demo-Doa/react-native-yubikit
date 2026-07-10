#import "YubikitOpenPgp.h"

@implementation YubikitOpenPgp

RCT_EXPORT_MODULE(YubikitOpenPgp)

- (void)getVersion:(NSString *)deviceHandle
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getApplicationRelatedData:(NSString *)deviceHandle
                          resolve:(RCTPromiseResolveBlock)resolve
                           reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)verifyUserPin:(NSString *)deviceHandle
                  pin:(NSString *)pin
             extended:(NSNumber *)extended
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)verifyAdminPin:(NSString *)deviceHandle
                   pin:(NSString *)pin
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)unverifyUserPin:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)unverifyAdminPin:(NSString *)deviceHandle
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getSignatureCounter:(NSString *)deviceHandle
                    resolve:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getChallenge:(NSString *)deviceHandle
              length:(double)length
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)setPinAttempts:(NSString *)deviceHandle
          userAttempts:(double)userAttempts
         resetAttempts:(double)resetAttempts
         adminAttempts:(double)adminAttempts
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)changeUserPin:(NSString *)deviceHandle
                  pin:(NSString *)pin
               newPin:(NSString *)newPin
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)changeAdminPin:(NSString *)deviceHandle
                   pin:(NSString *)pin
                newPin:(NSString *)newPin
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)setSignaturePinPolicy:(NSString *)deviceHandle
                       policy:(NSString *)policy
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getUif:(NSString *)deviceHandle
        keyRef:(NSString *)keyRef
       resolve:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)setUif:(NSString *)deviceHandle
        keyRef:(NSString *)keyRef
           uif:(NSString *)uif
       resolve:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getAlgorithmInformation:(NSString *)deviceHandle
                        resolve:(RCTPromiseResolveBlock)resolve
                         reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)setAlgorithmAttributes:(NSString *)deviceHandle
                        keyRef:(NSString *)keyRef
                    attributes:(JS::NativeYubikitOpenPgp::OpenPgpAlgorithmAttributes &)attributes
                       resolve:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getCertificate:(NSString *)deviceHandle
                keyRef:(NSString *)keyRef
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)putCertificate:(NSString *)deviceHandle
                keyRef:(NSString *)keyRef
           certificate:(NSString *)certificate
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteCertificate:(NSString *)deviceHandle
                   keyRef:(NSString *)keyRef
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)generateRsaKey:(NSString *)deviceHandle
                keyRef:(NSString *)keyRef
               keySize:(double)keySize
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)generateEcKey:(NSString *)deviceHandle
               keyRef:(NSString *)keyRef
                curve:(NSString *)curve
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)getPublicKey:(NSString *)deviceHandle
              keyRef:(NSString *)keyRef
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteKey:(NSString *)deviceHandle
           keyRef:(NSString *)keyRef
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)sign:(NSString *)deviceHandle
     payload:(NSString *)payload
     resolve:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)decrypt:(NSString *)deviceHandle
        payload:(NSString *)payload
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)authenticate:(NSString *)deviceHandle
             payload:(NSString *)payload
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (void)attestKey:(NSString *)deviceHandle
            keyRef:(NSString *)keyRef
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  reject(@"OPENPGP_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitOpenPgpSpecJSI>(params);
}

@end
