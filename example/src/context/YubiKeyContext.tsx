import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import type { ReactNode } from 'react';
import { Core } from 'react-native-yubikit';
import type { YubiKeyDevice, YubiKeyEvent } from 'react-native-yubikit';

export interface LogEntry {
  id: number;
  message: string;
  isError: boolean;
}

interface YubiKeyContextValue {
  devices: YubiKeyDevice[];
  selectedDevice: YubiKeyDevice | null;
  selectDevice: (handle: string) => void;
  usbActive: boolean;
  toggleUsbDiscovery: () => Promise<void>;
  nfcActive: boolean;
  toggleNfcDiscovery: () => Promise<void>;
  logs: LogEntry[];
  log: (message: string, isError?: boolean) => void;
  clearLogs: () => void;
  withBusy: <T>(work: () => Promise<T>) => Promise<T | undefined>;
  isBusy: boolean;
}

const YubiKeyContext = createContext<YubiKeyContextValue | null>(null);

export function YubiKeyProvider({ children }: { children: ReactNode }) {
  const [devices, setDevices] = useState<YubiKeyDevice[]>([]);
  const [selectedHandle, setSelectedHandle] = useState<string | null>(null);
  const [usbActive, setUsbActive] = useState(false);
  const [nfcActive, setNfcActive] = useState(false);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [isBusy, setIsBusy] = useState(false);
  const nextLogId = useRef(0);

  const log = useCallback((message: string, isError = false) => {
    const id = nextLogId.current++;
    setLogs((prev) => [{ id, message, isError }, ...prev].slice(0, 50));
  }, []);

  const clearLogs = useCallback(() => setLogs([]), []);

  useEffect(() => {
    const subscription = Core.addYubiKeyListener((event: YubiKeyEvent) => {
      console.log('YubiKey event:', event);
      if (event.type === 'attached') {
        setDevices((prev) => [
          event.device,
          ...prev.filter((d) => d.handle !== event.device.handle),
        ]);
        setSelectedHandle((prev) => prev ?? event.device.handle);
        log(`YubiKey attached (${event.device.transport.toUpperCase()})`);

        return;
      }
      if (event.type === 'detached') {
        setDevices((prev) => prev.filter((d) => d.handle !== event.handle));
        setSelectedHandle((prev) => (prev === event.handle ? null : prev));
        log('YubiKey detached');

        return;
      }

      log(event.error, true);
    });

    return () => subscription.remove();
  }, [log]);

  const toggleUsbDiscovery = useCallback(async () => {
    try {
      if (usbActive) {
        Core.stopUsbDiscovery();
        setDevices([]);
        setUsbActive(false);
        log('Stopped USB discovery');
      } else {
        Core.startUsbDiscovery({ handlePermissions: true });
        setUsbActive(true);
        log('Started USB discovery — plug in a YubiKey');
      }
    } catch (e) {
      log(`USB discovery error: ${String(e)}`, true);
    }
  }, [usbActive, log]);

  const toggleNfcDiscovery = useCallback(async () => {
    try {
      if (nfcActive) {
        Core.stopNfcDiscovery();
        setNfcActive(false);
        log('Stopped NFC discovery');
      } else {
        Core.startNfcDiscovery();
        setNfcActive(true);
        log('Started NFC discovery — tap a YubiKey to the back of the device');
      }
    } catch (e) {
      log(`NFC discovery error: ${String(e)}`, true);
    }
  }, [nfcActive, log]);

  const selectDevice = useCallback((handle: string) => {
    setSelectedHandle(handle);
  }, []);

  const withBusy = useCallback(
    async <T,>(work: () => Promise<T>): Promise<T | undefined> => {
      setIsBusy(true);
      try {
        return await work();
      } catch (e) {
        log(String(e), true);
        return undefined;
      } finally {
        setIsBusy(false);
      }
    },
    [log]
  );

  const selectedDevice = useMemo(
    () => devices.find((d) => d.handle === selectedHandle) ?? null,
    [devices, selectedHandle]
  );

  const value = useMemo<YubiKeyContextValue>(
    () => ({
      devices,
      selectedDevice,
      selectDevice,
      usbActive,
      toggleUsbDiscovery,
      nfcActive,
      toggleNfcDiscovery,
      logs,
      log,
      clearLogs,
      withBusy,
      isBusy,
    }),
    [
      devices,
      selectedDevice,
      selectDevice,
      usbActive,
      toggleUsbDiscovery,
      nfcActive,
      toggleNfcDiscovery,
      logs,
      log,
      clearLogs,
      withBusy,
      isBusy,
    ]
  );

  return (
    <YubiKeyContext.Provider value={value}>{children}</YubiKeyContext.Provider>
  );
}

export function useYubiKey(): YubiKeyContextValue {
  const ctx = useContext(YubiKeyContext);
  if (!ctx) {
    throw new Error('useYubiKey must be used within a YubiKeyProvider');
  }
  return ctx;
}
