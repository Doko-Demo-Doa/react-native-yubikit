import NativeYubikitFido from './specs/NativeYubikitFido';
import type {
  Ctap2Info,
  FidoCredentialDescriptor,
  FidoCredentialUserEntity,
  PublicKeyCredential,
  PublicKeyCredentialCreationOptions,
  PublicKeyCredentialRequestOptions,
} from './types';

export function getInfo(deviceHandle: string): Promise<Ctap2Info> {
  return NativeYubikitFido.getInfo(deviceHandle) as Promise<Ctap2Info>;
}

export function makeCredential(
  deviceHandle: string,
  options: PublicKeyCredentialCreationOptions,
  effectiveDomain: string,
  pin?: string,
  enterpriseAttestation?: number
): Promise<PublicKeyCredential> {
  return NativeYubikitFido.makeCredential(
    deviceHandle,
    options,
    effectiveDomain,
    pin,
    enterpriseAttestation
  ) as Promise<PublicKeyCredential>;
}

export function getAssertion(
  deviceHandle: string,
  options: PublicKeyCredentialRequestOptions,
  effectiveDomain: string,
  pin?: string
): Promise<PublicKeyCredential> {
  return NativeYubikitFido.getAssertion(
    deviceHandle,
    options,
    effectiveDomain,
    pin
  ) as Promise<PublicKeyCredential>;
}

export function reset(deviceHandle: string): Promise<void> {
  return NativeYubikitFido.reset(deviceHandle);
}

export function getCredentialCount(
  deviceHandle: string,
  pin: string
): Promise<number> {
  return NativeYubikitFido.getCredentialCount(deviceHandle, pin);
}

export function getRpIdList(
  deviceHandle: string,
  pin: string
): Promise<string[]> {
  return NativeYubikitFido.getRpIdList(deviceHandle, pin) as Promise<string[]>;
}

export function getCredentials(
  deviceHandle: string,
  rpId: string,
  pin: string
): Promise<
  Array<{
    credential: FidoCredentialDescriptor;
    user: FidoCredentialUserEntity;
  }>
> {
  return NativeYubikitFido.getCredentials(deviceHandle, rpId, pin) as Promise<
    Array<{
      credential: FidoCredentialDescriptor;
      user: FidoCredentialUserEntity;
    }>
  >;
}

export function deleteCredential(
  deviceHandle: string,
  credential: FidoCredentialDescriptor,
  pin: string
): Promise<void> {
  return NativeYubikitFido.deleteCredential(deviceHandle, credential, pin);
}

export function updateUserInformation(
  deviceHandle: string,
  credential: FidoCredentialDescriptor,
  user: FidoCredentialUserEntity,
  pin: string
): Promise<void> {
  return NativeYubikitFido.updateUserInformation(
    deviceHandle,
    credential,
    user,
    pin
  );
}

export { NativeYubikitFido };
