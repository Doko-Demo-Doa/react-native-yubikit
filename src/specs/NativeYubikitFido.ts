import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface PublicKeyCredentialRpEntity {
  id: string;
  name: string;
}

interface PublicKeyCredentialUserEntity {
  id: string;
  name: string;
  displayName: string;
}

interface PublicKeyCredentialParameters {
  type: string;
  alg: number;
}

interface PublicKeyCredentialCreationOptions {
  rp: PublicKeyCredentialRpEntity;
  user: PublicKeyCredentialUserEntity;
  challenge: string;
  pubKeyCredParams: PublicKeyCredentialParameters[];
  timeout?: number;
  excludeCredentials?: Array<{
    id: string;
    type: string;
    transports?: string[];
  }>;
  authenticatorSelection?: {
    authenticatorAttachment?: string;
    residentKey?: string;
    userVerification?: string;
  };
  attestation?: string;
  extensions?: { [key: string]: unknown };
}

interface PublicKeyCredentialRequestOptions {
  challenge: string;
  timeout?: number;
  rpId?: string;
  allowCredentials?: Array<{
    id: string;
    type: string;
    transports?: string[];
  }>;
  userVerification?: string;
  extensions?: { [key: string]: unknown };
}

interface PublicKeyCredential {
  id: string;
  rawId: string;
  type: 'public-key';
  response: {
    clientDataJSON: string;
    authenticatorData?: string;
    attestationObject?: string;
    signature?: string;
    userHandle?: string;
  };
}

interface Ctap2Info {
  versions: string[];
  extensions?: string[];
  aaguid?: string;
  options?: { [key: string]: boolean };
  maxMsgSize?: number;
  pinUvAuthProtocols?: number[];
  maxCredentialCountInList?: number;
  maxCredentialIdLength?: number;
  transports?: string[];
  algorithms?: Array<{ type: string; alg: number }>;
  maxLargeBlob?: number;
  minPinLength?: number;
  firmwareVersion?: number;
  maxCredBlobLength?: number;
  maxRpidsForMinPinLength?: number;
  preferredPlatformUvAttempts?: number;
  uvModality?: number;
  certifications?: { [key: string]: number };
  remainingDiscoverableCredentials?: number;
  vendorPrototypeConfigCommands?: number[];
}

interface FidoCredentialDescriptor {
  id: string;
  type: string;
}

interface FidoCredentialUserEntity {
  id: string;
  name: string;
  displayName: string;
}

export interface Spec extends TurboModule {
  /** Get CTAP2 authenticator info. */
  getInfo(deviceHandle: string): Promise<Ctap2Info>;

  /** Perform a WebAuthn registration (makeCredential). */
  makeCredential(
    deviceHandle: string,
    options: PublicKeyCredentialCreationOptions,
    effectiveDomain: string,
    pin?: string,
    enterpriseAttestation?: number
  ): Promise<PublicKeyCredential>;

  /** Perform a WebAuthn authentication (getAssertion). */
  getAssertion(
    deviceHandle: string,
    options: PublicKeyCredentialRequestOptions,
    effectiveDomain: string,
    pin?: string
  ): Promise<PublicKeyCredential>;

  /** Reset the authenticator. */
  reset(deviceHandle: string): Promise<void>;

  /** Credential management operations (requires PIN). */
  getCredentialCount(deviceHandle: string, pin: string): Promise<number>;
  getRpIdList(deviceHandle: string, pin: string): Promise<string[]>;
  getCredentials(
    deviceHandle: string,
    rpId: string,
    pin: string
  ): Promise<
    Array<{
      credential: FidoCredentialDescriptor;
      user: FidoCredentialUserEntity;
    }>
  >;
  deleteCredential(
    deviceHandle: string,
    credential: FidoCredentialDescriptor,
    pin: string
  ): Promise<void>;
  updateUserInformation(
    deviceHandle: string,
    credential: FidoCredentialDescriptor,
    user: FidoCredentialUserEntity,
    pin: string
  ): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitFido');
