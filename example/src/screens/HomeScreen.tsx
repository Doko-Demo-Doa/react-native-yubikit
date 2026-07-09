import { ScrollView } from 'react-native';
import {
  Heading,
  ListGroup,
  ListGroupItem,
  ListGroupItemContent,
  ListGroupItemDescription,
  ListGroupItemSuffix,
  ListGroupItemTitle,
  Paragraph,
} from '../components/heroui';
import { DeviceBanner } from '../components/DeviceBanner';
import { LogPanel } from '../components/LogPanel';
import type { Route } from '../routes';

const FEATURES: Array<{ route: Route; title: string; description: string }> = [
  {
    route: 'core',
    title: 'Core & Discovery',
    description: 'USB/NFC discovery, raw APDU, connection handles',
  },
  {
    route: 'management',
    title: 'Management',
    description: 'Device info, capabilities, USB mode',
  },
  {
    route: 'oath',
    title: 'OATH',
    description: 'TOTP/HOTP credentials and codes',
  },
  {
    route: 'piv',
    title: 'PIV',
    description: 'PIN/PUK, slots, key generation',
  },
  {
    route: 'openpgp',
    title: 'OpenPGP',
    description: 'PIN verification, signature counter, keys',
  },
  {
    route: 'yubiotp',
    title: 'YubiOTP',
    description: 'Slot configuration, HMAC-SHA1 challenge-response',
  },
  {
    route: 'fido',
    title: 'FIDO2 / WebAuthn',
    description: 'Authenticator info and resident credentials',
  },
  {
    route: 'support',
    title: 'Support',
    description: 'Device identification helpers',
  },
];

export function HomeScreen({
  onNavigate,
}: {
  onNavigate: (route: Route) => void;
}) {
  return (
    <ScrollView
      className="flex-1 bg-background"
      contentContainerClassName="p-4"
    >
      <Heading className="mb-1 text-3xl">react-native-yubikit</Heading>
      <Paragraph color="muted" className="mb-4">
        Pick a module to try it against a connected YubiKey.
      </Paragraph>

      <DeviceBanner />

      <ListGroup>
        {FEATURES.map((feature) => (
          <ListGroupItem
            key={feature.route}
            onPress={() => onNavigate(feature.route)}
          >
            <ListGroupItemContent>
              <ListGroupItemTitle>{feature.title}</ListGroupItemTitle>
              <ListGroupItemDescription>
                {feature.description}
              </ListGroupItemDescription>
            </ListGroupItemContent>
            <ListGroupItemSuffix />
          </ListGroupItem>
        ))}
      </ListGroup>

      <LogPanel />
    </ScrollView>
  );
}
