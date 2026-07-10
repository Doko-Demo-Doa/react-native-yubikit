#import "YubikitFido.h"
#import "YubikitManager.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitFido

RCT_EXPORT_MODULE(YubikitFido)

#pragma mark - Helpers

- (id<YKFConnectionProtocol>)connectionForHandle:(NSString *)deviceHandle
                                           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
  }
  return connection;
}

- (nullable NSData *)base64Decode:(nullable NSString *)value {
  if (value == nil) return nil;
  return [[NSData alloc] initWithBase64EncodedString:value options:0];
}

- (YKFFIDO2PublicKeyCredentialDescriptor *)descriptorFromId:(NSString *)identifier
                                                          type:(NSString *)type {
  YKFFIDO2PublicKeyCredentialType *credentialType = [[YKFFIDO2PublicKeyCredentialType alloc] init];
  credentialType.name = type ?: @"public-key";

  YKFFIDO2PublicKeyCredentialDescriptor *descriptor = [[YKFFIDO2PublicKeyCredentialDescriptor alloc] init];
  descriptor.credentialId = [self base64Decode:identifier] ?: [NSData data];
  descriptor.credentialType = credentialType;
  return descriptor;
}

// Requirement levels other than "discouraged" are treated as required, since this
// SDK's options dictionary only accepts a plain boolean, not a three-way preference.
- (BOOL)isRequiredPreference:(nullable NSString *)preference {
  return preference != nil && ![preference isEqualToString:@"discouraged"];
}

#pragma mark - Methods

- (void)getInfo:(NSString *)deviceHandle
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection fido2Session:^(YKFFIDO2Session *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"FIDO_ERROR", error ? error.localizedDescription : @"FIDO2 session not available", error);
      return;
    }
    [session getInfoWithCompletion:^(YKFFIDO2GetInfoResponse *_Nullable response, NSError *_Nullable error) {
      if (error || response == nil) {
        reject(@"FIDO_ERROR", error ? error.localizedDescription : @"Get info failed", error);
        return;
      }

      NSMutableDictionary *result = [NSMutableDictionary dictionary];
      result[@"versions"] = response.versions ?: @[];
      if (response.extensions != nil) {
        result[@"extensions"] = response.extensions;
      }
      if (response.aaguid != nil) {
        result[@"aaguid"] = [response.aaguid base64EncodedStringWithOptions:0];
      }
      if (response.options != nil) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [response.options enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
          if ([value isKindOfClass:[NSNumber class]]) {
            options[key] = value;
          }
        }];
        result[@"options"] = options;
      }
      result[@"maxMsgSize"] = @(response.maxMsgSize);
      if (response.pinProtocols != nil) {
        result[@"pinUvAuthProtocols"] = response.pinProtocols;
      }
      result[@"minPinLength"] = @(response.minPinLength);

      resolve(result);
    }];
  }];
}

