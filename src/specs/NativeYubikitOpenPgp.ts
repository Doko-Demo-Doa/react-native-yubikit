import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  getVersion(deviceHandle: string): Promise<Object>;
  getApplicationRelatedData(deviceHandle: string): Promise<Object>;

  verifyUserPin(
    deviceHandle: string,
    pin: string,
    extended?: boolean
  ): Promise<void>;
  verifyAdminPin(deviceHandle: string, pin: string): Promise<void>;
  unverifyUserPin(deviceHandle: string): Promise<void>;
  unverifyAdminPin(deviceHandle: string): Promise<void>;

  getSignatureCounter(deviceHandle: string): Promise<number>;
  getChallenge(deviceHandle: string, length: number): Promise<string>;

  reset(deviceHandle: string): Promise<void>;
  setPinAttempts(
    deviceHandle: string,
    userAttempts: number,
    resetAttempts: number,
    adminAttempts: number
  ): Promise<void>;
  changeUserPin(
    deviceHandle: string,
    pin: string,
    newPin: string
  ): Promise<void>;
  changeAdminPin(
    deviceHandle: string,
    pin: string,
    newPin: string
  ): Promise<void>;

  setSignaturePinPolicy(deviceHandle: string, policy: string): Promise<void>;

  getUif(deviceHandle: string, keyRef: string): Promise<string>;
  setUif(deviceHandle: string, keyRef: string, uif: string): Promise<void>;

  getAlgorithmInformation(deviceHandle: string): Promise<Object[]>;
  setAlgorithmAttributes(
    deviceHandle: string,
    keyRef: string,
    attributes: Object
  ): Promise<void>;

  getCertificate(deviceHandle: string, keyRef: string): Promise<string>;
  putCertificate(
    deviceHandle: string,
    keyRef: string,
    certificate: string
  ): Promise<void>;
  deleteCertificate(deviceHandle: string, keyRef: string): Promise<void>;

  generateRsaKey(
    deviceHandle: string,
    keyRef: string,
    keySize: number
  ): Promise<string>;
  generateEcKey(
    deviceHandle: string,
    keyRef: string,
    curve: string
  ): Promise<string>;
  getPublicKey(deviceHandle: string, keyRef: string): Promise<string>;
  deleteKey(deviceHandle: string, keyRef: string): Promise<void>;

  sign(deviceHandle: string, payload: string): Promise<string>;
  decrypt(deviceHandle: string, payload: string): Promise<string>;
  authenticate(deviceHandle: string, payload: string): Promise<string>;
  attestKey(deviceHandle: string, keyRef: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitOpenPgp');
