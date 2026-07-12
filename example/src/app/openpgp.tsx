import { useState } from 'react';
import { ScrollView } from 'react-native';
import { Button, Card, ListGroup } from 'heroui-native';
import { OpenPgp } from 'react-native-yubikit';
import type { Version } from 'react-native-yubikit';
import { ScreenHeader } from '@/components/ScreenHeader';
import { DeviceBanner } from '@/components/DeviceBanner';
import { LabeledInput } from '@/components/LabeledInput';
import { LogPanel } from '@/components/LogPanel';
import { useYubiKey } from '@/context/YubiKeyContext';

export default function OpenPgpScreen() {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [pin, setPin] = useState('');
  const [version, setVersion] = useState<Version | null>(null);
  const [signatureCounter, setSignatureCounter] = useState<number | null>(null);

  const verifyUserPin = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      await OpenPgp.verifyUserPin(selectedDevice.handle, pin);
      log('OpenPGP user PIN verified');
    });
  };

  const readVersion = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const result = await OpenPgp.getVersion(selectedDevice.handle);
      setVersion(result);
      log(
        `Application version ${result.major}.${result.minor}.${result.micro}`
      );
    });
  };

  const readSignatureCounter = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const counter = await OpenPgp.getSignatureCounter(selectedDevice.handle);
      setSignatureCounter(counter);
      log(`Signature counter: ${counter}`);
    });
  };

  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <ScreenHeader
        title="OpenPGP"
        description="PIN verification and application metadata."
      />

      <DeviceBanner />

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>User PIN</Card.Title>
        </Card.Header>
        <Card.Body>
          <LabeledInput
            label="PIN"
            value={pin}
            onChangeText={setPin}
            secureTextEntry
            placeholder="123456"
          />
        </Card.Body>
        <Card.Footer>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy || !pin}
            onPress={verifyUserPin}
          >
            Verify PIN
          </Button>
        </Card.Footer>
      </Card>

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Application info</Card.Title>
        </Card.Header>
        <Card.Body>
          <ListGroup variant="transparent">
            <ListGroup.Item>
              <ListGroup.ItemContent>
                <ListGroup.ItemTitle>OpenPGP version</ListGroup.ItemTitle>
                <ListGroup.ItemDescription>
                  {version
                    ? `${version.major}.${version.minor}.${version.micro}`
                    : 'unknown'}
                </ListGroup.ItemDescription>
              </ListGroup.ItemContent>
            </ListGroup.Item>
            <ListGroup.Item>
              <ListGroup.ItemContent>
                <ListGroup.ItemTitle>Signature counter</ListGroup.ItemTitle>
                <ListGroup.ItemDescription>
                  {signatureCounter ?? 'unknown'}
                </ListGroup.ItemDescription>
              </ListGroup.ItemContent>
            </ListGroup.Item>
          </ListGroup>
        </Card.Body>
        <Card.Footer className="flex-row gap-2">
          <Button
            size="sm"
            variant="secondary"
            isDisabled={!selectedDevice || isBusy}
            onPress={readVersion}
          >
            Read version
          </Button>
          <Button
            size="sm"
            variant="secondary"
            isDisabled={!selectedDevice || isBusy}
            onPress={readSignatureCounter}
          >
            Read signature counter
          </Button>
        </Card.Footer>
      </Card>

      <LogPanel />
    </ScrollView>
  );
}
