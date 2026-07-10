#import "YubikitPiv.h"
#import "YubikitManager.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitPiv

RCT_EXPORT_MODULE(YubikitPiv)

#pragma mark - Helpers

- (id<YKFConnectionProtocol>)connectionForHandle:(NSString *)deviceHandle
                                           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
  }
  return connection;
}

- (YKFPIVSlot)slotFromString:(NSString *)slot {
  if ([slot isEqualToString:@"SIGNATURE"]) return YKFPIVSlotSignature;
  if ([slot isEqualToString:@"KEY_MANAGEMENT"]) return YKFPIVSlotKeyManagement;
  if ([slot isEqualToString:@"CARD_AUTH"]) return YKFPIVSlotCardAuth;
  if ([slot isEqualToString:@"ATTESTATION"]) return YKFPIVSlotAttestation;
  if ([slot hasPrefix:@"RETIRED"]) {
    NSInteger index = [[slot substringFromIndex:7] integerValue];
    if (index >= 1 && index <= 20) {
      return (YKFPIVSlot)(0x82 + (index - 1));
    }
  }
  return YKFPIVSlotAuthentication;
}

- (YKFPIVKeyType)keyTypeFromString:(NSString *)keyType {
  if ([keyType isEqualToString:@"RSA1024"]) return YKFPIVKeyTypeRSA1024;
  if ([keyType isEqualToString:@"RSA2048"]) return YKFPIVKeyTypeRSA2048;
  if ([keyType isEqualToString:@"RSA3072"]) return YKFPIVKeyTypeRSA3072;
  if ([keyType isEqualToString:@"RSA4096"]) return YKFPIVKeyTypeRSA4096;
  if ([keyType isEqualToString:@"ECCP256"]) return YKFPIVKeyTypeECCP256;
  if ([keyType isEqualToString:@"ECCP384"]) return YKFPIVKeyTypeECCP384;
  return YKFPIVKeyTypeUnknown;
}

- (NSString *)stringFromKeyType:(YKFPIVKeyType)keyType {
  switch (keyType) {
    case YKFPIVKeyTypeRSA1024: return @"RSA1024";
    case YKFPIVKeyTypeRSA2048: return @"RSA2048";
    case YKFPIVKeyTypeRSA3072: return @"RSA3072";
    case YKFPIVKeyTypeRSA4096: return @"RSA4096";
    case YKFPIVKeyTypeECCP256: return @"ECCP256";
    case YKFPIVKeyTypeECCP384: return @"ECCP384";
    default: return @"";
  }
}

- (YKFPIVPinPolicy)pinPolicyFromString:(NSString *)policy {
  if ([policy isEqualToString:@"NEVER"]) return YKFPIVPinPolicyNever;
  if ([policy isEqualToString:@"ONCE"]) return YKFPIVPinPolicyOnce;
  if ([policy isEqualToString:@"ALWAYS"]) return YKFPIVPinPolicyAlways;
  if ([policy isEqualToString:@"MATCH_ONCE"]) return YKFPIVPinPolicyMatchOnce;
  if ([policy isEqualToString:@"MATCH_ALWAYS"]) return YKFPIVPinPolicyMatchAlways;
  return YKFPIVPinPolicyDefault;
}

- (NSString *)stringFromPinPolicy:(YKFPIVPinPolicy)policy {
  switch (policy) {
    case YKFPIVPinPolicyNever: return @"NEVER";
    case YKFPIVPinPolicyOnce: return @"ONCE";
    case YKFPIVPinPolicyAlways: return @"ALWAYS";
    case YKFPIVPinPolicyMatchOnce: return @"MATCH_ONCE";
    case YKFPIVPinPolicyMatchAlways: return @"MATCH_ALWAYS";
    default: return @"DEFAULT";
  }
}

- (YKFPIVTouchPolicy)touchPolicyFromString:(NSString *)policy {
  if ([policy isEqualToString:@"NEVER"]) return YKFPIVTouchPolicyNever;
  if ([policy isEqualToString:@"ALWAYS"]) return YKFPIVTouchPolicyAlways;
  if ([policy isEqualToString:@"CACHED"]) return YKFPIVTouchPolicyCached;
  return YKFPIVTouchPolicyDefault;
}

