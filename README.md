# @doko/react-native-yubikit

A React Native wrapper around the [YubiKit Android SDK v3](https://developers.yubico.com/yubikit-android/) and [YubiKit iOS SDK](https://developers.yubico.com/yubikit-ios/) for interacting with YubiKey devices over USB and NFC.

## Features

- USB and NFC YubiKey discovery
- Core connection handling and raw APDU transport
- Management: device info, config, USB mode, factory reset
- OATH: TOTP/HOTP credentials and code calculation
- PIV: PIN/PUK, slot metadata, certificates, key generation
- OpenPGP: PIN verification, signature counter, key management
- YubiOTP: slot configuration and HMAC-SHA1 challenge-response
- FIDO2 / WebAuthn: authenticator info, resident credentials
- Support helpers for device identification

## Platform support

This library targets both Android and iOS, but feature parity is a work in progress. The table below shows where the two platforms differ today.

| Module | Android | iOS | Notes |
|---|---|---|---|
| Core | Full | Full | Discovery, connection listing, `closeConnection`, and raw APDU transport (`sendApdu`, via `YKFSmartCardInterface`) are all wrapped on iOS. |
| Support | Full | Full | `readInfo` and `getName` are both wrapped on iOS. |
| Management | Full | Partial | `getDeviceInfo` and `updateDeviceConfig` are wrapped on iOS. `setMode` and `deviceReset` are not available in the iOS SDK. |
| OATH | Full | Full | The iOS SDK's full OATH feature set is wrapped. |
| PIV | Full | Full | The iOS SDK's full PIV feature set is wrapped, including PIN/PUK/management-key operations, slot metadata, certificates, attestation, key generation, and raw sign/decrypt. `rawSignOrDecrypt` has no explicit sign-vs-decrypt flag on iOS, so it decrypts for RSA keys in the `KEY_MANAGEMENT` slot and signs otherwise. |
| OpenPGP | Full | Not available | The YubiKit iOS SDK does not include an OpenPGP session. |
| YubiOTP | Full | Partial | `calculateHmacSha1` is wrapped on iOS. Slot configuration, NDEF, serial/version/swap, and delete/put/update are not available in the iOS SDK (it only exposes HMAC-SHA1 challenge-response). |
| FIDO2 | Full | Partial | `getInfo`, `makeCredential`, `getAssertion`, and `reset` are wrapped on iOS. `getInfo` exposes a smaller field set than Android (only `versions`, `extensions`, `aaguid`, `options`, `maxMsgSize`, `pinUvAuthProtocols`, `minPinLength` — the iOS SDK doesn't report the rest). Credential management (`getCredentialCount`, `getRpIdList`, `getCredentials`, `deleteCredential`, `updateUserInformation`) is not available in the iOS SDK. |

## Installation

```sh
npm install @doko/react-native-yubikit
```

```sh
yarn add @doko/react-native-yubikit
```

```sh
pnpm add @doko/react-native-yubikit
```

### Requirements

- React Native 0.74+ with the New Architecture enabled (Fabric / TurboModules)
- Android: minSdk 24
- iOS: partial support; see the platform support table above for per-module gaps (mainly OpenPGP, YubiOTP slot configuration, and FIDO2 credential management)

### Android permissions

Add USB permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.usb.host" />

<uses-permission android:name="android.permission.USB_PERMISSION" />
```

For NFC:

```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```

## Basic usage

Import the module namespaces you need:

```ts
import { Core, Management, Oath } from '@doko/react-native-yubikit';
```

Start USB discovery and listen for attach/detach events:

```ts
import { useEffect, useState } from 'react';
import { Core } from '@doko/react-native-yubikit';
import type { YubiKeyDevice, YubiKeyEvent } from '@doko/react-native-yubikit';

function useYubiKey() {
  const [device, setDevice] = useState<YubiKeyDevice | null>(null);

  useEffect(() => {
    Core.startUsbDiscovery({ handlePermissions: true });

    const subscription = Core.addYubiKeyListener((event: YubiKeyEvent) => {
      if (event.type === 'attached') {
        setDevice(event.device);
      } else if (event.type === 'detached') {
        setDevice((current) =>
          current?.handle === event.handle ? null : current
        );
      }
    });

    return () => {
      subscription.remove();
      Core.stopUsbDiscovery();
    };
  }, []);

  return device;
}
```

## Module examples

### Management

Read device info from a discovered YubiKey:

```ts
import { Management } from '@doko/react-native-yubikit';

const info = await Management.getDeviceInfo(deviceHandle);
console.log(info.versionName, info.formFactor, info.serialNumber);
```

### OATH

Add a TOTP credential and calculate codes:

```ts
import { Oath } from '@doko/react-native-yubikit';

await Oath.putCredential(
  deviceHandle,
  {
    accountName: 'alice@example.com',
    issuer: 'Example Corp',
    oathType: 'TOTP',
    hashAlgorithm: 'SHA1',
    secret: 'c2VjcmV0', // base64-encoded shared secret
    digits: 6,
    period: 30,
    counter: 0,
  },
  false // requireTouch
);

const { credentials } = await Oath.getCredentials(deviceHandle);
const { codes } = await Oath.calculateCodes(deviceHandle);
```

### PIV

Verify a PIN and generate a key in a slot:

```ts
import { Piv } from '@doko/react-native-yubikit';

await Piv.verifyPin(deviceHandle, '123456');

const publicKey = await Piv.generateKey(
  deviceHandle,
  'AUTHENTICATION',
  'ECCP256',
  'DEFAULT',
  'DEFAULT'
);
```

### OpenPGP

Verify the user PIN and read metadata:

```ts
import { OpenPgp } from '@doko/react-native-yubikit';

await OpenPgp.verifyUserPin(deviceHandle, '123456');
const version = await OpenPgp.getVersion(deviceHandle);
const counter = await OpenPgp.getSignatureCounter(deviceHandle);
```

### YubiOTP

Read slot configuration state and perform HMAC-SHA1 challenge-response:

```ts
import { YubiOtp } from '@doko/react-native-yubikit';

const state = await YubiOtp.getConfigurationState(deviceHandle);

const response = await YubiOtp.calculateHmacSha1(
  deviceHandle,
  'TWO',
  'Y2hhbGxlbmdl' // base64-encoded challenge
);
```

### FIDO2 / WebAuthn

Read authenticator info and list resident credentials:

```ts
import { Fido } from '@doko/react-native-yubikit';

const info = await Fido.getInfo(deviceHandle);
console.log(info.versions.join(', '));

const count = await Fido.getCredentialCount(deviceHandle, pin);
const rpIds = await Fido.getRpIdList(deviceHandle, pin);
```

### Support

Identify the connected device by name:

```ts
import { Support } from '@doko/react-native-yubikit';

const info = await Support.readInfo(deviceHandle);
const name = await Support.getName(info);
console.log(name);
```

## Example app

A runnable example app is included in the [`example/`](./example) directory. It uses [Expo Router](https://docs.expo.dev/router/introduction/) and demonstrates every supported module.

From the root of this repository:

```sh
pnpm install
pnpm example start
```

Then press `a` for Android, `i` for iOS, or `w` for web.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, build instructions, and how to send a pull request.

## License

MIT

---
