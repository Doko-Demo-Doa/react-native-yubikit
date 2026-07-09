import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  /** Get a stable ID for the OATH application on this device. */
  getDeviceId(deviceHandle: string): Promise<string>;

  /** Reset the OATH application. */
  reset(deviceHandle: string): Promise<void>;

  /** True if an access key/password is configured. */
  isAccessKeySet(deviceHandle: string): Promise<boolean>;

  /** True if the session is locked and needs unlock. */
  isLocked(deviceHandle: string): Promise<boolean>;

  /** Unlock with a password. */
  unlockWithPassword(deviceHandle: string, password: string): Promise<boolean>;

  /** Unlock with a raw access key. */
  unlockWithAccessKey(
    deviceHandle: string,
    accessKey: string
  ): Promise<boolean>;

  /** Set or change the password used to derive the access key. */
  setPassword(deviceHandle: string, password: string): Promise<void>;

  /** Set the raw access key directly. */
  setAccessKey(deviceHandle: string, accessKey: string): Promise<void>;

  /** Remove access key protection. */
  deleteAccessKey(deviceHandle: string): Promise<void>;

  /** List stored credentials. */
  getCredentials(deviceHandle: string): Promise<Object>;

  /** Calculate all TOTP codes for the current time. */
  calculateCodes(deviceHandle: string, timestamp?: number): Promise<Object>;

  /** Calculate a HOTP response for a credential. */
  calculateResponse(
    deviceHandle: string,
    credentialId: string,
    challenge: string
  ): Promise<string>;

  /** Calculate a single TOTP/HOTP code. */
  calculateCode(
    deviceHandle: string,
    credentialId: string,
    timestamp?: number
  ): Promise<Object>;

  /** Add a new credential. */
  putCredential(
    deviceHandle: string,
    credentialData: Object,
    requireTouch: boolean
  ): Promise<Object>;

  /** Delete a credential by ID. */
  deleteCredential(deviceHandle: string, credentialId: string): Promise<void>;

  /** Rename a credential by ID. */
  renameCredential(
    deviceHandle: string,
    credentialId: string,
    newAccountName: string,
    newIssuer?: string
  ): Promise<Object>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitOath');
