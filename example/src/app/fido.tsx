import { useState } from 'react';
import { Platform } from 'react-native';
import { Button, Card, ListGroup } from 'heroui-native';
import { Fido } from 'react-native-yubikit';
import type { Ctap2Info } from 'react-native-yubikit';
import { ScreenHeader } from '@/components/ScreenHeader';
import { DeviceBanner } from '@/components/DeviceBanner';
import { LabeledInput } from '@/components/LabeledInput';
import { LogPanel } from '@/components/LogPanel';
import { PlatformNotice } from '@/components/PlatformNotice';
import { useYubiKey } from '@/context/YubiKeyContext';
import { MasterLayout } from '@/components/layouts/MasterLayout';

const isCredentialManagementSupported = Platform.OS === 'android';

export default function FidoScreen() {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [info, setInfo] = useState<Ctap2Info | null>(null);
  const [pin, setPin] = useState('');
  const [credentialCount, setCredentialCount] = useState<number | null>(null);
  const [rpIds, setRpIds] = useState<string[]>([]);

  const readInfo = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const result = await Fido.getInfo(selectedDevice.handle);
      setInfo(result);
      log(`Authenticator supports ${result.versions.join(', ')}`);
    });
  };

  const readResidentCredentials = async () => {
    if (!selectedDevice || !pin) return;
    await withBusy(async () => {
      const count = await Fido.getCredentialCount(selectedDevice.handle, pin);
      const ids = await Fido.getRpIdList(selectedDevice.handle, pin);
      setCredentialCount(count);
      setRpIds(ids);
      log(`${count} resident credential(s) across ${ids.length} RP(s)`);
    });
  };

  return (
    <MasterLayout>
      <ScreenHeader
        title="FIDO2 / WebAuthn"
        description="Authenticator info and resident credential management."
      />

      <DeviceBanner />

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Authenticator info</Card.Title>
        </Card.Header>
        <Card.Body>
          {info ? (
            <ListGroup variant="transparent">
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>Versions</ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {info.versions.join(', ')}
                  </ListGroup.ItemDescription>
                </ListGroup.ItemContent>
              </ListGroup.Item>
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>Min PIN length</ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {info.minPinLength ?? 'unknown'}
                  </ListGroup.ItemDescription>
                </ListGroup.ItemContent>
              </ListGroup.Item>
            </ListGroup>
          ) : null}
        </Card.Body>
        <Card.Footer>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={readInfo}
          >
            Read info
          </Button>
        </Card.Footer>
      </Card>

      <PlatformNotice
        platform="android"
        message="FIDO2 resident-credential management is not available on iOS - the YubiKit iOS SDK doesn't expose it. Authenticator info above still works on both platforms."
      />

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Resident credentials</Card.Title>
          <Card.Description>Requires the FIDO2 PIN.</Card.Description>
        </Card.Header>
        <Card.Body className="gap-2">
          <LabeledInput
            label="PIN"
            value={pin}
            onChangeText={setPin}
            secureTextEntry
            placeholder="FIDO2 PIN"
          />
          {credentialCount !== null ? (
            <ListGroup variant="transparent">
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>
                    {credentialCount} credential(s)
                  </ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {rpIds.length > 0 ? rpIds.join(', ') : 'no relying parties'}
                  </ListGroup.ItemDescription>
                </ListGroup.ItemContent>
              </ListGroup.Item>
            </ListGroup>
          ) : null}
        </Card.Body>
        <Card.Footer>
          <Button
            size="sm"
            isDisabled={
              !selectedDevice ||
              isBusy ||
              !pin ||
              !isCredentialManagementSupported
            }
            onPress={readResidentCredentials}
          >
            List credentials
          </Button>
        </Card.Footer>
      </Card>

      <LogPanel />
    </MasterLayout>
  );
}
