import { useState } from 'react';
import { ScrollView, View } from 'react-native';
import { Oath } from 'react-native-yubikit';
import type { Credential } from 'react-native-yubikit';
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
import { LabeledInput } from '../components/LabeledInput';
import { LogPanel } from '../components/LogPanel';
import { useYubiKey } from '../context/YubiKeyContext';
import type { Route } from '../routes';

export function OathScreen({
  onNavigate,
}: {
  onNavigate: (route: Route) => void;
}) {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [password, setPassword] = useState('');
  const [accountName, setAccountName] = useState('');
  const [issuer, setIssuer] = useState('');
  const [secretBase64, setSecretBase64] = useState('');
  const [credentials, setCredentials] = useState<Credential[]>([]);
  const [codes, setCodes] = useState<Record<string, string>>({});

  const unlock = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const unlocked = await Oath.unlockWithPassword(
        selectedDevice.handle,
        password
      );
      log(unlocked ? 'OATH unlocked' : 'OATH unlock failed');
    });
  };

  const refreshCredentials = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const result = await Oath.getCredentials(selectedDevice.handle);
      setCredentials(result.credentials);
      log(`Found ${result.credentials.length} credential(s)`);
    });
  };

  const calculateAllCodes = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const result = await Oath.calculateCodes(selectedDevice.handle);
      const next: Record<string, string> = {};
      for (const entry of result.codes) {
        if (entry.code) next[entry.credential.id] = entry.code.value;
      }
      setCodes(next);
      log(`Calculated ${result.codes.length} code(s)`);
    });
  };

  const addCredential = async () => {
    if (!selectedDevice || !accountName || !secretBase64) return;
    await withBusy(async () => {
      await Oath.putCredential(
        selectedDevice.handle,
        {
          accountName,
          issuer: issuer || undefined,
          oathType: 'TOTP',
          hashAlgorithm: 'SHA1',
          secret: secretBase64,
          digits: 6,
          period: 30,
          counter: 0,
        },
        false
      );
      log(`Added credential ${accountName}`);
      setAccountName('');
      setIssuer('');
      setSecretBase64('');
      await refreshCredentials();
    });
  };

  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <ScreenHeader
        title="OATH"
        description="TOTP/HOTP credential storage and code calculation."
        onBack={() => onNavigate('home')}
      />

      <DeviceBanner />

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Unlock</CardTitle>
          <CardDescription>
            Only needed if an access password is set.
          </CardDescription>
        </CardHeader>
        <CardBody>
          <LabeledInput
            label="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            placeholder="OATH password"
          />
        </CardBody>
        <CardFooter>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy}
            onPress={unlock}
          >
            Unlock
          </Button>
        </CardFooter>
      </Card>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Credentials</CardTitle>
        </CardHeader>
        <CardBody>
          {credentials.length === 0 ? (
            <ListGroup variant="transparent">
              <ListGroupItem>
                <ListGroupItemContent>
                  <ListGroupItemDescription>
                    No credentials loaded yet.
                  </ListGroupItemDescription>
                </ListGroupItemContent>
              </ListGroupItem>
            </ListGroup>
          ) : (
            <ListGroup variant="transparent">
              {credentials.map((credential) => (
                <ListGroupItem key={credential.id}>
                  <ListGroupItemContent>
                    <ListGroupItemTitle>
                      {credential.issuer ? `${credential.issuer}: ` : ''}
                      {credential.accountName}
                    </ListGroupItemTitle>
                    <ListGroupItemDescription>
                      {codes[credential.id] ?? 'no code calculated'}
                    </ListGroupItemDescription>
                  </ListGroupItemContent>
                </ListGroupItem>
              ))}
            </ListGroup>
          )}
        </CardBody>
        <CardFooter className="flex-row gap-2">
          <Button
            size="sm"
            variant="secondary"
            isDisabled={!selectedDevice || isBusy}
            onPress={refreshCredentials}
          >
            Refresh
          </Button>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy || credentials.length === 0}
            onPress={calculateAllCodes}
          >
            Calculate codes
          </Button>
        </CardFooter>
      </Card>

      <Card className="mb-4">
        <CardHeader>
          <CardTitle>Add credential</CardTitle>
          <CardDescription>
            Secret is a base64-encoded shared key.
          </CardDescription>
        </CardHeader>
        <CardBody className="gap-3">
          <View className="flex-row gap-2">
            <LabeledInput
              label="Account"
              value={accountName}
              onChangeText={setAccountName}
              placeholder="alice@example.com"
            />
            <LabeledInput
              label="Issuer"
              value={issuer}
              onChangeText={setIssuer}
              placeholder="Example Corp"
            />
          </View>
          <LabeledInput
            label="Secret (base64)"
            value={secretBase64}
            onChangeText={setSecretBase64}
            placeholder="c2VjcmV0"
          />
        </CardBody>
        <CardFooter>
          <Button
            size="sm"
            isDisabled={
              !selectedDevice || isBusy || !accountName || !secretBase64
            }
            onPress={addCredential}
          >
            Add
          </Button>
        </CardFooter>
      </Card>

      <LogPanel />
    </ScrollView>
  );
}