- (NSString *)stringFromTouchPolicy:(YKFPIVTouchPolicy)policy {
  switch (policy) {
    case YKFPIVTouchPolicyNever: return @"NEVER";
    case YKFPIVTouchPolicyAlways: return @"ALWAYS";
    case YKFPIVTouchPolicyCached: return @"CACHED";
    default: return @"DEFAULT";
  }
}

- (YKFPIVManagementKeyType *)managementKeyTypeFromString:(NSString *)keyType {
  if ([keyType isEqualToString:@"AES128"]) return [YKFPIVManagementKeyType AES128];
  if ([keyType isEqualToString:@"AES192"]) return [YKFPIVManagementKeyType AES192];
  if ([keyType isEqualToString:@"AES256"]) return [YKFPIVManagementKeyType AES256];
  return [YKFPIVManagementKeyType TripleDES];
}

// The "authenticate" method doesn't receive an explicit key type from JS, so the
// management key type is inferred from its length. 24-byte keys default to TDES
// since that's the YubiKey factory-default management key type.
- (YKFPIVManagementKeyType *)managementKeyTypeFromKeyData:(NSData *)keyData {
  switch (keyData.length) {
    case 16: return [YKFPIVManagementKeyType AES128];
    case 32: return [YKFPIVManagementKeyType AES256];
    default: return [YKFPIVManagementKeyType TripleDES];
  }
}

- (NSString *)stringFromManagementKeyType:(YKFPIVManagementKeyType *)keyType {
  if ([keyType.name isEqualToString:YKFPIVManagementKeyTypeAES]) {
    switch (keyType.keyLenght) {
      case 16: return @"AES128";
      case 24: return @"AES192";
      case 32: return @"AES256";
      default: return @"TDES";
    }
  }
  return @"TDES";
}

- (NSString *)base64FromSecCertificate:(SecCertificateRef)certificate {
  if (certificate == NULL) return nil;
  NSData *data = (__bridge_transfer NSData *)SecCertificateCopyData(certificate);
  return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64FromSecKey:(SecKeyRef)key {
  if (key == NULL) return nil;
  CFErrorRef error = NULL;
  NSData *data = (__bridge_transfer NSData *)SecKeyCopyExternalRepresentation(key, &error);
  if (error || data == nil) return nil;
  return [data base64EncodedStringWithOptions:0];
}

// The SDK's rawSignOrDecrypt is exposed as two distinct methods (sign / decrypt),
// while the JS API takes no explicit intent. Decryption is only meaningful for RSA
// keys in the KEY_MANAGEMENT slot on this SDK (EC keys use ECDH instead), so that
// combination is treated as decrypt; everything else is treated as sign. (The two
// paths are mathematically equivalent raw RSA operations when using the "Raw"
// algorithm variants below, so this choice mainly preserves intent for callers.)
- (BOOL)isDecryptOperationForSlot:(YKFPIVSlot)pivSlot keyType:(YKFPIVKeyType)pivKeyType {
  BOOL isRsa = pivKeyType == YKFPIVKeyTypeRSA1024 || pivKeyType == YKFPIVKeyTypeRSA2048;
  return isRsa && pivSlot == YKFPIVSlotKeyManagement;
}

// "Raw"/plain-digest algorithm variants make YKFPIVPadding treat the payload as an
// already-formed, pass-through block (no extra hashing or padding added), matching
// the Android SDK's rawSignOrDecrypt, which sends the payload to the card unmodified
// (aside from the length normalization in normalizedPayload:forKeyType:error: below).
// Note: YKFPIVPadding only recognizes the SHA-suffixed "Digest" EC constants (they're
// all treated identically, as pure pass-through) — the unsuffixed
// kSecKeyAlgorithmECDSASignatureDigestX962 is NOT one of them and would silently
// zero-pad the payload instead of forwarding it, so it must not be used here.
- (SecKeyAlgorithm)signAlgorithmForKeyType:(YKFPIVKeyType)pivKeyType {
  switch (pivKeyType) {
    case YKFPIVKeyTypeECCP256:
      return kSecKeyAlgorithmECDSASignatureDigestX962SHA256;
    case YKFPIVKeyTypeECCP384:
      return kSecKeyAlgorithmECDSASignatureDigestX962SHA384;
    default:
      return kSecKeyAlgorithmRSASignatureRaw;
  }
}

// Mirrors PivSession.rawSignOrDecrypt on Android: left-pad short payloads with
// leading zero bytes, truncate long EC payloads, and reject long RSA payloads,
// before handing off to the card's raw private-key operation.
- (nullable NSData *)normalizedPayload:(NSData *)payload
                             forKeyType:(YKFPIVKeyType)pivKeyType
                                  error:(NSError **)error {
  NSInteger byteLength = YKFPIVSizeFromKeyType(pivKeyType);
  if (byteLength <= 0 || payload.length == (NSUInteger)byteLength) {
    return payload;
  }

  BOOL isEC = pivKeyType == YKFPIVKeyTypeECCP256 || pivKeyType == YKFPIVKeyTypeECCP384;

  if (payload.length > (NSUInteger)byteLength) {
    if (isEC) {
      return [payload subdataWithRange:NSMakeRange(0, (NSUInteger)byteLength)];
    }
    if (error) {
      *error = [NSError errorWithDomain:@"YubikitPiv" code:0
                                userInfo:@{NSLocalizedDescriptionKey: @"Payload too large for key"}];
    }
    return nil;
  }

  NSMutableData *padded = [NSMutableData dataWithLength:(NSUInteger)byteLength];
  [payload getBytes:(uint8_t *)padded.mutableBytes + (byteLength - payload.length) length:payload.length];
  return padded;
}

#pragma mark - Methods

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session resetWithCompletion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)getSerialNumber:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getSerialNumberWithCompletion:^(int serialNumber, NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@(serialNumber));
    }];
  }];
}

