/**
 * Shared TypeScript types mirroring the YubiKit Android SDK v3 public API.
 * Serialization over the bridge uses plain objects and base64-encoded byte arrays.
 */

export type Base64String = string;

export type Transport = 'usb' | 'nfc';

export interface Version {
  major: number;
  minor: number;
  micro: number;
}

export interface YubiKeyDevice {
  /** Unique handle for this device within the current session. */
  handle: string;
  transport: Transport;
  /** Types of connections supported by the device, e.g. ["SmartCardConnection"]. */
  supportedConnections: string[];
}

export type ConnectionType =
  'SmartCardConnection' | 'OtpConnection' | 'FidoConnection';

export interface UsbConfiguration {
  handlePermissions?: boolean;
}

export interface NfcConfiguration {
  timeout?: number;
  disableNfcDiscoverySound?: boolean;
  skipNdefCheck?: boolean;
  handleUnavailableNfc?: boolean;
}

export interface NfcNotAvailableError {
  disabled: boolean;
  message: string;
}

export type YubiKeyEvent =
  | { type: 'attached'; device: YubiKeyDevice }
  | { type: 'detached'; handle: string }
  | { type: 'error'; error: string };

/** Core module enums */

export type YubiKeyType = 'YKS' | 'NEO' | 'SKY' | 'YKP' | 'YK4' | 'OTHER';

export type FormFactor =
  | 'UNKNOWN'
  | 'USB_A_KEYCHAIN'
  | 'USB_A_NANO'
  | 'USB_C_KEYCHAIN'
  | 'USB_C_NANO'
  | 'USB_C_LIGHTNING'
  | 'USB_A_BIO'
  | 'USB_C_BIO';

export type Capability =
  'OTP' | 'U2F' | 'OPENPGP' | 'PIV' | 'OATH' | 'HSMAUTH' | 'FIDO2';

export interface DeviceConfig {
  enabledCapabilities?: Partial<Record<Transport, number>>;
  autoEjectTimeout?: number;
  challengeResponseTimeout?: number;
  nfcRestricted?: boolean;
  deviceFlags?: number;
}

