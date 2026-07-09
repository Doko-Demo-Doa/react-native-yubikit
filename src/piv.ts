import NativeYubikitPiv from './specs/NativeYubikitPiv';
import type {
  Base64String,
  PivBioMetadata,
  PivKeyType,
  PivManagementKeyMetadata,
  PivManagementKeyType,
  PivPinMetadata,
  PivPinPolicy,
  PivSlot,
  PivSlotMetadata,
  PivTouchPolicy,
} from './types';

export function reset(deviceHandle: string): Promise<void> {
  return NativeYubikitPiv.reset(deviceHandle);
}

export function getSerialNumber(deviceHandle: string): Promise<number> {
  return NativeYubikitPiv.getSerialNumber(deviceHandle);
}

export function authenticate(
  deviceHandle: string,
  managementKey: Base64String
): Promise<void> {
  return NativeYubikitPiv.authenticate(deviceHandle, managementKey);
}

export function setManagementKey(
  deviceHandle: string,
  keyType: PivManagementKeyType,
  managementKey: Base64String,
  requireTouch: boolean
): Promise<void> {
  return NativeYubikitPiv.setManagementKey(
    deviceHandle,
    keyType,
    managementKey,
    requireTouch
  );
}

export function verifyPin(deviceHandle: string, pin: string): Promise<void> {
  return NativeYubikitPiv.verifyPin(deviceHandle, pin);
}

export function getPinAttempts(deviceHandle: string): Promise<number> {
  return NativeYubikitPiv.getPinAttempts(deviceHandle);
}

export function changePin(
  deviceHandle: string,
  oldPin: string,
  newPin: string
): Promise<void> {
  return NativeYubikitPiv.changePin(deviceHandle, oldPin, newPin);
}

export function changePuk(
  deviceHandle: string,
  oldPuk: string,
  newPuk: string
): Promise<void> {
  return NativeYubikitPiv.changePuk(deviceHandle, oldPuk, newPuk);
}

export function unblockPin(
  deviceHandle: string,
  puk: string,
  newPin: string
): Promise<void> {
  return NativeYubikitPiv.unblockPin(deviceHandle, puk, newPin);
}

export function setPinAttempts(
  deviceHandle: string,
  pinAttempts: number,
  pukAttempts: number
): Promise<void> {
  return NativeYubikitPiv.setPinAttempts(
    deviceHandle,
    pinAttempts,
    pukAttempts
  );
}

export function getPinMetadata(deviceHandle: string): Promise<PivPinMetadata> {
  return NativeYubikitPiv.getPinMetadata(
    deviceHandle
  ) as Promise<PivPinMetadata>;
}

export function getPukMetadata(deviceHandle: string): Promise<PivPinMetadata> {
  return NativeYubikitPiv.getPukMetadata(
    deviceHandle
  ) as Promise<PivPinMetadata>;
}

export function getManagementKeyMetadata(
  deviceHandle: string
): Promise<PivManagementKeyMetadata> {
  return NativeYubikitPiv.getManagementKeyMetadata(
    deviceHandle
  ) as Promise<PivManagementKeyMetadata>;
}

export function getSlotMetadata(
  deviceHandle: string,
  slot: PivSlot
): Promise<PivSlotMetadata> {
  return NativeYubikitPiv.getSlotMetadata(
    deviceHandle,
    slot
  ) as Promise<PivSlotMetadata>;
}

export function getCertificate(
  deviceHandle: string,
  slot: PivSlot
): Promise<Base64String> {
  return NativeYubikitPiv.getCertificate(deviceHandle, slot);
}

export function putCertificate(
  deviceHandle: string,
  slot: PivSlot,
  certificate: Base64String,
  compress?: boolean
): Promise<void> {
  return NativeYubikitPiv.putCertificate(
    deviceHandle,
    slot,
    certificate,
    compress
  );
}

export function deleteCertificate(
  deviceHandle: string,
  slot: PivSlot
): Promise<void> {
  return NativeYubikitPiv.deleteCertificate(deviceHandle, slot);
}

export function attestKey(
  deviceHandle: string,
  slot: PivSlot
): Promise<Base64String> {
  return NativeYubikitPiv.attestKey(deviceHandle, slot);
}

export function generateKey(
  deviceHandle: string,
  slot: PivSlot,
  keyType: PivKeyType,
  pinPolicy: PivPinPolicy,
  touchPolicy: PivTouchPolicy
): Promise<Base64String> {
  return NativeYubikitPiv.generateKey(
    deviceHandle,
    slot,
    keyType,
    pinPolicy,
    touchPolicy
  );
}

export function deleteKey(deviceHandle: string, slot: PivSlot): Promise<void> {
  return NativeYubikitPiv.deleteKey(deviceHandle, slot);
}

export function rawSignOrDecrypt(
  deviceHandle: string,
  slot: PivSlot,
  keyType: PivKeyType,
  payload: Base64String
): Promise<Base64String> {
  return NativeYubikitPiv.rawSignOrDecrypt(
    deviceHandle,
    slot,
    keyType,
    payload
  );
}

export function getBioMetadata(deviceHandle: string): Promise<PivBioMetadata> {
  return NativeYubikitPiv.getBioMetadata(
    deviceHandle
  ) as Promise<PivBioMetadata>;
}

export { NativeYubikitPiv };
