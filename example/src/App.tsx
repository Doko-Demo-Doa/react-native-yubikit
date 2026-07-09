import { useEffect, useState } from 'react';
import { Text, View, StyleSheet, ScrollView, Button } from 'react-native';
import {
  Core,
  Management,
  type YubiKeyDevice,
  type YubiKeyEvent,
} from 'react-native-yubikit';

export default function App() {
  const [logs, setLogs] = useState<string[]>(['YubiKit example app']);
  const [devices, setDevices] = useState<YubiKeyDevice[]>([]);

  useEffect(() => {
    const subscription = Core.addYubiKeyListener((event: YubiKeyEvent) => {
      if (event.type === 'attached') {
        setLogs((prev) => [...prev, `Attached: ${event.device.handle}`]);
        setDevices((prev) => [...prev, event.device]);
      } else if (event.type === 'detached') {
        setLogs((prev) => [...prev, `Detached: ${event.handle}`]);
        setDevices((prev) => prev.filter((d) => d.handle !== event.handle));
      } else if (event.type === 'error') {
        setLogs((prev) => [...prev, `Error: ${event.error}`]);
      }
    });

    Core.startUsbDiscovery()
      .then(() => setLogs((prev) => [...prev, 'USB discovery started']))
      .catch((e) => setLogs((prev) => [...prev, `USB error: ${String(e)}`]));

    return () => {
      subscription.remove();
      Core.stopUsbDiscovery().catch(() => {});
    };
  }, []);

  const readInfo = async (device: YubiKeyDevice) => {
    try {
      const info = await Management.getDeviceInfo(device.handle);
      setLogs((prev) => [
        ...prev,
        `Device info: ${info.versionName} (${info.formFactor})`,
      ]);
    } catch (e) {
      setLogs((prev) => [...prev, `Info error: ${String(e)}`]);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>react-native-yubikit</Text>
      {devices.length === 0 && <Text>Waiting for YubiKey...</Text>}
      {devices.map((device) => (
        <View key={device.handle} style={styles.device}>
          <Text>{device.transport.toUpperCase()}</Text>
          <Button title="Read device info" onPress={() => readInfo(device)} />
        </View>
      ))}
      <View style={styles.logs}>
        {logs.map((log, i) => (
          <Text key={i}>{log}</Text>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  device: {
    marginVertical: 8,
    alignItems: 'center',
  },
  logs: {
    marginTop: 24,
    alignSelf: 'stretch',
  },
});
