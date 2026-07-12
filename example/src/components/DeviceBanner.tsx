import { View } from 'react-native';
import { Chip, Description, Label, Radio, RadioGroup } from 'heroui-native';
import {
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardTitle,
  Paragraph,
} from '@/components/heroui';
import { useYubiKey } from '@/context/YubiKeyContext';

function shortenHandle(handle: string) {
  if (handle.length <= 8) return handle;
  return `${handle.slice(0, 4)}...${handle.slice(-4)}`;
}

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

        <RadioGroup
          value={selectedDevice?.handle ?? ''}
          onValueChange={selectDevice}
          className="py-8"
        >
          {devices.map((device) => (
            <RadioGroup.Item
              key={device.handle}
              value={device.handle}
              className="flex-row items-center gap-2"
            >
              <Label>{device.transport.toUpperCase()}</Label>
              <Description>{shortenHandle(device.handle)}</Description>
              <Radio>
                <Radio.Indicator>
                  <Radio.IndicatorThumb />
                </Radio.Indicator>
              </Radio>
            </RadioGroup.Item>
          ))}
        </RadioGroup>
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
