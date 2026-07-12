import { useState } from 'react';
import { Button, Card, ListGroup } from 'heroui-native';
import { Support, type YubiKeyDevice } from 'react-native-yubikit';

import { ScreenHeader } from '@/components/ScreenHeader';
import { DeviceBanner } from '@/components/DeviceBanner';
import { LogPanel } from '@/components/LogPanel';
import { useYubiKey } from '@/context/YubiKeyContext';
import { MasterLayout } from '@/components/layouts/MasterLayout';

export default function SupportScreen() {
  const { devices, log, withBusy, isBusy } = useYubiKey();
  const [name, setName] = useState<string | null>(null);

  const identifyDevice = async (device: YubiKeyDevice) => {
    await withBusy(async () => {
      const info = await Support.readInfo(device.handle);
      const deviceName = Support.getName(info);
      setName(deviceName);
      log(`Identified as ${deviceName}`);
    });
  };

  return (
    <MasterLayout>
      <ScreenHeader
        title="Support"
        description="Device identification helpers shared across transports."
      />

      <DeviceBanner />

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Identify device</Card.Title>
          <Card.Description>
            Reads DeviceInfo from any supported connection and resolves a
            human-readable name.
          </Card.Description>
        </Card.Header>
        <Card.Body>
          {name ? (
            <ListGroup variant="transparent">
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>{name}</ListGroup.ItemTitle>
                </ListGroup.ItemContent>
              </ListGroup.Item>
            </ListGroup>
          ) : null}
        </Card.Body>
        <Card.Footer>
          <Button
            size="sm"
            isDisabled={!devices.length || isBusy}
            onPress={() => {
              if (devices[0]) {
                identifyDevice(devices[0]);
              }
            }}
          >
            Identify
          </Button>
        </Card.Footer>
      </Card>

      <LogPanel />
    </MasterLayout>
  );
}
