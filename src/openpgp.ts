import NativeYubikitOpenPgp from './specs/NativeYubikitOpenPgp';
import type {
  Base64String,
  OpenPgpAlgorithmAttributes,
  OpenPgpApplicationRelatedData,
  OpenPgpCurve,
  OpenPgpKeyRef,
  OpenPgpPinPolicy,
  OpenPgpUif,
  Version,
} from './types';

export function getVersion(deviceHandle: string): Promise<Version> {
  return NativeYubikitOpenPgp.getVersion(deviceHandle) as Promise<Version>;
}

export function getApplicationRelatedData(
  deviceHandle: string
): Promise<OpenPgpApplicationRelatedData> {
  return NativeYubikitOpenPgp.getApplicationRelatedData(
    deviceHandle
  ) as Promise<OpenPgpApplicationRelatedData>;
}

export function verifyUserPin(
  deviceHandle: string,
  pin: string,
  extended?: boolean
): Promise<void> {
  return NativeYubikitOpenPgp.verifyUserPin(deviceHandle, pin, extended);
}

export function verifyAdminPin(
  deviceHandle: string,
  pin: string
): Promise<void> {
  return NativeYubikitOpenPgp.verifyAdminPin(deviceHandle, pin);
}

export function unverifyUserPin(deviceHandle: string): Promise<void> {
  return NativeYubikitOpenPgp.unverifyUserPin(deviceHandle);
}

export function unverifyAdminPin(deviceHandle: string): Promise<void> {
  return NativeYubikitOpenPgp.unverifyAdminPin(deviceHandle);
}

export function getSignatureCounter(deviceHandle: string): Promise<number> {
  return NativeYubikitOpenPgp.getSignatureCounter(deviceHandle);
}

export function getChallenge(
  deviceHandle: string,
  length: number
): Promise<Base64String> {
  return NativeYubikitOpenPgp.getChallenge(deviceHandle, length);
}

export function reset(deviceHandle: string): Promise<void> {
  return NativeYubikitOpenPgp.reset(deviceHandle);
}

export function setPinAttempts(
  deviceHandle: string,
  userAttempts: number,
  resetAttempts: number,
  adminAttempts: number
): Promise<void> {
  return NativeYubikitOpenPgp.setPinAttempts(
    deviceHandle,
    userAttempts,
    resetAttempts,
    adminAttempts
  );
}

export function changeUserPin(
  deviceHandle: string,
  pin: string,
  newPin: string
): Promise<void> {
  return NativeYubikitOpenPgp.changeUserPin(deviceHandle, pin, newPin);
}

export function changeAdminPin(
  deviceHandle: string,
  pin: string,
  newPin: string
): Promise<void> {
  return NativeYubikitOpenPgp.changeAdminPin(deviceHandle, pin, newPin);
}

export function setSignaturePinPolicy(
  deviceHandle: string,
  policy: OpenPgpPinPolicy
): Promise<void> {
  return NativeYubikitOpenPgp.setSignaturePinPolicy(deviceHandle, policy);
}

export function getUif(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<OpenPgpUif> {
  return NativeYubikitOpenPgp.getUif(
    deviceHandle,
    keyRef
  ) as Promise<OpenPgpUif>;
}

export function setUif(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef,
  uif: OpenPgpUif
): Promise<void> {
  return NativeYubikitOpenPgp.setUif(deviceHandle, keyRef, uif);
}

export function getAlgorithmInformation(
  deviceHandle: string
): Promise<
  Array<{ keyRef: OpenPgpKeyRef; attributes: OpenPgpAlgorithmAttributes[] }>
> {
  return NativeYubikitOpenPgp.getAlgorithmInformation(deviceHandle) as Promise<
    Array<{ keyRef: OpenPgpKeyRef; attributes: OpenPgpAlgorithmAttributes[] }>
  >;
}

export function setAlgorithmAttributes(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef,
  attributes: OpenPgpAlgorithmAttributes
): Promise<void> {
  return NativeYubikitOpenPgp.setAlgorithmAttributes(
    deviceHandle,
    keyRef,
    attributes
  );
}

export function getCertificate(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<Base64String> {
  return NativeYubikitOpenPgp.getCertificate(deviceHandle, keyRef);
}

export function putCertificate(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef,
  certificate: Base64String
): Promise<void> {
  return NativeYubikitOpenPgp.putCertificate(deviceHandle, keyRef, certificate);
}

export function deleteCertificate(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<void> {
  return NativeYubikitOpenPgp.deleteCertificate(deviceHandle, keyRef);
}

export function generateRsaKey(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef,
  keySize: number
): Promise<Base64String> {
  return NativeYubikitOpenPgp.generateRsaKey(deviceHandle, keyRef, keySize);
}

export function generateEcKey(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef,
  curve: OpenPgpCurve
): Promise<Base64String> {
  return NativeYubikitOpenPgp.generateEcKey(deviceHandle, keyRef, curve);
}

export function getPublicKey(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<Base64String> {
  return NativeYubikitOpenPgp.getPublicKey(deviceHandle, keyRef);
}

export function deleteKey(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<void> {
  return NativeYubikitOpenPgp.deleteKey(deviceHandle, keyRef);
}

export function sign(
  deviceHandle: string,
  payload: Base64String
): Promise<Base64String> {
  return NativeYubikitOpenPgp.sign(deviceHandle, payload);
}

export function decrypt(
  deviceHandle: string,
  payload: Base64String
): Promise<Base64String> {
  return NativeYubikitOpenPgp.decrypt(deviceHandle, payload);
}

export function authenticate(
  deviceHandle: string,
  payload: Base64String
): Promise<Base64String> {
  return NativeYubikitOpenPgp.authenticate(deviceHandle, payload);
}

export function attestKey(
  deviceHandle: string,
  keyRef: OpenPgpKeyRef
): Promise<Base64String> {
  return NativeYubikitOpenPgp.attestKey(deviceHandle, keyRef);
}

export { NativeYubikitOpenPgp };