- (void)makeCredential:(NSString *)deviceHandle
               options:(JS::NativeYubikitFido::PublicKeyCredentialCreationOptions &)options
       effectiveDomain:(NSString *)effectiveDomain
                   pin:(NSString *)pin
 enterpriseAttestation:(NSNumber *)enterpriseAttestation
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *challengeData = [self base64Decode:options.challenge()];
  if (challengeData == nil) {
    reject(@"FIDO_ERROR", @"Invalid base64 challenge", nil);
    return;
  }

  NSString *origin = [NSString stringWithFormat:@"https://%@", effectiveDomain];
  YKFWebAuthnClientData *clientData = [[YKFWebAuthnClientData alloc] initWithType:YKFWebAuthnClientDataTypeCreate
                                                                          challenge:challengeData
                                                                             origin:origin];
  if (clientData == nil || clientData.clientDataHash == nil || clientData.jsonData == nil) {
    reject(@"FIDO_ERROR", @"Failed to build client data", nil);
    return;
  }

  JS::NativeYubikitFido::PublicKeyCredentialRpEntity rpOptions = options.rp();
  YKFFIDO2PublicKeyCredentialRpEntity *rp = [[YKFFIDO2PublicKeyCredentialRpEntity alloc] init];
  rp.rpId = rpOptions.id_() ?: effectiveDomain;
  rp.rpName = rpOptions.name() ?: rp.rpId;

  JS::NativeYubikitFido::PublicKeyCredentialUserEntity userOptions = options.user();
  YKFFIDO2PublicKeyCredentialUserEntity *user = [[YKFFIDO2PublicKeyCredentialUserEntity alloc] init];
  user.userId = [self base64Decode:userOptions.id_()] ?: [NSData data];
  user.userName = userOptions.name() ?: @"";
  user.userDisplayName = userOptions.displayName() ?: @"";

  NSMutableArray<YKFFIDO2PublicKeyCredentialParam *> *pubKeyCredParams = [NSMutableArray array];
  auto params = options.pubKeyCredParams();
  for (const auto &param : params) {
    YKFFIDO2PublicKeyCredentialParam *credParam = [[YKFFIDO2PublicKeyCredentialParam alloc] init];
    credParam.alg = (NSInteger)param.alg();
    [pubKeyCredParams addObject:credParam];
  }

  NSMutableArray<YKFFIDO2PublicKeyCredentialDescriptor *> *excludeList = nil;
  auto excludeCredentials = options.excludeCredentials();
  if (excludeCredentials.has_value()) {
    excludeList = [NSMutableArray array];
    for (const auto &credential : excludeCredentials.value()) {
      [excludeList addObject:[self descriptorFromId:credential.id_() type:credential.type()]];
    }
  }

  NSMutableDictionary *fidoOptions = [NSMutableDictionary dictionary];
  auto authenticatorSelection = options.authenticatorSelection();
  if (authenticatorSelection.has_value()) {
    NSString *residentKey = authenticatorSelection.value().residentKey();
    if (residentKey != nil) {
      fidoOptions[YKFFIDO2OptionRK] = @([self isRequiredPreference:residentKey]);
    }
    NSString *userVerification = authenticatorSelection.value().userVerification();
    if (userVerification != nil) {
      fidoOptions[YKFFIDO2OptionUV] = @([self isRequiredPreference:userVerification]);
    }
  }

  [connection fido2Session:^(YKFFIDO2Session *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"FIDO_ERROR", error ? error.localizedDescription : @"FIDO2 session not available", error);
      return;
    }

    void (^performMakeCredential)(void) = ^{
      [session makeCredentialWithClientDataHash:clientData.clientDataHash
                                              rp:rp
                                            user:user
                                pubKeyCredParams:pubKeyCredParams
                                     excludeList:excludeList
                                         options:fidoOptions.count > 0 ? fidoOptions : nil
                                      completion:^(YKFFIDO2MakeCredentialResponse *_Nullable response, NSError *_Nullable error) {
        if (error || response == nil) {
          reject(@"FIDO_ERROR", error ? error.localizedDescription : @"Make credential failed", error);
          return;
        }

        NSData *credentialId = response.authenticatorData.credentialId ?: [NSData data];
        NSString *credentialIdBase64 = [credentialId base64EncodedStringWithOptions:0];

        resolve(@{
          @"id": credentialIdBase64,
          @"rawId": credentialIdBase64,
          @"type": @"public-key",
          @"response": @{
            @"clientDataJSON": [clientData.jsonData base64EncodedStringWithOptions:0],
            @"authenticatorData": [response.authData base64EncodedStringWithOptions:0],
            @"attestationObject": [response.webauthnAttestationObject base64EncodedStringWithOptions:0]
          }
        });
      }];
    };

    if (pin != nil && pin.length > 0) {
      [session verifyPin:pin completion:^(NSError *_Nullable error) {
        if (error) {
          reject(@"FIDO_ERROR", error.localizedDescription, error);
          return;
        }
        performMakeCredential();
      }];
    } else {
      performMakeCredential();
    }
  }];
}

