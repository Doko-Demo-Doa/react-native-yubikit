import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface Version {
  major: number;
  minor: number;
  micro: number;
}

interface OpenPgpAlgorithmAttributes {
  keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT';
  algorithm: string;
  curve?:
    | 'SECP256R1'
    | 'SECP256K1'
    | 'SECP384R1'
    | 'SECP521R1'
    | 'BrainpoolP256R1'
    | 'BrainpoolP384R1'
    | 'BrainpoolP512R1'
    | 'X25519'
    | 'Ed25519';
  keySize?: number;
}

interface OpenPgpApplicationRelatedData {
  aid: string;
  historical: string;
  signatureCounter: number;
}

export interface Spec extends TurboModule {
  getVersion(deviceHandle: string): Promise<Version>;
  getApplicationRelatedData(
    deviceHandle: string
  ): Promise<OpenPgpApplicationRelatedData>;

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

  setSignaturePinPolicy(
    deviceHandle: string,
    policy: 'ALWAYS' | 'ONCE'
  ): Promise<void>;

  getUif(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<'OFF' | 'ON' | 'FIXED' | 'CACHED' | 'CACHED_FIXED'>;
  setUif(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT',
    uif: 'OFF' | 'ON' | 'FIXED' | 'CACHED' | 'CACHED_FIXED'
  ): Promise<void>;

  getAlgorithmInformation(deviceHandle: string): Promise<
    Array<{
      keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT';
      attributes: OpenPgpAlgorithmAttributes[];
    }>
  >;

  setAlgorithmAttributes(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT',
    attributes: OpenPgpAlgorithmAttributes
  ): Promise<void>;

  getCertificate(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<string>;
  putCertificate(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT',
    certificate: string
  ): Promise<void>;
  deleteCertificate(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<void>;

  generateRsaKey(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT',
    keySize: number
  ): Promise<string>;
  generateEcKey(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT',
    curve:
      | 'SECP256R1'
      | 'SECP256K1'
      | 'SECP384R1'
      | 'SECP521R1'
      | 'BrainpoolP256R1'
      | 'BrainpoolP384R1'
      | 'BrainpoolP512R1'
      | 'X25519'
      | 'Ed25519'
  ): Promise<string>;
  getPublicKey(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<string>;
  deleteKey(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<void>;

  sign(deviceHandle: string, payload: string): Promise<string>;
  decrypt(deviceHandle: string, payload: string): Promise<string>;
  authenticate(deviceHandle: string, payload: string): Promise<string>;
  attestKey(
    deviceHandle: string,
    keyRef: 'SIG' | 'DEC' | 'AUT' | 'ATT'
  ): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitOpenPgp');
