import NativeYubikitSupport from './specs/NativeYubikitSupport';
import type { DeviceInfo, YubiKeyType } from './types';

export function readInfo(
  deviceHandle: string,
  pid?: number
): Promise<DeviceInfo> {
  return NativeYubikitSupport.readInfo(
    deviceHandle,
    pid
  ) as Promise<DeviceInfo>;
}

export function getName(
  info: DeviceInfo,
  keyType?: YubiKeyType
): Promise<string> {
  return NativeYubikitSupport.getName(info, keyType);
}

export { NativeYubikitSupport };
