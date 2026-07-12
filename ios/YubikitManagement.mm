#import "YubikitManagement.h"
#import "YubikitManager.h"
#import "YubikitDeviceInfoHelper.h"

@implementation YubikitManagement

RCT_EXPORT_MODULE(YubikitManagement)

- (void)getDeviceInfo:(NSString *)deviceHandle
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }

  [connection managementSession:^(YKFManagementSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"MANAGEMENT_ERROR", error ? error.localizedDescription : @"Management session not available", error);
      return;
    }

    [session getDeviceInfoWithCompletion:^(YKFManagementDeviceInfo *_Nullable deviceInfo, NSError *_Nullable error) {
      if (error || deviceInfo == nil) {
        reject(@"MANAGEMENT_ERROR", error ? error.localizedDescription : @"Failed to read device info", error);
        return;
      }
      resolve([YubikitDeviceInfoHelper dictionaryFromDeviceInfo:deviceInfo]);
    }];
  }];
}

- (void)updateDeviceConfig:(NSString *)deviceHandle
                    config:(JS::NativeYubikitManagement::DeviceConfig &)config
                    reboot:(BOOL)reboot
           currentLockCode:(NSString *)currentLockCode
               newLockCode:(NSString *)newLockCode
                   resolve:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }

  [connection managementSession:^(YKFManagementSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"MANAGEMENT_ERROR", error ? error.localizedDescription : @"Management session not available", error);
      return;
    }

    [session getDeviceInfoWithCompletion:^(YKFManagementDeviceInfo *_Nullable deviceInfo, NSError *_Nullable error) {
      if (error || deviceInfo == nil || deviceInfo.configuration == nil) {
        reject(@"MANAGEMENT_ERROR", error ? error.localizedDescription : @"Device configuration not available", error);
        return;
      }

      YKFManagementInterfaceConfiguration *interfaceConfig = deviceInfo.configuration;
      std::optional<JS::NativeYubikitManagement::DeviceConfigEnabledCapabilities> enabledCaps = config.enabledCapabilities();
      if (enabledCaps.has_value()) {
        std::optional<double> usbCaps = enabledCaps.value().usb();
        std::optional<double> nfcCaps = enabledCaps.value().nfc();
        // Assign the raw bitmask directly - iterating a hardcoded application list (as
        // done previously) drops any bit not enumerated there (e.g. HSMAUTH), silently
        // failing to apply part of what the caller asked for.
        if (usbCaps.has_value()) {
          interfaceConfig.usbEnabledMask = (NSUInteger)usbCaps.value();
        }
        if (nfcCaps.has_value()) {
          interfaceConfig.nfcEnabledMask = (NSUInteger)nfcCaps.value();
        }
      }

      std::optional<double> autoEjectTimeout = config.autoEjectTimeout();
      if (autoEjectTimeout.has_value()) {
        interfaceConfig.autoEjectTimeout = autoEjectTimeout.value();
      }
      std::optional<double> challengeResponseTimeout = config.challengeResponseTimeout();
      if (challengeResponseTimeout.has_value()) {
        interfaceConfig.challengeResponseTimeout = challengeResponseTimeout.value();
      }
      std::optional<bool> nfcRestricted = config.nfcRestricted();
      if (nfcRestricted.has_value()) {
        interfaceConfig.isNFCRestricted = nfcRestricted.value();
      }

      NSData *currentLockCodeData = currentLockCode != nil
        ? [[NSData alloc] initWithBase64EncodedString:currentLockCode options:0]
        : nil;
      NSData *newLockCodeData = newLockCode != nil
        ? [[NSData alloc] initWithBase64EncodedString:newLockCode options:0]
        : nil;

      YKFManagementSessionWriteCompletionBlock completion = ^(NSError *_Nullable error) {
        if (error) {
          reject(@"MANAGEMENT_ERROR", error.localizedDescription, error);
          return;
        }
        resolve(nil);
      };

      if (currentLockCodeData != nil || newLockCodeData != nil) {
        [session writeConfiguration:interfaceConfig reboot:reboot lockCode:currentLockCodeData newLockCode:newLockCodeData completion:completion];
      } else {
        [session writeConfiguration:interfaceConfig reboot:reboot completion:completion];
      }
    }];
  }];
}

// The iOS SDK has no dedicated "mode" setter; the same per-transport interface
// enable/disable behavior is available through updateDeviceConfig instead.
- (void)setMode:(NSString *)deviceHandle
           mode:(NSString *)mode
chalrespTimeout:(double)chalrespTimeout
autoejectTimeout:(double)autoejectTimeout
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject {
  reject(@"MANAGEMENT_ERROR", @"Not implemented on iOS; use updateDeviceConfig instead", nil);
}

// Only supported by YubiKey Bio - Multi-protocol Edition devices on firmware 5.6+;
// the SDK surfaces an error for any other device rather than a universal factory reset.
- (void)deviceReset:(NSString *)deviceHandle
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }

  [connection managementSession:^(YKFManagementSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"MANAGEMENT_ERROR", error ? error.localizedDescription : @"Management session not available", error);
      return;
    }
    [session deviceReset:^(NSError *_Nullable error) {
      if (error) {
        reject(@"MANAGEMENT_ERROR", error.localizedDescription, error);
        return;
      }
      resolve(nil);
    }];
  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitManagementSpecJSI>(params);
}

@end
