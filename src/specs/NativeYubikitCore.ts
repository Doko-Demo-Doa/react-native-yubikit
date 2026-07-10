import { TurboModuleRegistry, type TurboModule } from 'react-native';

interface UsbConfiguration {
  handlePermissions?: boolean;
}

interface NfcConfiguration {
  timeout?: number;
  disableNfcDiscoverySound?: boolean;
  skipNdefCheck?: boolean;
  handleUnavailableNfc?: boolean;
}

interface YubiKeyDevice {
  handle: string;
  transport: 'usb' | 'nfc';
  supportedConnections: string[];
}

export interface Spec extends TurboModule {
  /** Start listening for USB YubiKeys. */
  startUsbDiscovery(config?: UsbConfiguration): void;
  /** Stop listening for USB YubiKeys. */
  stopUsbDiscovery(): void;
  /** Start listening for NFC YubiKeys. */
  startNfcDiscovery(config?: NfcConfiguration): void;
  /** Stop listening for NFC YubiKeys. */
  stopNfcDiscovery(): void;

  /**
   * Request a connection to a discovered device. The promise resolves with a
   * connection handle that can be passed to session modules.
   */
  requestConnection(
    deviceHandle: string,
    connectionType: string
  ): Promise<string>;

  /**
   * Send a raw APDU over a SmartCardConnection and receive the response.
   */
  sendApdu(connectionHandle: string, apdu: string): Promise<string>;

  /** Close an opened connection. */
  closeConnection(connectionHandle: string): void;

  /** List devices currently held by the manager. */
  getDiscoveredDevices(): YubiKeyDevice[];

  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitCore');
