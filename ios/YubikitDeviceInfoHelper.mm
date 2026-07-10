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
    case YKFFormFactorUSBANano:
      formFactor = @"USB_A_NANO";
      break;
    case YKFFormFactorUSBCKeychain:
      formFactor = @"USB_C_KEYCHAIN";
      break;
    case YKFFormFactorUSBCNano:
      formFactor = @"USB_C_NANO";
      break;
    case YKFFormFactorUSBCLightning:
      formFactor = @"USB_C_LIGHTNING";
      break;
    case YKFFormFactorUSBABio:
      formFactor = @"USB_A_BIO";
      break;
    case YKFFormFactorUSBCBio:
      formFactor = @"USB_C_BIO";
      break;
    default:
      break;
  }
  result[@"formFactor"] = formFactor;

  result[@"serialNumber"] = @(deviceInfo.serialNumber);
  result[@"isLocked"] = @(deviceInfo.isConfigurationLocked);
  if (deviceInfo.partNumber != nil) {
    result[@"partNumber"] = deviceInfo.partNumber;
  }
  if (deviceInfo.fpsVersion != nil) {
    result[@"fpsVersion"] = @{
      @"major": @(deviceInfo.fpsVersion.major),
      @"minor": @(deviceInfo.fpsVersion.minor),
      @"micro": @(deviceInfo.fpsVersion.micro)
    };
  }
  if (deviceInfo.stmVersion != nil) {
    result[@"stmVersion"] = @{
      @"major": @(deviceInfo.stmVersion.major),
      @"minor": @(deviceInfo.stmVersion.minor),
      @"micro": @(deviceInfo.stmVersion.micro)
    };
  }

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

  result[@"isFips"] = @(deviceInfo.isFips);
  result[@"isSky"] = @(deviceInfo.isSky);
  result[@"fipsCapable"] = @(deviceInfo.isFIPSCapable);
  result[@"fipsApproved"] = @(deviceInfo.isFIPSApproved);
  result[@"pinComplexity"] = @(deviceInfo.pinComplexity);
  result[@"resetBlocked"] = @(deviceInfo.isResetBlocked);

  return result;
}

@end
