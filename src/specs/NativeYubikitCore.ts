import {
  TurboModuleRegistry,
  type TurboModule,
  type CodegenTypes,
} from 'react-native';

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

// Codegen doesn't support discriminated union payloads, so every variant's
// fields are optional here; consumers get the narrower YubiKeyEvent union
// via Core.addYubiKeyListener instead of calling this event directly.
interface YubiKeyEventPayload {
  type: 'attached' | 'detached' | 'error';
  device?: YubiKeyDevice;
  handle?: string;
  error?: string;
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

  /** Fires on device attach/detach and discovery-connection failures. */
  readonly onYubiKeyEvent: CodegenTypes.EventEmitter<YubiKeyEventPayload>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitCore');
