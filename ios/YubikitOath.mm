#import "YubikitOath.h"
#import "YubikitManager.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitOath

#pragma mark - Helpers

- (id<YKFConnectionProtocol>)connectionForHandle:(NSString *)deviceHandle
                                           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
  }
  return connection;
}

- (YKFOATHCredentialType)oathTypeFromString:(NSString *)type {
  if ([type isEqualToString:@"HOTP"]) return YKFOATHCredentialTypeHOTP;
  return YKFOATHCredentialTypeTOTP;
}

- (NSString *)stringFromOathType:(YKFOATHCredentialType)type {
  return type == YKFOATHCredentialTypeHOTP ? @"HOTP" : @"TOTP";
}

- (YKFOATHCredentialAlgorithm)algorithmFromString:(NSString *)algorithm {
  if ([algorithm isEqualToString:@"SHA256"]) return YKFOATHCredentialAlgorithmSHA256;
  if ([algorithm isEqualToString:@"SHA512"]) return YKFOATHCredentialAlgorithmSHA512;
  return YKFOATHCredentialAlgorithmSHA1;
}

- (NSString *)credentialIdFromCredential:(YKFOATHCredential *)credential {
  NSDictionary *dict = @{
    @"oathType": [self stringFromOathType:credential.type],
    @"accountName": credential.accountName ?: @"",
    @"issuer": credential.issuer ?: @"",
    @"period": @(credential.period)
  };
  NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  return [data base64EncodedStringWithOptions:0];
}

- (nullable YKFOATHCredential *)findCredentialWithId:(NSString *)credentialId
                                        inCredentialList:(NSArray<YKFOATHCredential *> *)credentials {
  NSData *data = [[NSData alloc] initWithBase64EncodedString:credentialId options:0];
  if (data == nil) return nil;
  NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  if (dict == nil) return nil;

  NSString *type = dict[@"oathType"];
  NSString *accountName = dict[@"accountName"];
  NSString *issuer = dict[@"issuer"];
  NSUInteger period = [dict[@"period"] unsignedIntegerValue];
  YKFOATHCredentialType credentialType = [self oathTypeFromString:type];

  for (YKFOATHCredential *credential in credentials) {
    if (credential.type == credentialType &&
        credential.period == period &&
        [credential.accountName isEqualToString:accountName] &&
        ((credential.issuer == nil && [issuer length] == 0) || [credential.issuer isEqualToString:issuer])) {
      return credential;
    }
  }
  return nil;
}

- (NSDictionary *)dictionaryFromCredential:(YKFOATHCredential *)credential {
  return @{
    @"id": [self credentialIdFromCredential:credential],
    @"oathType": [self stringFromOathType:credential.type],
    @"accountName": credential.accountName ?: @"",
    @"issuer": credential.issuer ?: [NSNull null],
    @"period": @(credential.period),
    @"touchRequired": @(credential.requiresTouch)
  };
}

- (NSDictionary *)dictionaryFromCode:(YKFOATHCode *)code {
  NSTimeInterval validFrom = [code.validity.startDate timeIntervalSince1970] * 1000;
  NSTimeInterval validUntil = [code.validity.endDate timeIntervalSince1970] * 1000;
  return @{
    @"value": code.otp ?: @"",
    @"validFrom": @(validFrom),
    @"validUntil": @(validUntil)
  };
}

RCT_EXPORT_MODULE(YubikitOath)

- (void)getDeviceId:(NSString *)deviceHandle
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    resolve(session.deviceId);
  }];
}

- (void)reset:(NSString *)deviceHandle
      resolve:(RCTPromiseResolveBlock)resolve
       reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session resetWithCompletion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)isAccessKeySet:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    // The iOS SDK does not expose "is a password configured" directly. The only signal
    // available through public API is YKFOATHErrorCodeAuthenticationRequired from a
    // command that needs auth, which proves a password IS set - but a *lack* of that
    // error only proves the session isn't currently locked, not that no password was
    // ever configured (it may have already been unlocked earlier in this connection's
    // lifetime; see unlockWithPassword's docs). So this can under-report true here.
    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error && [error isKindOfClass:[YKFOATHError class]] && error.code == YKFOATHErrorCodeAuthenticationRequired) {
        resolve(@YES);
      } else if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
      } else {
        resolve(@NO);
      }
    }];
  }];
}

