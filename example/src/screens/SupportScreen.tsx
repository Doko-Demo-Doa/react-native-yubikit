import { useState } from 'react';
import { ScrollView } from 'react-native';
import { Button, Card, ListGroup } from 'heroui-native';
import { Support } from 'react-native-yubikit';
import { ScreenHeader } from '../components/ScreenHeader';
import { DeviceBanner } from '../components/DeviceBanner';
import { LogPanel } from '../components/LogPanel';
import { useYubiKey } from '../context/YubiKeyContext';
import type { Route } from '../routes';

export function SupportScreen({
  onNavigate,
}: {
  onNavigate: (route: Route) => void;
}) {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [name, setName] = useState<string | null>(null);

  const identifyDevice = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const info = await Support.readInfo(selectedDevice.handle);
      const deviceName = await Support.getName(info);
      setName(deviceName);
      log(`Identified as ${deviceName}`);
    });
  };

  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <ScreenHeader
        title="Support"
        description="Device identification helpers shared across transports."
        onBack={() => onNavigate('home')}
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
            isDisabled={!selectedDevice || isBusy}
            onPress={identifyDevice}
          >
            Identify
          </Button>
        </Card.Footer>
      </Card>

      <LogPanel />
    </ScrollView>
  );
}
