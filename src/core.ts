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

export function startUsbDiscovery(config?: UsbConfiguration): void {
  NativeYubikitCore.startUsbDiscovery(config ?? {});
}

export function stopUsbDiscovery(): void {
  NativeYubikitCore.stopUsbDiscovery();
}

export function startNfcDiscovery(config?: NfcConfiguration): void {
  NativeYubikitCore.startNfcDiscovery(config ?? {});
}

export function stopNfcDiscovery(): void {
  NativeYubikitCore.stopNfcDiscovery();
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

export function closeConnection(connectionHandle: string): void {
  NativeYubikitCore.closeConnection(connectionHandle);
}

export function getDiscoveredDevices(): YubiKeyDevice[] {
  return NativeYubikitCore.getDiscoveredDevices() as YubiKeyDevice[];
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
