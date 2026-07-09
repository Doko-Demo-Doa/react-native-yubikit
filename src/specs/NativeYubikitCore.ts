import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  /** Start listening for USB YubiKeys. */
  startUsbDiscovery(config?: Object): Promise<void>;
  /** Stop listening for USB YubiKeys. */
  stopUsbDiscovery(): Promise<void>;
  /** Start listening for NFC YubiKeys. */
  startNfcDiscovery(config?: Object): Promise<void>;
  /** Stop listening for NFC YubiKeys. */
  stopNfcDiscovery(): Promise<void>;

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
  closeConnection(connectionHandle: string): Promise<void>;

  /** List devices currently held by the manager. */
  getDiscoveredDevices(): Promise<Object[]>;

  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YubikitCore');
