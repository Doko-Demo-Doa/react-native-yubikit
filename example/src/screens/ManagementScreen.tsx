import { useState } from 'react';
import { ScrollView } from 'react-native';
import { Management } from 'react-native-yubikit';
import type { DeviceInfo } from 'react-native-yubikit';
import {
  Button,
  Card,
  CardBody,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
  ListGroup,
  ListGroupItem,
  ListGroupItemContent,
  ListGroupItemDescription,
  ListGroupItemTitle,
} from '../components/heroui';
import { ScreenHeader } from '../components/ScreenHeader';
import { DeviceBanner } from '../components/DeviceBanner';
import { LogPanel } from '../components/LogPanel';
import { useYubiKey } from '../context/YubiKeyContext';
import type { Route } from '../routes';

export function ManagementScreen({
  onNavigate,
}: {
  onNavigate: (route: Route) => void;
}) {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [info, setInfo] = useState<DeviceInfo | null>(null);

  const readDeviceInfo = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const deviceInfo = await Management.getDeviceInfo(selectedDevice.handle);
      setInfo(deviceInfo);
      log('Read device info');
    });
  };

  const resetDevice = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      await Management.deviceReset(selectedDevice.handle);
      log('Device reset requested');
    });
  };

  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <ScreenHeader
        title="Management"
        description="Read device metadata and toggle enabled interfaces."
        onBack={() => onNavigate('home')}
      />

      <DeviceBanner />

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Device info</CardTitle>
        </CardHeader>
        <CardBody>
          {info ? (
            <ListGroup variant="transparent">
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemTitle>Firmware</ListGroupItemTitle>
                  <ListGroupItemDescription>
                    {info.versionName}
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemTitle>Form factor</ListGroupItemTitle>
                  <ListGroupItemDescription>
                    {info.formFactor}
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemTitle>Serial number</ListGroupItemTitle>
                  <ListGroupItemDescription>
                    {info.serialNumber ?? 'unavailable'}
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemTitle>Locked / FIPS</ListGroupItemTitle>
                  <ListGroupItemDescription>
                    {String(info.isLocked)} / {String(info.isFips)}
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
            </ListGroup>
          ) : null}
        </CardBody>
        <CardFooter>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={readDeviceInfo}
          >
            Read device info
          </Button>
        </CardFooter>
      </Card>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Factory reset</CardTitle>
          <CardDescription>
            Destructive: erases all applications on the YubiKey.
          </CardDescription>
        </CardHeader>
        <CardFooter>
          <Button
            variant="danger"
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={resetDevice}
          >
            Reset device
          </Button>
        </CardFooter>
      </Card>

      <LogPanel />
    </ScrollView>
  );
}
