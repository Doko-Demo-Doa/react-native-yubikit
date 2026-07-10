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

        YKFManagementApplicationType apps[] = {
          YKFManagementApplicationTypeOTP,
          YKFManagementApplicationTypeU2F,
          YKFManagementApplicationTypeOPGP,
          YKFManagementApplicationTypePIV,
          YKFManagementApplicationTypeOATH,
          YKFManagementApplicationTypeCTAP2
        };

        if (usbCaps.has_value()) {
          NSUInteger usbValue = (NSUInteger)usbCaps.value();
          for (NSUInteger i = 0; i < sizeof(apps) / sizeof(apps[0]); i++) {
            BOOL enabled = (usbValue & apps[i]) != 0;
            [interfaceConfig setEnabled:enabled application:apps[i] overTransport:YKFManagementTransportTypeUSB];
          }
        }

        if (nfcCaps.has_value()) {
          NSUInteger nfcValue = (NSUInteger)nfcCaps.value();
          for (NSUInteger i = 0; i < sizeof(apps) / sizeof(apps[0]); i++) {
            BOOL enabled = (nfcValue & apps[i]) != 0;
            [interfaceConfig setEnabled:enabled application:apps[i] overTransport:YKFManagementTransportTypeNFC];
          }
        }
      }

      [session writeConfiguration:interfaceConfig reboot:reboot completion:^(NSError *_Nullable error) {
        if (error) {
          reject(@"MANAGEMENT_ERROR", error.localizedDescription, error);
          return;
        }
        resolve(nil);
      }];
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
