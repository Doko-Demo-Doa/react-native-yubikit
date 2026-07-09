import { View } from 'react-native';
import { Chip } from 'heroui-native';
import {
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardTitle,
  Paragraph,
} from './heroui';
import { useYubiKey } from '../context/YubiKeyContext';

export function DeviceBanner() {
  const {
    devices,
    selectedDevice,
    selectDevice,
    usbActive,
    toggleUsbDiscovery,
  } = useYubiKey();

  return (
    <Card className="mb-4">
      <CardHeader className="flex-row items-center justify-between">
        <CardTitle>YubiKey</CardTitle>
        <Chip color={usbActive ? 'success' : 'default'} size="sm">
          {usbActive ? 'Scanning' : 'Idle'}
        </Chip>
      </CardHeader>
      <CardBody className="gap-2">
        {selectedDevice ? (
          <View className="gap-1">
            <Paragraph>
              Connected via {selectedDevice.transport.toUpperCase()}
            </Paragraph>
            <Paragraph type="body-xs" color="muted">
              {selectedDevice.supportedConnections.join(', ')}
            </Paragraph>
          </View>
        ) : (
          <Paragraph color="muted">
            No YubiKey connected. Start USB discovery, then plug one in.
          </Paragraph>
        )}
        {devices.length > 1 ? (
          <View className="flex-row flex-wrap gap-2">
            {devices.map((device) => (
              <Chip
                key={device.handle}
                color={
                  device.handle === selectedDevice?.handle
                    ? 'accent'
                    : 'default'
                }
                onPress={() => selectDevice(device.handle)}
              >
                {device.transport.toUpperCase()}
              </Chip>
            ))}
          </View>
        ) : null}
      </CardBody>
      <CardFooter>
        <Button
          variant={usbActive ? 'outline' : 'primary'}
          size="sm"
          onPress={toggleUsbDiscovery}
        >
          {usbActive ? 'Stop USB discovery' : 'Start USB discovery'}
        </Button>
      </CardFooter>
    </Card>
  );
}
