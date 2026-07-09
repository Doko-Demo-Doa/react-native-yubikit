import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  /** Read DeviceInfo from any supported connection. */
  readInfo(deviceHandle: string, pid?: number): Promise<Object>;

  /** Get a human-readable name for a YubiKey. */
  getName(info: Object, keyType?: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitSupport');
