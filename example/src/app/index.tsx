import { ScrollView } from 'react-native';
import { router } from 'expo-router';
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

const FEATURES: Array<{
  href: `/${string}`;
  title: string;
  description: string;
}> = [
  {
    href: '/core',
    title: 'Core & Discovery',
    description: 'USB/NFC discovery, raw APDU, connection handles',
  },
  {
    href: '/management',
    title: 'Management',
    description: 'Device info, capabilities, USB mode',
  },
  {
    href: '/oath',
    title: 'OATH',
    description: 'TOTP/HOTP credentials and codes',
  },
  {
    href: '/piv',
    title: 'PIV',
    description: 'PIN/PUK, slots, key generation',
  },
  {
    href: '/openpgp',
    title: 'OpenPGP',
    description: 'PIN verification, signature counter, keys',
  },
  {
    href: '/yubiotp',
    title: 'YubiOTP',
    description: 'Slot configuration, HMAC-SHA1 challenge-response',
  },
  {
    href: '/fido',
    title: 'FIDO2 / WebAuthn',
    description: 'Authenticator info and resident credentials',
  },
  {
    href: '/support',
    title: 'Support',
    description: 'Device identification helpers',
  },
];

export default function HomeScreen() {
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
            key={feature.href}
            onPress={() => router.push(feature.href)}
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