- (void)getAssertion:(NSString *)deviceHandle
             options:(JS::NativeYubikitFido::PublicKeyCredentialRequestOptions &)options
     effectiveDomain:(NSString *)effectiveDomain
                 pin:(NSString *)pin
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *challengeData = [self base64Decode:options.challenge()];
  if (challengeData == nil) {
    reject(@"FIDO_ERROR", @"Invalid base64 challenge", nil);
    return;
  }

  NSString *origin = [NSString stringWithFormat:@"https://%@", effectiveDomain];
  YKFWebAuthnClientData *clientData = [[YKFWebAuthnClientData alloc] initWithType:YKFWebAuthnClientDataTypeGet
                                                                          challenge:challengeData
                                                                             origin:origin];
  if (clientData == nil || clientData.clientDataHash == nil || clientData.jsonData == nil) {
    reject(@"FIDO_ERROR", @"Failed to build client data", nil);
    return;
  }

  NSString *rpId = options.rpId() ?: effectiveDomain;

  NSMutableArray<YKFFIDO2PublicKeyCredentialDescriptor *> *allowList = nil;
  auto allowCredentials = options.allowCredentials();
  if (allowCredentials.has_value()) {
    allowList = [NSMutableArray array];
    for (const auto &credential : allowCredentials.value()) {
      [allowList addObject:[self descriptorFromId:credential.id_() type:credential.type()]];
    }
  }

  NSMutableDictionary *fidoOptions = [NSMutableDictionary dictionary];
  NSString *userVerification = options.userVerification();
  if (userVerification != nil) {
    fidoOptions[YKFFIDO2OptionUV] = @([self isRequiredPreference:userVerification]);
  }

  NSArray<YKFFIDO2PublicKeyCredentialDescriptor *> *finalAllowList = allowList;

  [connection fido2Session:^(YKFFIDO2Session *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"FIDO_ERROR", error ? error.localizedDescription : @"FIDO2 session not available", error);
      return;
    }

    void (^performGetAssertion)(void) = ^{
      [session getAssertionWithClientDataHash:clientData.clientDataHash
                                          rpId:rpId
                                     allowList:finalAllowList
                                       options:fidoOptions.count > 0 ? fidoOptions : nil
                                    completion:^(YKFFIDO2GetAssertionResponse *_Nullable response, NSError *_Nullable error) {
        if (error || response == nil) {
          reject(@"FIDO_ERROR", error ? error.localizedDescription : @"Get assertion failed", error);
          return;
        }

        NSData *credentialId = response.credential.credentialId;
        if (credentialId == nil && finalAllowList.count == 1) {
          credentialId = finalAllowList.firstObject.credentialId;
        }
        NSString *credentialIdBase64 = [(credentialId ?: [NSData data]) base64EncodedStringWithOptions:0];

        NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
        responseDict[@"clientDataJSON"] = [clientData.jsonData base64EncodedStringWithOptions:0];
        responseDict[@"authenticatorData"] = [response.authData base64EncodedStringWithOptions:0];
        responseDict[@"signature"] = [response.signature base64EncodedStringWithOptions:0];
        if (response.user != nil && response.user.userId != nil) {
          responseDict[@"userHandle"] = [response.user.userId base64EncodedStringWithOptions:0];
        }

        resolve(@{
          @"id": credentialIdBase64,
          @"rawId": credentialIdBase64,
          @"type": @"public-key",
          @"response": responseDict
        });
      }];
    };

    if (pin != nil && pin.length > 0) {
      [session verifyPin:pin completion:^(NSError *_Nullable error) {
        if (error) {
          reject(@"FIDO_ERROR", error.localizedDescription, error);
          return;
        }
        performGetAssertion();
      }];
    } else {
      performGetAssertion();
    }
  }];
}

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection fido2Session:^(YKFFIDO2Session *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"FIDO_ERROR", error ? error.localizedDescription : @"FIDO2 session not available", error);
      return;
    }
    [session resetWithCompletion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"FIDO_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
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
