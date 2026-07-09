import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  getConfigurationState(deviceHandle: string): Promise<Object>;
  getVersion(deviceHandle: string): Promise<Object>;
  getSerialNumber(deviceHandle: string): Promise<number>;

  swapConfigurations(deviceHandle: string): Promise<void>;

  deleteConfiguration(
    deviceHandle: string,
    slot: string,
    currentAccessCode?: string
  ): Promise<void>;

  putConfiguration(
    deviceHandle: string,
    slot: string,
    configuration: Object,
    accessCode?: string,
    currentAccessCode?: string
  ): Promise<void>;

  updateConfiguration(
    deviceHandle: string,
    slot: string,
    configuration: Object,
    accessCode?: string,
    currentAccessCode?: string
  ): Promise<void>;

  setNdefConfiguration(
    deviceHandle: string,
    slot: string,
    uri?: string,
    currentAccessCode?: string
  ): Promise<void>;

  calculateHmacSha1(
    deviceHandle: string,
    slot: string,
    challenge: string
  ): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitYubiOtp');
