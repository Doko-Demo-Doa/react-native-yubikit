import NativeYubikitManagement from './specs/NativeYubikitManagement';
import type { Base64String, DeviceConfig, DeviceInfo, UsbMode } from './types';

export function getDeviceInfo(deviceHandle: string): Promise<DeviceInfo> {
  return NativeYubikitManagement.getDeviceInfo(
    deviceHandle
  ) as Promise<DeviceInfo>;
}

export function updateDeviceConfig(
  deviceHandle: string,
  config: DeviceConfig,
  reboot: boolean,
  currentLockCode?: Base64String,
  newLockCode?: Base64String
): Promise<void> {
  return NativeYubikitManagement.updateDeviceConfig(
    deviceHandle,
    config,
    reboot,
    currentLockCode,
    newLockCode
  );
}

export function setMode(
  deviceHandle: string,
  mode: UsbMode,
  chalrespTimeout: number,
  autoejectTimeout: number
): Promise<void> {
  return NativeYubikitManagement.setMode(
    deviceHandle,
    mode,
    chalrespTimeout,
    autoejectTimeout
  );
}

export function deviceReset(deviceHandle: string): Promise<void> {
  return NativeYubikitManagement.deviceReset(deviceHandle);
}

export { NativeYubikitManagement };
