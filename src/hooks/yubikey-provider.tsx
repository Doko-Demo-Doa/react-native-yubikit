import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import type { ReactNode } from 'react';
import * as Core from '../core';
import type {
  NfcConfiguration,
  UsbConfiguration,
  YubiKeyDevice,
  YubiKeyEvent,
} from '../types';

export interface YubiKeyContextValue {
  /** Devices currently attached, most-recently-attached first. */
  devices: YubiKeyDevice[];
  /** The selected device, or the most recently attached one if none was explicitly selected. */
  selectedDevice: YubiKeyDevice | null;
  /** Explicitly select a device by handle, or `null` to fall back to auto-selection. */
  selectDevice: (handle: string | null) => void;
  isUsbDiscovering: boolean;
  isNfcDiscovering: boolean;
  startUsbDiscovery: (config?: UsbConfiguration) => void;
  stopUsbDiscovery: () => void;
  startNfcDiscovery: (config?: NfcConfiguration) => void;
  stopNfcDiscovery: () => void;
  /** The most recent native-side error event, if any. */
  lastError: string | null;
}

export const YubiKeyContext = createContext<YubiKeyContextValue | null>(null);

export function YubiKeyProvider({ children }: { children: ReactNode }) {
  const [devices, setDevices] = useState<YubiKeyDevice[]>(() =>
    Core.getDiscoveredDevices()
  );
  const [selectedHandle, setSelectedHandle] = useState<string | null>(null);
  const [isUsbDiscovering, setIsUsbDiscovering] = useState(false);
  const [isNfcDiscovering, setIsNfcDiscovering] = useState(false);
  const [lastError, setLastError] = useState<string | null>(null);
  const isUsbDiscoveringRef = useRef(isUsbDiscovering);
  const isNfcDiscoveringRef = useRef(isNfcDiscovering);

  useEffect(() => {
    isUsbDiscoveringRef.current = isUsbDiscovering;
  }, [isUsbDiscovering]);

  useEffect(() => {
    isNfcDiscoveringRef.current = isNfcDiscovering;
  }, [isNfcDiscovering]);

  useEffect(() => {
    const subscription = Core.addYubiKeyListener((event: YubiKeyEvent) => {
      if (event.type === 'attached') {
        setDevices((prev) => [
          event.device,
          ...prev.filter((d) => d.handle !== event.device.handle),
        ]);
        return;
      }
      if (event.type === 'detached') {
        setDevices((prev) => prev.filter((d) => d.handle !== event.handle));
        setSelectedHandle((prev) => (prev === event.handle ? null : prev));
        return;
      }
      setLastError(event.error);
    });

    return () => subscription.remove();
  }, []);

  const startUsbDiscovery = useCallback((config?: UsbConfiguration) => {
    Core.startUsbDiscovery(config);
    setIsUsbDiscovering(true);
  }, []);

  const stopUsbDiscovery = useCallback(() => {
    Core.stopUsbDiscovery();
    setIsUsbDiscovering(false);
  }, []);

  const startNfcDiscovery = useCallback((config?: NfcConfiguration) => {
    Core.startNfcDiscovery(config);
    setIsNfcDiscovering(true);
  }, []);

  const stopNfcDiscovery = useCallback(() => {
    Core.stopNfcDiscovery();
    setIsNfcDiscovering(false);
  }, []);

  // Discovery is a global, imperative native API (not tied to this component's
  // lifetime by the native side), but leaving it running past the provider that
  // started it would leak a dangling USB/NFC session the app can no longer see.
  useEffect(() => {
    return () => {
      if (isUsbDiscoveringRef.current) Core.stopUsbDiscovery();
      if (isNfcDiscoveringRef.current) Core.stopNfcDiscovery();
    };
  }, []);

  const selectDevice = useCallback((handle: string | null) => {
    setSelectedHandle(handle);
  }, []);

  const selectedDevice = useMemo(
    () =>
      devices.find((d) => d.handle === selectedHandle) ?? devices[0] ?? null,
    [devices, selectedHandle]
  );

  const value = useMemo<YubiKeyContextValue>(
    () => ({
      devices,
      selectedDevice,
      selectDevice,
      isUsbDiscovering,
      isNfcDiscovering,
      startUsbDiscovery,
      stopUsbDiscovery,
      startNfcDiscovery,
      stopNfcDiscovery,
      lastError,
    }),
    [
      devices,
      selectedDevice,
      selectDevice,
      isUsbDiscovering,
      isNfcDiscovering,
      startUsbDiscovery,
      stopUsbDiscovery,
      startNfcDiscovery,
      stopNfcDiscovery,
      lastError,
    ]
  );

  return (
    <YubiKeyContext.Provider value={value}>{children}</YubiKeyContext.Provider>
  );
}
