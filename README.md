react-native-yubikit

A React Native TurboModule wrapper around Yubico's native [YubiKit Android](https://developers.yubico.com/yubikit-android/) and [YubiKit iOS](https://developers.yubico.com/yubikit-ios/) SDKs, for talking to YubiKey hardware over USB and NFC.

[![npm version](https://img.shields.io/npm/v/@doko/react-native-yubikit?style=for-the-badge&color=blue)](https://www.npmjs.com/package/@doko/react-native-yubikit)
[![Monthly downloads](https://img.shields.io/npm/dm/@doko/react-native-yubikit?style=for-the-badge)](https://www.npmjs.com/package/@doko/react-native-yubikit)
[![New Architecture](https://img.shields.io/badge/New%20Architecture-Only-5f3dc4?style=for-the-badge)](https://reactnative.dev/docs/the-new-architecture/landing-page)
[![TypeScript](https://img.shields.io/badge/TypeScript-Supported-3178C6?style=for-the-badge)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-2f9e44?style=for-the-badge)](LICENSE)
[![iOS](https://img.shields.io/badge/iOS-16%2B-000000?style=for-the-badge&logo=apple)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-API%2024%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com/)

📖 **Full documentation:** [doko.aniviet.com/oss/react-native-yubikey](https://doko.aniviet.com/oss/react-native-yubikey)

The docs site covers requirements, installation (including the iOS Podfile override you need), usage examples for every module, security notes, advanced patterns, and troubleshooting. This README is deliberately short - start there for anything beyond a quick look.

---

## Features

- 🔌 **USB + NFC discovery** - attach/detach events via a single `YubiKeyEvent` stream
- 🧩 **8 native modules**, exposed as namespaces: `Core`, `Support`, `Management`, `Oath`, `Piv`, `OpenPgp`, `YubiOtp`, `Fido`
- 🪝 **`YubiKeyProvider` + `useYubiKey()`** - drop-in device discovery/selection state, no boilerplate required
- 🔐 **PIV** - PIN/PUK, slot metadata, certificates, key generation, raw sign/decrypt
- 🔑 **FIDO2/WebAuthn** - authenticator info, registration, authentication
- ⏱️ **OATH** - TOTP/HOTP credential management and code calculation
- 🆕 **New Architecture only** - built as Fabric/TurboModules with Codegen, no old-bridge fallback

---

## Platform support

Android has full parity across every module. iOS is missing OpenPGP entirely, YubiOTP slot programming, and FIDO2 resident-credential management - these gaps come from the underlying YubiKit iOS SDK itself, not from this wrapper. See the [full platform support table](https://doko.aniviet.com/oss/react-native-yubikey) on the docs site for the exact per-method breakdown.

| Module         | Android | iOS                                     |
| -------------- | ------- | --------------------------------------- |
| Core / Support | Full    | Full                                    |
| Management     | Full    | Partial                                 |
| OATH           | Full    | Full                                    |
| PIV            | Full    | Full (no RSA3072/4096 raw sign/decrypt) |
| OpenPGP        | Full    | Not available                           |
| YubiOTP        | Full    | Partial (HMAC-SHA1 only)                |
| FIDO2          | Full    | Partial (no credential management)      |

---

## Requirements

|              | Minimum                                                                                                                                                        |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| React Native | 0.74+ with the **New Architecture enabled**                                                                                                                    |
| iOS          | 16.4+ recommended ([Podfile override required](https://doko.aniviet.com/oss/react-native-yubikey/installation) - the CocoaPods-trunk `YubiKit` pod is too old) |
| Android      | `minSdkVersion` 24                                                                                                                                             |

---

## Installation

```sh
npm install @doko/react-native-yubikit
# or
yarn add @doko/react-native-yubikit
# or
pnpm add @doko/react-native-yubikit
```

iOS needs a Podfile override and a few entitlements depending on which transports you use; Android needs USB/NFC manifest entries. See [Installation](https://doko.aniviet.com/oss/react-native-yubikey/installation) for the exact steps.

---

## Quick start

```tsx
import { YubiKeyProvider, useYubiKey } from '@doko/react-native-yubikit';

export default function App() {
  return (
    <YubiKeyProvider>
      <DeviceScreen />
    </YubiKeyProvider>
  );
}

function DeviceScreen() {
  const { devices, selectedDevice, startUsbDiscovery, stopUsbDiscovery } =
    useYubiKey();

  // startUsbDiscovery({ handlePermissions: true }) to begin listening,
  // then read/write against selectedDevice.handle with any module below.
}
```

```ts
import { Management, Oath, Piv } from '@doko/react-native-yubikit';

const info = await Management.getDeviceInfo(deviceHandle);
await Piv.verifyPin(deviceHandle, '123456');
const { credentials } = await Oath.getCredentials(deviceHandle);
```

More examples for every module are in [Usage Examples](https://doko.aniviet.com/oss/react-native-yubikey/usage).

---

## Example app

A runnable example app is included in [`example/`](./example) (Expo Router, demonstrates every supported module).

```sh
pnpm install
pnpm example start
```

Then press `a` for Android or `i` for iOS.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow, build instructions, and how to send a pull request.

---

## License

MIT
