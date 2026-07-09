import { useState } from 'react';
import { ScrollView } from 'react-native';
import { Button, Card, ListGroup } from 'heroui-native';
import { YubiOtp } from 'react-native-yubikit';
import type { ConfigurationState } from 'react-native-yubikit';
import { ScreenHeader } from '../components/ScreenHeader';
import { DeviceBanner } from '../components/DeviceBanner';
import { LabeledInput } from '../components/LabeledInput';
import { LogPanel } from '../components/LogPanel';
import { useYubiKey } from '../context/YubiKeyContext';
import type { Route } from '../routes';

export function YubiOtpScreen({
  onNavigate,
}: {
  onNavigate: (route: Route) => void;
}) {
  const { selectedDevice, log, withBusy, isBusy } = useYubiKey();
  const [state, setState] = useState<ConfigurationState | null>(null);
  const [challengeBase64, setChallengeBase64] = useState('');
  const [response, setResponse] = useState<string | null>(null);

  const readConfigurationState = async () => {
    if (!selectedDevice) return;
    await withBusy(async () => {
      const result = await YubiOtp.getConfigurationState(selectedDevice.handle);
      setState(result);
      log('Read slot configuration state');
    });
  };

  const calculateChallengeResponse = async () => {
    if (!selectedDevice || !challengeBase64) return;
    await withBusy(async () => {
      const result = await YubiOtp.calculateHmacSha1(
        selectedDevice.handle,
        'TWO',
        challengeBase64
      );
      setResponse(result);
      log('Calculated HMAC-SHA1 response for slot 2');
    });
  };

  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <ScreenHeader
        title="YubiOTP"
        description="Static slot configuration and challenge-response."
        onBack={() => onNavigate('home')}
      />

      <DeviceBanner />

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Slot state</Card.Title>
        </Card.Header>
        <Card.Body>
          {state ? (
            <ListGroup variant="transparent">
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>Slot 1</ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {state.slot1Configured ? 'configured' : 'empty'}
                  </ListGroup.ItemDescription>
                </ListGroup.ItemContent>
              </ListGroup.Item>
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>Slot 2</ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {state.slot2Configured ? 'configured' : 'empty'}
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
            onPress={readConfigurationState}
          >
            Read slot state
          </Button>
        </Card.Footer>
      </Card>

      <Card className="mb-4">
        <Card.Header>
          <Card.Title>Challenge-response (slot 2)</Card.Title>
          <Card.Description>
            Requires an HMAC-SHA1 challenge-response credential in slot 2.
          </Card.Description>
        </Card.Header>
        <Card.Body className="gap-2">
          <LabeledInput
            label="Challenge (base64)"
            value={challengeBase64}
            onChangeText={setChallengeBase64}
            placeholder="Y2hhbGxlbmdl"
          />
          {response ? (
            <ListGroup variant="transparent">
              <ListGroup.Item>
                <ListGroup.ItemContent>
                  <ListGroup.ItemTitle>Response</ListGroup.ItemTitle>
                  <ListGroup.ItemDescription>
                    {response}
                  </ListGroup.ItemDescription>
                </ListGroup.ItemContent>
              </ListGroup.Item>
            </ListGroup>
          ) : null}
        </Card.Body>
        <Card.Footer>
          <Button
            size="sm"
            isDisabled={!selectedDevice || isBusy || !challengeBase64}
            onPress={calculateChallengeResponse}
          >
            Calculate response
          </Button>
        </Card.Footer>
      </Card>

      <LogPanel />
    </ScrollView>
  );
}