- (void)authenticate:(NSString *)deviceHandle
       managementKey:(NSString *)managementKey
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *keyData = [[NSData alloc] initWithBase64EncodedString:managementKey options:0];
  if (keyData == nil) {
    reject(@"PIV_ERROR", @"Invalid base64 management key", nil);
    return;
  }

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session authenticateWithManagementKey:keyData
                                       type:[self managementKeyTypeFromKeyData:keyData]
                                 completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)setManagementKey:(NSString *)deviceHandle
                 keyType:(NSString *)keyType
           managementKey:(NSString *)managementKey
            requireTouch:(BOOL)requireTouch
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *keyData = [[NSData alloc] initWithBase64EncodedString:managementKey options:0];
  if (keyData == nil) {
    reject(@"PIV_ERROR", @"Invalid base64 management key", nil);
    return;
  }

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session setManagementKey:keyData
                          type:[self managementKeyTypeFromString:keyType]
                 requiresTouch:requireTouch
                    completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)verifyPin:(NSString *)deviceHandle
              pin:(NSString *)pin
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session verifyPin:pin completion:^(int retries, NSError *_Nullable error) {
      if (error) {
        NSString *message = retries > 0
          ? [NSString stringWithFormat:@"%@ (%d attempt(s) remaining)", error.localizedDescription, retries]
          : error.localizedDescription;
        reject(@"PIV_ERROR", message, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)getPinAttempts:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getPinAttemptsWithCompletion:^(int retriesRemaining, NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@(retriesRemaining));
    }];
  }];
}

- (void)changePin:(NSString *)deviceHandle
           oldPin:(NSString *)oldPin
           newPin:(NSString *)newPin
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session setPin:newPin oldPin:oldPin completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)changePuk:(NSString *)deviceHandle
           oldPuk:(NSString *)oldPuk
           newPuk:(NSString *)newPuk
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session setPuk:newPuk oldPuk:oldPuk completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)unblockPin:(NSString *)deviceHandle
               puk:(NSString *)puk
            newPin:(NSString *)newPin
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session unblockPinWithPuk:puk newPin:newPin completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)setPinAttempts:(NSString *)deviceHandle
           pinAttempts:(double)pinAttempts
           pukAttempts:(double)pukAttempts
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session setPinAttempts:(int)pinAttempts
                 pukAttempts:(int)pukAttempts
                  completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)getPinMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getPinMetadataWithCompletion:^(bool isDefault, int retriesTotal, int retriesRemaining, NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@{@"attemptsRemaining": @(retriesRemaining)});
    }];
  }];
}

