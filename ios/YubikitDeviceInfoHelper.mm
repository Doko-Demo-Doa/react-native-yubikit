#import "YubikitDeviceInfoHelper.h"
#import <YubiKit/YubiKit.h>

@implementation YubikitDeviceInfoHelper

+ (NSDictionary *)dictionaryFromDeviceInfo:(YKFManagementDeviceInfo *)deviceInfo {
  YKFManagementInterfaceConfiguration *config = deviceInfo.configuration;
  NSMutableDictionary *result = [NSMutableDictionary dictionary];

  YKFVersion *version = deviceInfo.version;
  NSString *versionName = [NSString stringWithFormat:@"%d.%d.%d", version.major, version.minor, version.micro];
  result[@"version"] = @{
    @"major": @(version.major),
    @"minor": @(version.minor),
    @"micro": @(version.micro)
  };
  result[@"versionName"] = versionName;

  NSString *formFactor = @"UNKNOWN";
  switch (deviceInfo.formFactor) {
    case YKFFormFactorUSBAKeychain:
      formFactor = @"USB_A_KEYCHAIN";
      break;
    case YKFFormFactorUSBCKeychain:
      formFactor = @"USB_C_KEYCHAIN";
      break;
    case YKFFormFactorUSBCLightning:
      formFactor = @"USB_C_LIGHTNING";
      break;
    default:
      break;
  }
  result[@"formFactor"] = formFactor;

  result[@"serialNumber"] = @(deviceInfo.serialNumber);
  result[@"isLocked"] = @(deviceInfo.isConfigurationLocked);

  if (config) {
    NSUInteger usbEnabled = 0;
    NSUInteger nfcEnabled = 0;
    NSUInteger usbSupported = 0;
    NSUInteger nfcSupported = 0;

    YKFManagementApplicationType apps[] = {
      YKFManagementApplicationTypeOTP,
      YKFManagementApplicationTypeU2F,
      YKFManagementApplicationTypeOPGP,
      YKFManagementApplicationTypePIV,
      YKFManagementApplicationTypeOATH,
      YKFManagementApplicationTypeCTAP2
    };

    for (NSUInteger i = 0; i < sizeof(apps) / sizeof(apps[0]); i++) {
      YKFManagementApplicationType app = apps[i];
      if ([config isEnabled:app overTransport:YKFManagementTransportTypeUSB]) {
        usbEnabled |= app;
      }
      if ([config isSupported:app overTransport:YKFManagementTransportTypeUSB]) {
        usbSupported |= app;
      }
      if ([config isEnabled:app overTransport:YKFManagementTransportTypeNFC]) {
        nfcEnabled |= app;
      }
      if ([config isSupported:app overTransport:YKFManagementTransportTypeNFC]) {
        nfcSupported |= app;
      }
    }

    result[@"config"] = @{
      @"enabledCapabilities": @{
        @"usb": @(usbEnabled),
        @"nfc": @(nfcEnabled)
      }
    };
    result[@"supportedCapabilities"] = @{
      @"usb": @(usbSupported),
      @"nfc": @(nfcSupported)
    };
    result[@"hasTransportUsb"] = @(usbSupported != 0);
    result[@"hasTransportNfc"] = @(nfcSupported != 0);
  } else {
    result[@"supportedCapabilities"] = @{};
    result[@"hasTransportUsb"] = @NO;
    result[@"hasTransportNfc"] = @NO;
  }

  result[@"isFips"] = @NO;
  result[@"isSky"] = @NO;
  result[@"fipsCapable"] = @0;
  result[@"fipsApproved"] = @0;
  result[@"pinComplexity"] = @NO;
  result[@"resetBlocked"] = @0;

  return result;
}

@end
