#import "YubikitSupport.h"

@implementation YubikitSupport

RCT_EXPORT_MODULE(YubikitSupport)

- (void)readInfo:(NSString *)deviceHandle
             pid:(NSNumber *)pid
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject {
  reject(@"SUPPORT_ERROR", @"readInfo is not yet implemented on iOS", nil);
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