export interface DeviceInfo {
  config?: DeviceConfig;
  serialNumber?: number;
  version: Version;
  versionName: string;
  formFactor: FormFactor;
  supportedCapabilities: Partial<Record<Transport, number>>;
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

export type UsbMode =
  | 'OTP'
  | 'FIDO'
  | 'CCID'
  | 'OTP_FIDO'
  | 'OTP_CCID'
  | 'FIDO_CCID'
  | 'OTP_FIDO_CCID';

/** OATH module */

export type OathType = 'HOTP' | 'TOTP';
export type HashAlgorithm = 'SHA1' | 'SHA256' | 'SHA512';

export interface Credential {
  id: Base64String;
  oathType: OathType;
  issuer?: string;
  accountName: string;
  period: number;
  touchRequired: boolean;
}

export interface Code {
  value: string;
  validFrom: number;
  validUntil: number;
}

export interface CredentialData {
  accountName: string;
  oathType: OathType;
  hashAlgorithm: HashAlgorithm;
  secret: Base64String;
  digits: number;
  period: number;
  counter: number;
  issuer?: string;
}

export interface OathCredentialsResult {
  credentials: Credential[];
}

export interface OathCodesResult {
  codes: Array<{ credential: Credential; code?: Code }>;
}

/** PIV module */

export type PivSlot =
  | 'AUTHENTICATION'
  | 'SIGNATURE'
  | 'KEY_MANAGEMENT'
  | 'CARD_AUTH'
  | 'RETIRED1'
  | 'RETIRED2'
  | 'RETIRED3'
  | 'RETIRED4'
  | 'RETIRED5'
  | 'RETIRED6'
  | 'RETIRED7'
  | 'RETIRED8'
  | 'RETIRED9'
  | 'RETIRED10'
  | 'RETIRED11'
  | 'RETIRED12'
  | 'RETIRED13'
  | 'RETIRED14'
  | 'RETIRED15'
  | 'RETIRED16'
  | 'RETIRED17'
  | 'RETIRED18'
  | 'RETIRED19'
  | 'RETIRED20'
  | 'ATTESTATION';

export type PivKeyType =
  | 'RSA1024'
  | 'RSA2048'
  | 'RSA3072'
  | 'RSA4096'
  | 'ECCP256'
  | 'ECCP384'
  | 'ED25519'
  | 'X25519';

export type PivPinPolicy =
  'DEFAULT' | 'NEVER' | 'ONCE' | 'ALWAYS' | 'MATCH_ONCE' | 'MATCH_ALWAYS';

export type PivTouchPolicy = 'DEFAULT' | 'NEVER' | 'ALWAYS' | 'CACHED';

export type PivManagementKeyType = 'TDES' | 'AES128' | 'AES192' | 'AES256';

export interface PivPinMetadata {
  attemptsRemaining: number;
}

export interface PivSlotMetadata {
  keyType: PivKeyType;
  pinPolicy: PivPinPolicy;
  touchPolicy: PivTouchPolicy;
  generated: boolean;
  publicKey?: Base64String;
}

export interface PivManagementKeyMetadata {
  keyType: PivManagementKeyType;
  defaultValue: boolean;
  touchRequired: boolean;
}

export interface PivBioMetadata {
  attemptsRemaining?: number;
  temporaryPin?: boolean;
}

/** OpenPGP module */

export type OpenPgpKeyRef = 'SIG' | 'DEC' | 'AUT' | 'ATT';

export type OpenPgpUif = 'OFF' | 'ON' | 'FIXED' | 'CACHED' | 'CACHED_FIXED';

export type OpenPgpPinPolicy = 'ALWAYS' | 'ONCE';

export type OpenPgpCurve =
  | 'SECP256R1'
  | 'SECP256K1'
  | 'SECP384R1'
  | 'SECP521R1'
  | 'BrainpoolP256R1'
  | 'BrainpoolP384R1'
  | 'BrainpoolP512R1'
  | 'X25519'
  | 'Ed25519';

export interface OpenPgpAlgorithmAttributes {
  keyRef: OpenPgpKeyRef;
  algorithm: string;
  curve?: OpenPgpCurve;
  keySize?: number;
}

export interface OpenPgpApplicationRelatedData {
  aid: Base64String;
  historical: Base64String;
  signatureCounter: number;
}

/** YubiOTP module */

export type OtpSlot = 'ONE' | 'TWO';

export interface ConfigurationState {
  slot1Configured: boolean;
  slot2Configured: boolean;
  slot1TouchTriggered: boolean;
  slot2TouchTriggered: boolean;
  ledInverted: boolean;
}

export type OtpConfigurationType =
  | 'YubiOtp'
  | 'HOTP'
  | 'HmacSha1'
  | 'StaticPassword'
  | 'StaticTicket'
  | 'Update';

export interface OtpSlotConfiguration {
  type: OtpConfigurationType;
  /** Base64-encoded fixed public ID (YubiOTP/StaticTicket). */
  fixed?: Base64String;
  /** Base64-encoded private ID (YubiOTP/StaticTicket). */
  uid?: Base64String;
  /** Base64-encoded AES key. */
  key?: Base64String;
  /** Base64-encoded HOTP/HMAC secret. */
  secret?: Base64String;
  /** Base64-encoded scan codes (StaticPassword). */
  scanCodes?: Base64String;
  /** HOTP digits: 6 or 8. */
  digits?: number;
  /** HOTP initial moving factor. */
  imf?: number;
  /** HMAC-SHA1: require touch to trigger. */
  requireTouch?: boolean;
  /** HMAC-SHA1: allow less than 64 byte challenges. */
  lt64?: boolean;
  /** Common flags. */
  appendCr?: boolean;
  serialApiVisible?: boolean;
  serialUsbVisible?: boolean;
  allowUpdate?: boolean;
  dormant?: boolean;
  invertLed?: boolean;
}

/** FIDO module */

export interface PublicKeyCredentialCreationOptions {
  rp: { id: string; name: string };
  user: { id: Base64String; name: string; displayName: string };
  challenge: Base64String;
  pubKeyCredParams: Array<{ type: string; alg: number }>;
  timeout?: number;
  excludeCredentials?: Array<{
    id: Base64String;
    type: string;
    transports?: string[];
  }>;
  authenticatorSelection?: {
    authenticatorAttachment?: string;
    residentKey?: string;
    userVerification?: string;
  };
  attestation?: string;
  extensions?: Record<string, unknown>;
}

export interface PublicKeyCredentialRequestOptions {
  challenge: Base64String;
  timeout?: number;
  rpId?: string;
  allowCredentials?: Array<{
    id: Base64String;
    type: string;
    transports?: string[];
  }>;
  userVerification?: string;
  extensions?: Record<string, unknown>;
}

export interface PublicKeyCredential {
  id: Base64String;
  rawId: Base64String;
  type: 'public-key';
  response: {
    clientDataJSON: Base64String;
    authenticatorData?: Base64String;
    attestationObject?: Base64String;
    signature?: Base64String;
    userHandle?: Base64String;
  };
}

export interface Ctap2Info {
  versions: string[];
  extensions?: string[];
  aaguid?: Base64String;
  options?: Record<string, boolean>;
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
  certifications?: Record<string, number>;
  remainingDiscoverableCredentials?: number;
  vendorPrototypeConfigCommands?: number[];
}

export interface FidoCredentialDescriptor {
  id: Base64String;
  type: string;
}

export interface FidoCredentialUserEntity {
  id: Base64String;
  name: string;
  displayName: string;
}

/** Support module */

export interface SupportDeviceInfo extends DeviceInfo {
  name: string;
}
