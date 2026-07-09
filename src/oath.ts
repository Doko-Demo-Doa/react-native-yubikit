import NativeYubikitOath from './specs/NativeYubikitOath';
import type {
  Base64String,
  Code,
  Credential,
  CredentialData,
  OathCodesResult,
  OathCredentialsResult,
} from './types';

export function getDeviceId(deviceHandle: string): Promise<string> {
  return NativeYubikitOath.getDeviceId(deviceHandle);
}

export function reset(deviceHandle: string): Promise<void> {
  return NativeYubikitOath.reset(deviceHandle);
}

export function isAccessKeySet(deviceHandle: string): Promise<boolean> {
  return NativeYubikitOath.isAccessKeySet(deviceHandle);
}

export function isLocked(deviceHandle: string): Promise<boolean> {
  return NativeYubikitOath.isLocked(deviceHandle);
}

export function unlockWithPassword(
  deviceHandle: string,
  password: string
): Promise<boolean> {
  return NativeYubikitOath.unlockWithPassword(deviceHandle, password);
}

export function unlockWithAccessKey(
  deviceHandle: string,
  accessKey: Base64String
): Promise<boolean> {
  return NativeYubikitOath.unlockWithAccessKey(deviceHandle, accessKey);
}

export function setPassword(
  deviceHandle: string,
  password: string
): Promise<void> {
  return NativeYubikitOath.setPassword(deviceHandle, password);
}

export function setAccessKey(
  deviceHandle: string,
  accessKey: Base64String
): Promise<void> {
  return NativeYubikitOath.setAccessKey(deviceHandle, accessKey);
}

export function deleteAccessKey(deviceHandle: string): Promise<void> {
  return NativeYubikitOath.deleteAccessKey(deviceHandle);
}

export function getCredentials(
  deviceHandle: string
): Promise<OathCredentialsResult> {
  return NativeYubikitOath.getCredentials(
    deviceHandle
  ) as Promise<OathCredentialsResult>;
}

export function calculateCodes(
  deviceHandle: string,
  timestamp?: number
): Promise<OathCodesResult> {
  return NativeYubikitOath.calculateCodes(
    deviceHandle,
    timestamp
  ) as Promise<OathCodesResult>;
}

export function calculateResponse(
  deviceHandle: string,
  credentialId: Base64String,
  challenge: Base64String
): Promise<Base64String> {
  return NativeYubikitOath.calculateResponse(
    deviceHandle,
    credentialId,
    challenge
  );
}

export function calculateCode(
  deviceHandle: string,
  credentialId: Base64String,
  timestamp?: number
): Promise<Code> {
  return NativeYubikitOath.calculateCode(
    deviceHandle,
    credentialId,
    timestamp
  ) as Promise<Code>;
}

export function putCredential(
  deviceHandle: string,
  credentialData: CredentialData,
  requireTouch: boolean
): Promise<Credential> {
  return NativeYubikitOath.putCredential(
    deviceHandle,
    credentialData,
    requireTouch
  ) as Promise<Credential>;
}

export function deleteCredential(
  deviceHandle: string,
  credentialId: Base64String
): Promise<void> {
  return NativeYubikitOath.deleteCredential(deviceHandle, credentialId);
}

export function renameCredential(
  deviceHandle: string,
  credentialId: Base64String,
  newAccountName: string,
  newIssuer?: string
): Promise<Credential> {
  return NativeYubikitOath.renameCredential(
    deviceHandle,
    credentialId,
    newAccountName,
    newIssuer
  ) as Promise<Credential>;
}

export { NativeYubikitOath };
