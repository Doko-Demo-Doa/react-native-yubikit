import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  /** Get CTAP2 authenticator info. */
  getInfo(deviceHandle: string): Promise<Object>;

  /** Perform a WebAuthn registration (makeCredential). */
  makeCredential(
    deviceHandle: string,
    options: Object,
    effectiveDomain: string,
    pin?: string,
    enterpriseAttestation?: number
  ): Promise<Object>;

  /** Perform a WebAuthn authentication (getAssertion). */
  getAssertion(
    deviceHandle: string,
    options: Object,
    effectiveDomain: string,
    pin?: string
  ): Promise<Object>;

  /** Reset the authenticator. */
  reset(deviceHandle: string): Promise<void>;

  /** Credential management operations (requires PIN). */
  getCredentialCount(deviceHandle: string, pin: string): Promise<number>;
  getRpIdList(deviceHandle: string, pin: string): Promise<Object>;
  getCredentials(
    deviceHandle: string,
    rpId: string,
    pin: string
  ): Promise<Object[]>;
  deleteCredential(
    deviceHandle: string,
    credential: Object,
    pin: string
  ): Promise<void>;
  updateUserInformation(
    deviceHandle: string,
    credential: Object,
    user: Object,
    pin: string
  ): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitFido');
