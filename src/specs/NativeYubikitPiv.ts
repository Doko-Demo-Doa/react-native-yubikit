import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface PivPinMetadata {
  attemptsRemaining: number;
}

interface PivManagementKeyMetadata {
  keyType: 'TDES' | 'AES128' | 'AES192' | 'AES256';
  defaultValue: boolean;
  touchRequired: boolean;
}

interface PivSlotMetadata {
  keyType:
    | 'RSA1024'
    | 'RSA2048'
    | 'RSA3072'
    | 'RSA4096'
    | 'ECCP256'
    | 'ECCP384'
    | 'ED25519'
    | 'X25519';
  pinPolicy:
    'DEFAULT' | 'NEVER' | 'ONCE' | 'ALWAYS' | 'MATCH_ONCE' | 'MATCH_ALWAYS';
  touchPolicy: 'DEFAULT' | 'NEVER' | 'ALWAYS' | 'CACHED';
  generated: boolean;
  publicKey?: string;
}

interface PivBioMetadata {
  attemptsRemaining?: number;
  temporaryPin?: boolean;
}

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

  getPinMetadata(deviceHandle: string): Promise<PivPinMetadata>;
  getPukMetadata(deviceHandle: string): Promise<PivPinMetadata>;
  getManagementKeyMetadata(
    deviceHandle: string
  ): Promise<PivManagementKeyMetadata>;
  getSlotMetadata(deviceHandle: string, slot: string): Promise<PivSlotMetadata>;

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

  getBioMetadata(deviceHandle: string): Promise<PivBioMetadata>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitPiv');
