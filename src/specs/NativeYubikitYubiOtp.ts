import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface Version {
  major: number;
  minor: number;
  micro: number;
}

interface ConfigurationState {
  slot1Configured: boolean;
  slot2Configured: boolean;
  slot1TouchTriggered: boolean;
  slot2TouchTriggered: boolean;
  ledInverted: boolean;
}

interface OtpSlotConfiguration {
  type:
    | 'YubiOtp'
    | 'HOTP'
    | 'HmacSha1'
    | 'StaticPassword'
    | 'StaticTicket'
    | 'Update';
  fixed?: string;
  uid?: string;
  key?: string;
  secret?: string;
  scanCodes?: string;
  digits?: number;
  imf?: number;
  requireTouch?: boolean;
  lt64?: boolean;
  appendCr?: boolean;
  serialApiVisible?: boolean;
  serialUsbVisible?: boolean;
  allowUpdate?: boolean;
  dormant?: boolean;
  invertLed?: boolean;
}

export interface Spec extends TurboModule {
  getConfigurationState(deviceHandle: string): Promise<ConfigurationState>;
  getVersion(deviceHandle: string): Promise<Version>;
  getSerialNumber(deviceHandle: string): Promise<number>;

  swapConfigurations(deviceHandle: string): Promise<void>;

  deleteConfiguration(
    deviceHandle: string,
    slot: 'ONE' | 'TWO',
    currentAccessCode?: string
  ): Promise<void>;
  putConfiguration(
    deviceHandle: string,
    slot: 'ONE' | 'TWO',
    configuration: OtpSlotConfiguration,
    accessCode?: string,
    currentAccessCode?: string
  ): Promise<void>;
  updateConfiguration(
    deviceHandle: string,
    slot: 'ONE' | 'TWO',
    configuration: OtpSlotConfiguration,
    accessCode?: string,
    currentAccessCode?: string
  ): Promise<void>;
  setNdefConfiguration(
    deviceHandle: string,
    slot: 'ONE' | 'TWO',
    uri?: string,
    currentAccessCode?: string
  ): Promise<void>;

  calculateHmacSha1(
    deviceHandle: string,
    slot: 'ONE' | 'TWO',
    challenge: string
  ): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitYubiOtp');
