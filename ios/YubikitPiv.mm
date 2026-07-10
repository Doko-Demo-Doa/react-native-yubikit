#import "YubikitPiv.h"

@implementation YubikitPiv

RCT_EXPORT_MODULE(YubikitPiv)

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getSerialNumber:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)authenticate:(NSString *)deviceHandle
       managementKey:(NSString *)managementKey
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)setManagementKey:(NSString *)deviceHandle
                 keyType:(NSString *)keyType
           managementKey:(NSString *)managementKey
            requireTouch:(BOOL)requireTouch
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)verifyPin:(NSString *)deviceHandle
              pin:(NSString *)pin
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getPinAttempts:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)changePin:(NSString *)deviceHandle
           oldPin:(NSString *)oldPin
           newPin:(NSString *)newPin
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)changePuk:(NSString *)deviceHandle
           oldPuk:(NSString *)oldPuk
           newPuk:(NSString *)newPuk
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)unblockPin:(NSString *)deviceHandle
               puk:(NSString *)puk
            newPin:(NSString *)newPin
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)setPinAttempts:(NSString *)deviceHandle
           pinAttempts:(double)pinAttempts
           pukAttempts:(double)pukAttempts
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getPinMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getPukMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getManagementKeyMetadata:(NSString *)deviceHandle
                         resolve:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getSlotMetadata:(NSString *)deviceHandle
                   slot:(NSString *)slot
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getCertificate:(NSString *)deviceHandle
                  slot:(NSString *)slot
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)putCertificate:(NSString *)deviceHandle
                  slot:(NSString *)slot
           certificate:(NSString *)certificate
              compress:(NSNumber *)compress
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteCertificate:(NSString *)deviceHandle
                     slot:(NSString *)slot
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)attestKey:(NSString *)deviceHandle
             slot:(NSString *)slot
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)generateKey:(NSString *)deviceHandle
               slot:(NSString *)slot
            keyType:(NSString *)keyType
          pinPolicy:(NSString *)pinPolicy
        touchPolicy:(NSString *)touchPolicy
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteKey:(NSString *)deviceHandle
             slot:(NSString *)slot
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)rawSignOrDecrypt:(NSString *)deviceHandle
                    slot:(NSString *)slot
                 keyType:(NSString *)keyType
                 payload:(NSString *)payload
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (void)getBioMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"PIV_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitPivSpecJSI>(params);
}

@end