- (void)isLocked:(NSString *)deviceHandle
          resolve:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    // Unlike isAccessKeySet, this only cares about the session's *current* auth state,
    // which YKFOATHErrorCodeAuthenticationRequired answers precisely and reliably.
    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error && [error isKindOfClass:[YKFOATHError class]] && error.code == YKFOATHErrorCodeAuthenticationRequired) {
        resolve(@YES);
      } else if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
      } else {
        resolve(@NO);
      }
    }];
  }];
}

- (void)unlockWithPassword:(NSString *)deviceHandle
                  password:(NSString *)password
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session unlockWithPassword:password completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@YES);
    }];
  }];
}

- (void)unlockWithAccessKey:(NSString *)deviceHandle
                  accessKey:(NSString *)accessKey
                    resolve:(RCTPromiseResolveBlock)resolve
                     reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:accessKey options:0];
    if (keyData == nil) {
      reject(@"OATH_ERROR", @"Invalid base64 access key", nil);
      return;
    }
    [session unlockWithAccessKey:keyData completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(@YES);
    }];
  }];
}

- (void)setPassword:(NSString *)deviceHandle
           password:(NSString *)password
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session setPassword:password completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)setAccessKey:(NSString *)deviceHandle
           accessKey:(NSString *)accessKey
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:accessKey options:0];
    if (keyData == nil) {
      reject(@"OATH_ERROR", @"Invalid base64 access key", nil);
      return;
    }
    [session setAccessKey:keyData completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)deleteAccessKey:(NSString *)deviceHandle
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session deleteAccessKeyWithCompletion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (void)getCredentials:(NSString *)deviceHandle
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      NSMutableArray *result = [NSMutableArray arrayWithCapacity:credentials.count];
      for (YKFOATHCredential *credential in credentials) {
        [result addObject:[self dictionaryFromCredential:credential]];
      }
      resolve(@{@"credentials": result});
    }];
  }];
}

- (void)calculateCodes:(NSString *)deviceHandle
             timestamp:(NSNumber *)timestamp
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }

    YKFOATHSessionCalculateAllCompletionBlock completion = ^(NSArray<YKFOATHCredentialWithCode *> *_Nullable credentialsWithCodes, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      NSMutableArray *result = [NSMutableArray arrayWithCapacity:credentialsWithCodes.count];
      for (YKFOATHCredentialWithCode *entry in credentialsWithCodes) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"credential"] = [self dictionaryFromCredential:entry.credential];
        if (entry.code) {
          dict[@"code"] = [self dictionaryFromCode:entry.code];
        }
        [result addObject:dict];
      }
      resolve(@{@"codes": result});
    };

    if (timestamp) {
      [session calculateAllWithTimestamp:[NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000.0] completion:completion];
    } else {
      [session calculateAllWithCompletion:completion];
    }
  }];
}

- (void)calculateResponse:(NSString *)deviceHandle
             credentialId:(NSString *)credentialId
                challenge:(NSString *)challenge
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }

    NSData *credentialIdData = [[NSData alloc] initWithBase64EncodedString:credentialId options:0];
    NSData *challengeData = [[NSData alloc] initWithBase64EncodedString:challenge options:0];
    if (challengeData == nil) {
      reject(@"OATH_ERROR", @"Invalid base64 challenge", nil);
      return;
    }

    [session calculateResponseForCredentialID:credentialIdData ?: [NSData data]
                                    challenge:challengeData
                                   completion:^(NSData *_Nullable response, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      resolve([response base64EncodedStringWithOptions:0]);
    }];
  }];
}

- (void)calculateCode:(NSString *)deviceHandle
         credentialId:(NSString *)credentialId
            timestamp:(NSNumber *)timestamp
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }

    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      YKFOATHCredential *credential = [self findCredentialWithId:credentialId inCredentialList:credentials];
      if (credential == nil) {
        reject(@"OATH_ERROR", @"Credential not found", nil);
        return;
      }

      YKFOATHSessionCalculateCompletionBlock completion = ^(YKFOATHCode *_Nullable code, NSError *_Nullable error) {
        if (error) {
          reject(@"OATH_ERROR", error.localizedDescription, error);
          return;
        }
        resolve([self dictionaryFromCode:code]);
      };

      if (timestamp) {
        [session calculateCredential:credential timestamp:[NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000.0] completion:completion];
      } else {
        [session calculateCredential:credential completion:completion];
      }
    }];
  }];
}

