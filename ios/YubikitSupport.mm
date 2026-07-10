#import "YubikitSupport.h"
#import "YubikitDeviceInfoHelper.h"

@implementation YubikitSupport

RCT_EXPORT_MODULE(YubikitSupport)

- (void)readInfo:(NSString *)deviceHandle
             pid:(NSNumber *)pid
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject {
  id<YKFConnectionProtocol> connection = [[YubikitManager shared] connectionForHandle:deviceHandle];
  if (connection == nil) {
    reject(@"CONNECTION_ERROR", @"No device found for handle", nil);
    return;
  }

  [connection managementSession:^(YKFManagementSession *_Nullable session, NSError *_Nullable error) {
    if (error || session == nil) {
      reject(@"SUPPORT_ERROR", error ? error.localizedDescription : @"Management session not available", error);
      return;
    }

    [session getDeviceInfoWithCompletion:^(YKFManagementDeviceInfo *_Nullable deviceInfo, NSError *_Nullable error) {
      if (error || deviceInfo == nil) {
        reject(@"SUPPORT_ERROR", error ? error.localizedDescription : @"Failed to read device info", error);
        return;
      }

      resolve([YubikitDeviceInfoHelper dictionaryFromDeviceInfo:deviceInfo]);
    }];
  }];
}

- (NSString *)getName:(JS::NativeYubikitSupport::DeviceInfo &)info
              keyType:(NSString *)keyType {
  NSString *formFactor = info.formFactor();
  if ([formFactor isEqualToString:@"USB_A_KEYCHAIN"]) return @"YubiKey 5 NFC";
  if ([formFactor isEqualToString:@"USB_A_NANO"]) return @"YubiKey 5 Nano";
  if ([formFactor isEqualToString:@"USB_C_KEYCHAIN"]) return @"YubiKey 5C NFC";
  if ([formFactor isEqualToString:@"USB_C_NANO"]) return @"YubiKey 5C Nano";
  if ([formFactor isEqualToString:@"USB_C_LIGHTNING"]) return @"YubiKey 5Ci";
  if ([formFactor isEqualToString:@"USB_A_BIO"]) return @"YubiKey Bio";
  if ([formFactor isEqualToString:@"USB_C_BIO"]) return @"YubiKey C Bio";
  return @"YubiKey";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeYubikitSupportSpecJSI>(params);
}

@end
