import NativeYubikitYubiOtp from './specs/NativeYubikitYubiOtp';
import type {
  Base64String,
  ConfigurationState,
  OtpSlot,
  OtpSlotConfiguration,
  Version,
} from './types';

export function getConfigurationState(
  deviceHandle: string
): Promise<ConfigurationState> {
  return NativeYubikitYubiOtp.getConfigurationState(
    deviceHandle
  ) as Promise<ConfigurationState>;
}

export function getVersion(deviceHandle: string): Promise<Version> {
  return NativeYubikitYubiOtp.getVersion(deviceHandle) as Promise<Version>;
}

export function getSerialNumber(deviceHandle: string): Promise<number> {
  return NativeYubikitYubiOtp.getSerialNumber(deviceHandle);
}

export function swapConfigurations(deviceHandle: string): Promise<void> {
  return NativeYubikitYubiOtp.swapConfigurations(deviceHandle);
}

export function deleteConfiguration(
  deviceHandle: string,
  slot: OtpSlot,
  currentAccessCode?: Base64String
): Promise<void> {
  return NativeYubikitYubiOtp.deleteConfiguration(
    deviceHandle,
    slot,
    currentAccessCode
  );
}

export function putConfiguration(
  deviceHandle: string,
  slot: OtpSlot,
  configuration: OtpSlotConfiguration,
  accessCode?: Base64String,
  currentAccessCode?: Base64String
): Promise<void> {
  return NativeYubikitYubiOtp.putConfiguration(
    deviceHandle,
    slot,
    configuration,
    accessCode,
    currentAccessCode
  );
}

export function updateConfiguration(
  deviceHandle: string,
  slot: OtpSlot,
  configuration: OtpSlotConfiguration,
  accessCode?: Base64String,
  currentAccessCode?: Base64String
): Promise<void> {
  return NativeYubikitYubiOtp.updateConfiguration(
    deviceHandle,
    slot,
    configuration,
    accessCode,
    currentAccessCode
  );
}

export function setNdefConfiguration(
  deviceHandle: string,
  slot: OtpSlot,
  uri?: string,
  currentAccessCode?: Base64String
): Promise<void> {
  return NativeYubikitYubiOtp.setNdefConfiguration(
    deviceHandle,
    slot,
    uri,
    currentAccessCode
  );
}

export function calculateHmacSha1(
  deviceHandle: string,
  slot: OtpSlot,
  challenge: Base64String
): Promise<Base64String> {
  return NativeYubikitYubiOtp.calculateHmacSha1(deviceHandle, slot, challenge);
}

export { NativeYubikitYubiOtp };