- (void)putCredential:(NSString *)deviceHandle
       credentialData:(JS::NativeYubikitOath::CredentialData &)credentialData
         requireTouch:(BOOL)requireTouch
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  NSData *secret = [[NSData alloc] initWithBase64EncodedString:credentialData.secret() options:0];
  if (secret == nil) {
    reject(@"OATH_ERROR", @"Invalid base64 secret", nil);
    return;
  }

  YKFOATHCredentialTemplate *credentialTemplate = [[YKFOATHCredentialTemplate alloc]
    initWithType:[self oathTypeFromString:credentialData.oathType()]
       algorithm:[self algorithmFromString:credentialData.hashAlgorithm()]
          secret:secret
          issuer:credentialData.issuer()
     accountName:credentialData.accountName()
          digits:(NSUInteger)credentialData.digits()
          period:(NSUInteger)credentialData.period()
         counter:(UInt32)credentialData.counter()];

  if (credentialTemplate == nil) {
    reject(@"OATH_ERROR", @"Invalid credential data", nil);
    return;
  }

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }
    [session putCredentialTemplate:credentialTemplate requiresTouch:requireTouch completion:^(NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }

      // Build a credential-like response from the template data.
      NSDictionary *idDict = @{
        @"oathType": credentialData.oathType(),
        @"accountName": credentialData.accountName(),
        @"issuer": credentialData.issuer() ?: @"",
        @"period": @(credentialData.period())
      };
      NSData *idData = [NSJSONSerialization dataWithJSONObject:idDict options:0 error:nil];
      NSString *credentialId = [idData base64EncodedStringWithOptions:0];

      NSMutableDictionary *result = [NSMutableDictionary dictionary];
      result[@"id"] = credentialId ?: @"";
      result[@"oathType"] = credentialData.oathType();
      result[@"accountName"] = credentialData.accountName();
      result[@"issuer"] = credentialData.issuer() ?: [NSNull null];
      result[@"period"] = @(credentialData.period());
      result[@"touchRequired"] = @(requireTouch);
      resolve(result);
    }];
  }];
}

- (void)deleteCredential:(NSString *)deviceHandle
          credentialId:(NSString *)credentialId
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }

    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      YKFOATHCredential *credential = [self findCredentialWithId:credentialId inCredentialList:credentials];
      if (credential == nil) {
        reject(@"OATH_ERROR", @"Credential not found", nil);
        return;
      }

      [session deleteCredential:credential completion:^(NSError *_Nullable error) {
        if (error) {
          reject(@"OATH_ERROR", error.localizedDescription, error);
          return;
        }
        resolve(nil);
      }];
    }];
  }];
}

- (void)renameCredential:(NSString *)deviceHandle
           credentialId:(NSString *)credentialId
         newAccountName:(NSString *)newAccountName
              newIssuer:(NSString *)newIssuer
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [self connectionForHandle:deviceHandle reject:reject];
  if (!connection) return;

  [connection oathSession:^(YKFOATHSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"OATH_ERROR", error ? error.localizedDescription : @"OATH session not available", error);
      return;
    }

    [session listCredentialsWithCompletion:^(NSArray<YKFOATHCredential *> *_Nullable credentials, NSError *_Nullable error) {
      if (error) {
        reject(@"OATH_ERROR", error.localizedDescription, error);
        return;
      }
      YKFOATHCredential *credential = [self findCredentialWithId:credentialId inCredentialList:credentials];
      if (credential == nil) {
        reject(@"OATH_ERROR", @"Credential not found", nil);
        return;
      }

      [session renameCredential:credential
                      newIssuer:newIssuer
                     newAccount:newAccountName
                     completion:^(NSError *_Nullable error) {
        if (error) {
          reject(@"OATH_ERROR", error.localizedDescription, error);
          return;
        }

        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryFromCredential:credential]];
        result[@"accountName"] = newAccountName;
        result[@"issuer"] = newIssuer ?: [NSNull null];
        resolve(result);
      }];
    }];
  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitOathSpecJSI>(params);
}

@end
