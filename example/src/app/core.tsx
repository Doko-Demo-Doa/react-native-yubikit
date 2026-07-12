import { useState } from 'react';
import { View } from 'react-native';
import { Chip } from 'heroui-native';
import {
  Button,
  Card,
  CardBody,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
  Paragraph,
} from '@/components/heroui';
import { Core } from 'react-native-yubikit';
import { DeviceBanner } from '@/components/DeviceBanner';
import { LogPanel } from '@/components/LogPanel';
import { useYubiKey } from '@/context/YubiKeyContext';
import { MasterLayout } from '@/components/layouts/MasterLayout';

export default function CoreScreen() {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [connectionHandle, setConnectionHandle] = useState<string | null>(null);

  const requestSmartCard = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const handle = await Core.requestConnection(
        selectedDevice.handle,
        'SmartCardConnection'
      );
      setConnectionHandle(handle);
      log(`Opened SmartCardConnection ${handle}`);
    });
  };

  const closeConnection = async () => {
    if (!connectionHandle) return;
    await withBusy(async () => {
      Core.closeConnection(connectionHandle);
      log(`Closed connection ${connectionHandle}`);
      setConnectionHandle(null);
    });
  };

  const listDevices = async () => {
    await withBusy(async () => {
      const devices = Core.getDiscoveredDevices();
      log(`Manager holds ${devices.length} device(s)`);
    });
  };

  return (
    <MasterLayout>
      <DeviceBanner />

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Connections</CardTitle>
          <CardDescription>
            Open a low-level connection to the selected device.
          </CardDescription>
        </CardHeader>
        <CardBody className="gap-3">
          {connectionHandle ? (
            <View className="flex-row items-center gap-2">
              <Paragraph type="body-sm">Open handle:</Paragraph>
              <Chip size="sm">{connectionHandle.slice(0, 8)}…</Chip>
            </View>
          ) : (
            <Paragraph color="muted" type="body-sm">
              No connection open.
            </Paragraph>
          )}
        </CardBody>
        <CardFooter className="flex-row gap-2">
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={requestSmartCard}
          >
            Open SmartCard connection
          </Button>
          <Button
            variant="outline"
            size="sm"
            isDisabled={!connectionHandle || isBusy}
            onPress={closeConnection}
          >
            Close
          </Button>
        </CardFooter>
      </Card>

      <Button
        variant="secondary"
        size="sm"
        className="self-start"
        onPress={listDevices}
      >
        List devices held by native manager
      </Button>

      <LogPanel />
    </MasterLayout>
  );
}
