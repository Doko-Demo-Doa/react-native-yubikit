import NativeYubikitCore from './specs/NativeYubikitCore';
import type {
  Base64String,
  ConnectionType,
  NfcConfiguration,
  UsbConfiguration,
  YubiKeyDevice,
  YubiKeyEvent,
} from './types';
import { NativeEventEmitter } from 'react-native';

const eventEmitter = new NativeEventEmitter(NativeYubikitCore);

export function startUsbDiscovery(config?: UsbConfiguration): Promise<void> {
  return NativeYubikitCore.startUsbDiscovery(config ?? {});
}

export function stopUsbDiscovery(): Promise<void> {
  return NativeYubikitCore.stopUsbDiscovery();
}

export function startNfcDiscovery(config?: NfcConfiguration): Promise<void> {
  return NativeYubikitCore.startNfcDiscovery(config ?? {});
}

export function stopNfcDiscovery(): Promise<void> {
  return NativeYubikitCore.stopNfcDiscovery();
}

export function requestConnection(
  deviceHandle: string,
  connectionType: ConnectionType
): Promise<string> {
  return NativeYubikitCore.requestConnection(deviceHandle, connectionType);
}

export function sendApdu(
  connectionHandle: string,
  apdu: Base64String
): Promise<Base64String> {
  return NativeYubikitCore.sendApdu(connectionHandle, apdu);
}

export function closeConnection(connectionHandle: string): Promise<void> {
  return NativeYubikitCore.closeConnection(connectionHandle);
}

export function getDiscoveredDevices(): Promise<YubiKeyDevice[]> {
  return NativeYubikitCore.getDiscoveredDevices() as Promise<YubiKeyDevice[]>;
}

export function addYubiKeyListener(
  listener: (event: YubiKeyEvent) => void
): ReturnType<typeof eventEmitter.addListener> {
  return eventEmitter.addListener(
    'YubiKeyEvent',
    listener as (...args: unknown[]) => void
  );
}

export { NativeYubikitCore };