- (void)getPukMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getPukMetadataWithCompletion:^(bool isDefault, int retriesTotal, int retriesRemaining, NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@{@"attemptsRemaining": @(retriesRemaining)});
    }];
  }];
}

- (void)getManagementKeyMetadata:(NSString *)deviceHandle
                         resolve:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getManagementKeyMetadataWithCompletion:^(YKFPIVManagementKeyMetadata *_Nullable metaData, NSError *_Nullable error) {
      if (error || metaData == nil) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"Management key metadata not available", error);
        return;
      }
      BOOL touchRequired = metaData.touchPolicy == YKFPIVTouchPolicyAlways || metaData.touchPolicy == YKFPIVTouchPolicyCached;
      resolve(@{
        @"keyType": [self stringFromManagementKeyType:metaData.keyType],
        @"defaultValue": @(metaData.isDefault),
        @"touchRequired": @(touchRequired)
      });
    }];
  }];
}

- (void)getSlotMetadata:(NSString *)deviceHandle
                   slot:(NSString *)slot
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getMetadataForSlot:[self slotFromString:slot]
                      completion:^(YKFPIVSlotMetadata *_Nullable metaData, NSError *_Nullable error) {
      if (error || metaData == nil) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"Slot metadata not available", error);
        return;
      }
      NSMutableDictionary *result = [NSMutableDictionary dictionary];
      result[@"keyType"] = [self stringFromKeyType:metaData.keyType];
      result[@"pinPolicy"] = [self stringFromPinPolicy:metaData.pinPolicy];
      result[@"touchPolicy"] = [self stringFromTouchPolicy:metaData.touchPolicy];
      result[@"generated"] = @(metaData.generated);
      NSString *publicKey = [self base64FromSecKey:metaData.publicKey];
      if (publicKey != nil) {
        result[@"publicKey"] = publicKey;
      }
      resolve(result);
    }];
  }];
}

- (void)getCertificate:(NSString *)deviceHandle
                   slot:(NSString *)slot
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getCertificateInSlot:[self slotFromString:slot]
                        completion:^(SecCertificateRef _Nullable certificate, NSError *_Nullable error) {
      if (error || certificate == NULL) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"No certificate in slot", error);
        return;
      }
      resolve([self base64FromSecCertificate:certificate]);
    }];
  }];
}

- (void)putCertificate:(NSString *)deviceHandle
                   slot:(NSString *)slot
            certificate:(NSString *)certificate
               compress:(NSNumber *)compress
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *certData = [[NSData alloc] initWithBase64EncodedString:certificate options:0];
  if (certData == nil) {
    reject(@"PIV_ERROR", @"Invalid base64 certificate", nil);
    return;
  }

  SecCertificateRef certRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
  if (certRef == NULL) {
    reject(@"PIV_ERROR", @"Invalid certificate data", nil);
    return;
  }

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      CFRelease(certRef);
      return;
    }
    [session putCertificate:certRef
                      inSlot:[self slotFromString:slot]
                    compress:compress != nil && compress.boolValue
                  completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
    CFRelease(certRef);
  }];
}

- (void)deleteCertificate:(NSString *)deviceHandle
                      slot:(NSString *)slot
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session deleteCertificateInSlot:[self slotFromString:slot] completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)attestKey:(NSString *)deviceHandle
             slot:(NSString *)slot
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session attestKeyInSlot:[self slotFromString:slot]
                    completion:^(SecCertificateRef _Nullable certificate, NSError *_Nullable error) {
      if (error || certificate == NULL) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"Attestation failed", error);
        return;
      }
      resolve([self base64FromSecCertificate:certificate]);
    }];
  }];
}

