#import "YubikitFido.h"

@implementation YubikitFido

RCT_EXPORT_MODULE(YubikitFido)

- (void)getInfo:(NSString *)deviceHandle
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)makeCredential:(NSString *)deviceHandle
               options:(JS::NativeYubikitFido::PublicKeyCredentialCreationOptions &)options
       effectiveDomain:(NSString *)effectiveDomain
                   pin:(NSString *)pin
 enterpriseAttestation:(NSNumber *)enterpriseAttestation
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)getAssertion:(NSString *)deviceHandle
             options:(JS::NativeYubikitFido::PublicKeyCredentialRequestOptions &)options
     effectiveDomain:(NSString *)effectiveDomain
                 pin:(NSString *)pin
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)getCredentialCount:(NSString *)deviceHandle
                       pin:(NSString *)pin
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)getRpIdList:(NSString *)deviceHandle
                pin:(NSString *)pin
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)getCredentials:(NSString *)deviceHandle
                  rpId:(NSString *)rpId
                   pin:(NSString *)pin
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)deleteCredential:(NSString *)deviceHandle
              credential:(JS::NativeYubikitFido::FidoCredentialDescriptor &)credential
                     pin:(NSString *)pin
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (void)updateUserInformation:(NSString *)deviceHandle
                   credential:(JS::NativeYubikitFido::FidoCredentialDescriptor &)credential
                         user:(JS::NativeYubikitFido::FidoCredentialUserEntity &)user
                          pin:(NSString *)pin
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
  reject(@"FIDO_ERROR", @"Not implemented on iOS", nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitFidoSpecJSI>(params);
}

@end
