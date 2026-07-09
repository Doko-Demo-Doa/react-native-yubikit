import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  reset(deviceHandle: string): Promise<void>;
  getSerialNumber(deviceHandle: string): Promise<number>;

  authenticate(deviceHandle: string, managementKey: string): Promise<void>;
  setManagementKey(
    deviceHandle: string,
    keyType: string,
    managementKey: string,
    requireTouch: boolean
  ): Promise<void>;

  verifyPin(deviceHandle: string, pin: string): Promise<void>;
  getPinAttempts(deviceHandle: string): Promise<number>;
  changePin(
    deviceHandle: string,
    oldPin: string,
    newPin: string
  ): Promise<void>;
  changePuk(
    deviceHandle: string,
    oldPuk: string,
    newPuk: string
  ): Promise<void>;
  unblockPin(deviceHandle: string, puk: string, newPin: string): Promise<void>;
  setPinAttempts(
    deviceHandle: string,
    pinAttempts: number,
    pukAttempts: number
  ): Promise<void>;

  getPinMetadata(deviceHandle: string): Promise<Object>;
  getPukMetadata(deviceHandle: string): Promise<Object>;
  getManagementKeyMetadata(deviceHandle: string): Promise<Object>;
  getSlotMetadata(deviceHandle: string, slot: string): Promise<Object>;

  getCertificate(deviceHandle: string, slot: string): Promise<string>;
  putCertificate(
    deviceHandle: string,
    slot: string,
    certificate: string,
    compress?: boolean
  ): Promise<void>;
  deleteCertificate(deviceHandle: string, slot: string): Promise<void>;
  attestKey(deviceHandle: string, slot: string): Promise<string>;

  generateKey(
    deviceHandle: string,
    slot: string,
    keyType: string,
    pinPolicy: string,
    touchPolicy: string
  ): Promise<string>;

  deleteKey(deviceHandle: string, slot: string): Promise<void>;

  rawSignOrDecrypt(
    deviceHandle: string,
    slot: string,
    keyType: string,
    payload: string
  ): Promise<string>;

  getBioMetadata(deviceHandle: string): Promise<Object>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitPiv');
