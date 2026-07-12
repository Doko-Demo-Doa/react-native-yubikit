import { useState } from 'react';
import { Chip } from 'heroui-native';
import { Piv } from 'react-native-yubikit';
import type { PivSlotMetadata } from 'react-native-yubikit';
import {
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardTitle,
  ListGroup,
  ListGroupItem,
  ListGroupItemContent,
  ListGroupItemDescription,
  ListGroupItemTitle,
} from '@/components/heroui';
import { ScreenHeader } from '@/components/ScreenHeader';
import { DeviceBanner } from '@/components/DeviceBanner';
import { LabeledInput } from '@/components/LabeledInput';
import { LogPanel } from '@/components/LogPanel';
import { useYubiKey } from '@/context/YubiKeyContext';
import { MasterLayout } from '@/components/layouts/MasterLayout';

const SLOTS = [
  'AUTHENTICATION',
  'SIGNATURE',
  'KEY_MANAGEMENT',
  'CARD_AUTH',
] as const;

export default function PivScreen() {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [pin, setPin] = useState('');
  const [pinAttempts, setPinAttempts] = useState<number | null>(null);
  const [slot, setSlot] = useState<(typeof SLOTS)[number]>('AUTHENTICATION');
  const [slotMetadata, setSlotMetadata] = useState<PivSlotMetadata | null>(
    null
  );

  const verifyPin = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      await Piv.verifyPin(selectedDevice.handle, pin);
      log('PIN verified');
    });
  };

  const readPinAttempts = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const attempts = await Piv.getPinAttempts(selectedDevice.handle);
      setPinAttempts(attempts);
      log(`${attempts} PIN attempt(s) remaining`);
    });
  };

  const readSlotMetadata = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const metadata = await Piv.getSlotMetadata(selectedDevice.handle, slot);
      setSlotMetadata(metadata);
      log(`Read metadata for slot ${slot}`);
    });
  };

  const generateKey = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      await Piv.generateKey(
        selectedDevice.handle,
        slot,
        'ECCP256',
        'DEFAULT',
        'DEFAULT'
      );
      log(`Generated ECCP256 key in slot ${slot}`);
      await readSlotMetadata();
    });
  };

  return (
    <MasterLayout>
      <ScreenHeader
        title="PIV"
        description="Smart-card PIN, slot metadata and key generation."
      />

      <DeviceBanner />

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>PIN</CardTitle>
        </CardHeader>
        <CardBody className="gap-2">
          <LabeledInput
            label="PIN"
            value={pin}
            onChangeText={setPin}
            secureTextEntry
            keyboardType="number-pad"
            placeholder="123456"
          />
          {pinAttempts !== null ? (
            <Chip size="sm" color={pinAttempts <= 1 ? 'danger' : 'default'}>
              {pinAttempts} attempt(s) left
            </Chip>
          ) : null}
        </CardBody>
        <CardFooter className="flex-row gap-2">
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy || !pin}
            onPress={verifyPin}
          >
            Verify PIN
          </Button>
          <Button
            size="sm"
            variant="secondary"
            isDisabled={!selectedDevice || isBusy}
            onPress={readPinAttempts}
          >
            Check attempts
          </Button>
        </CardFooter>
      </Card>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Slot</CardTitle>
        </CardHeader>
        <CardBody className="gap-3">
          <ListGroup variant="transparent">
            {SLOTS.map((candidate) => (
              <ListGroupItem key={candidate} onPress={() => setSlot(candidate)}>
                <ListGroupItemContent>
                  <ListGroupItemTitle>{candidate}</ListGroupItemTitle>
                </ListGroupItemContent>
                {candidate === slot ? <Chip size="sm">selected</Chip> : null}
              </ListGroupItem>
            ))}
          </ListGroup>

          {slotMetadata ? (
            <ListGroup variant="transparent">
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemTitle>Key type</ListGroupItemTitle>
                  <ListGroupItemDescription>
                    {slotMetadata.generated ? slotMetadata.keyType : 'empty'}
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
            </ListGroup>
          ) : null}
        </CardBody>
        <CardFooter className="flex-row gap-2">
          <Button
            size="sm"
            variant="secondary"
            isDisabled={!selectedDevice || isBusy}
            onPress={readSlotMetadata}
          >
            Read metadata
          </Button>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={generateKey}
          >
            Generate ECCP256 key
          </Button>
        </CardFooter>
      </Card>

      <LogPanel />
    </MasterLayout>
  );
}
