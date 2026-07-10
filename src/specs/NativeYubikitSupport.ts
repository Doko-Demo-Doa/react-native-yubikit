import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface Version {
  major: number;
  minor: number;
  micro: number;
}

interface DeviceConfig {
  enabledCapabilities?: {
    usb?: number;
    nfc?: number;
  };
  autoEjectTimeout?: number;
  challengeResponseTimeout?: number;
  nfcRestricted?: boolean;
  deviceFlags?: number;
}

interface DeviceInfo {
  config?: DeviceConfig;
  serialNumber?: number;
  version: Version;
  versionName: string;
  formFactor:
    | 'UNKNOWN'
    | 'USB_A_KEYCHAIN'
    | 'USB_A_NANO'
    | 'USB_C_KEYCHAIN'
    | 'USB_C_NANO'
    | 'USB_C_LIGHTNING'
    | 'USB_A_BIO'
    | 'USB_C_BIO';
  supportedCapabilities: {
    usb?: number;
    nfc?: number;
  };
  hasTransportUsb: boolean;
  hasTransportNfc: boolean;
  isLocked: boolean;
  isFips: boolean;
  isSky: boolean;
  partNumber?: string;
  fipsCapable: number;
  fipsApproved: number;
  pinComplexity: boolean;
  resetBlocked: number;
  fpsVersion?: Version;
  stmVersion?: Version;
  versionQualifier?: string;
}

export interface Spec extends TurboModule {
  /** Read DeviceInfo from any supported connection. */
  readInfo(deviceHandle: string, pid?: number): Promise<DeviceInfo>;

  /** Get a human-readable name for a YubiKey. */
  getName(info: DeviceInfo, keyType?: string): string;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitSupport');