- (void)generateKey:(NSString *)deviceHandle
               slot:(NSString *)slot
            keyType:(NSString *)keyType
          pinPolicy:(NSString *)pinPolicy
        touchPolicy:(NSString *)touchPolicy
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session generateKeyInSlot:[self slotFromString:slot]
                            type:[self keyTypeFromString:keyType]
                       pinPolicy:[self pinPolicyFromString:pinPolicy]
                     touchPolicy:[self touchPolicyFromString:touchPolicy]
                      completion:^(SecKeyRef _Nullable key, NSError *_Nullable error) {
      if (error || key == NULL) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"Key generation failed", error);
        return;
      }
      resolve([self base64FromSecKey:key]);
    }];
  }];
}

- (void)deleteKey:(NSString *)deviceHandle
             slot:(NSString *)slot
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session deleteKeyInSlot:[self slotFromString:slot] completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"PIV_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)rawSignOrDecrypt:(NSString *)deviceHandle
                    slot:(NSString *)slot
                 keyType:(NSString *)keyType
                 payload:(NSString *)payload
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0];
  if (payloadData == nil) {
    reject(@"PIV_ERROR", @"Invalid base64 payload", nil);
    return;
  }

  YKFPIVSlot pivSlot = [self slotFromString:slot];
  YKFPIVKeyType pivKeyType = [self keyTypeFromString:keyType];

  // YKFPIVPadding (used internally by signWithKeyInSlot:/decryptWithKeyInSlot:) only
  // handles RSA1024/RSA2048 — RSA3072/RSA4096 keys can be generated on iOS but can't
  // be used for raw sign/decrypt via this SDK version, so fail fast with a clear
  // message instead of a cryptic Security-framework error.
  if (pivKeyType == YKFPIVKeyTypeRSA3072 || pivKeyType == YKFPIVKeyTypeRSA4096) {
    reject(@"PIV_ERROR", @"rawSignOrDecrypt for RSA3072/RSA4096 is not supported by the YubiKit iOS SDK", nil);
    return;
  }

  NSError *normalizeError = nil;
  NSData *normalizedPayload = [self normalizedPayload:payloadData forKeyType:pivKeyType error:&normalizeError];
  if (normalizedPayload == nil) {
    reject(@"PIV_ERROR", normalizeError ? normalizeError.localizedDescription : @"Invalid payload for key type", normalizeError);
    return;
  }

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }

    if ([self isDecryptOperationForSlot:pivSlot keyType:pivKeyType]) {
      [session decryptWithKeyInSlot:pivSlot
                            algorithm:kSecKeyAlgorithmRSAEncryptionRaw
                            encrypted:normalizedPayload
                           completion:^(NSData *_Nullable decrypted, NSError *_Nullable error) {
        if (error || decrypted == nil) {
          reject(@"PIV_ERROR", error ? error.localizedDescription : @"Decryption failed", error);
          return;
        }
        resolve([decrypted base64EncodedStringWithOptions:0]);
      }];
    } else {
      [session signWithKeyInSlot:pivSlot
                              type:pivKeyType
                         algorithm:[self signAlgorithmForKeyType:pivKeyType]
                           message:normalizedPayload
                        completion:^(NSData *_Nullable signature, NSError *_Nullable error) {
        if (error || signature == nil) {
          reject(@"PIV_ERROR", error ? error.localizedDescription : @"Signing failed", error);
          return;
        }
        resolve([signature base64EncodedStringWithOptions:0]);
      }];
    }
  }];
}

- (void)getBioMetadata:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection pivSession:^(YKFPIVSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"PIV_ERROR", error ? error.localizedDescription : @"PIV session not available", error);
      return;
    }
    [session getBioMetadataWithCompletion:^(YKFPIVBioMetadata *_Nullable metaData, NSError *_Nullable error) {
      if (error || metaData == nil) {
        reject(@"PIV_ERROR", error ? error.localizedDescription : @"Bio metadata not available", error);
        return;
      }
      resolve(@{
        @"attemptsRemaining": @(metaData.attemptsRemaining),
        @"temporaryPin": @(metaData.temporaryPin)
      });
    }];
  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitPivSpecJSI>(params);
}

@end
