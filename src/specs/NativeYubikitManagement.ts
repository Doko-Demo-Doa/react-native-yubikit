import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  /** Read metadata from a YubiKey. */
  getDeviceInfo(deviceHandle: string): Promise<Object>;

  /** Update device configuration. */
  updateDeviceConfig(
    deviceHandle: string,
    config: Object,
    reboot: boolean,
    currentLockCode?: string,
    newLockCode?: string
  ): Promise<void>;

  /** Set the USB interface mode. */
  setMode(
    deviceHandle: string,
    mode: string,
    chalrespTimeout: number,
    autoejectTimeout: number
  ): Promise<void>;

  /** Reset the device to factory defaults. */
  deviceReset(deviceHandle: string): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitManagement');
