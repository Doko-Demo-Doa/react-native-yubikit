# YubiKit Android SDK Integration Plan

Goal: Integrate the official Yubico YubiKit Android SDK (v3) into `react-native-yubikit`, expose all SDK features to TypeScript, and build the example Android app.

## In scope

- YubiKit Android SDK modules:
  - `core`
  - `android`
  - `fido`
  - `fido-android-ui`
  - `management`
  - `yubiotp`
  - `openpgp`
  - `oath`
  - `piv`
  - `support`

- Out of scope: `desktop` (experimental).

## Phases

### 1. Android dependency setup
- Add YubiKit Android SDK v3 artifacts to `android/build.gradle`.
- Add required logging/transitive dependencies if needed.
- Sync/verify Gradle configuration.

### 2. Native Android module structure
- Replace the placeholder `multiply` TurboModule with `YubikitModule`.
- Implement lifecycle-aware `YubiKitManager` wrapper:
  - USB discovery start/stop
  - NFC discovery start/stop
  - Device connection helpers
- Expose events for device attach/detach.

### 3. TypeScript type surface and TurboModule specs
- Create one TurboModule spec per domain:
  - `NativeYubikitCore` — discovery, lifecycle, connection helpers
  - `NativeYubikitManagement`, `NativeYubikitOath`, `NativeYubikitPiv`
  - `NativeYubikitOpenPgp`, `NativeYubikitYubiOtp`, `NativeYubikitFido`
  - `NativeYubikitSupport`
- Define shared TS types mirroring the SDK public API (device, transport, sessions, enums).
- Replace `index.tsx` exports with a structured, typed API.

### 4. Per-module native bridges
For each in-scope module, implement callable TurboModule methods that delegate to the SDK.
Because the SDK is large, the initial implementation will cover the primary public methods of each session/utility class, with a clearly extensible pattern for adding remaining methods.

### 5. TypeScript 7 upgrade attempt
- Bump `typescript` to `^7.0.0`.
- Run `pnpm typecheck` and `pnpm prepare`.
- If incompatible with `@react-native/*` tooling or builder-bob, revert to `^6.0.3`.

### 6. Example Android build
- Run `pnpm install`.
- Prebuild and build the example Android app:
  - `pnpm --filter react-native-yubikit-example exec expo prebuild --platform android`
  - `pnpm exec turbo run build:android`
- Fix any build/linking errors.

## Notes

- The example app's `android/` and `ios/` directories are gitignored (CNG/prebuild). They will be regenerated during the build step.
- All changes are tracked in this repo; the cloned Android SDK at `/Users/doko/Projects/Android/yubikit-android` is only used as a reference.
- YubiKit Android SDK is pinned to **3.1.0**, not the newer 3.2.0. 3.2.0's `android` and `fido-android-ui` artifacts require `compileSdk 37` / AGP 9.1+, which the current Expo 57 / RN 0.86 toolchain (compileSdk 36, AGP 8.12.0) doesn't support. 3.1.0 exposes the same API surface used here and builds cleanly.

## Status: Android integration complete

All eight TurboModules (Core, Management, Oath, Piv, OpenPgp, YubiOtp, Fido, Support) are implemented and verified line-by-line against the actual SDK source (constructors, method signatures, field names). The example app builds successfully end-to-end (`./gradlew assembleDebug`) and `pnpm typecheck` passes.

### 7. Example app UI (HeroUI Native)
- Added `heroui-native` + Uniwind (Tailwind v4 for RN) to the example app, with the required
  peers (`react-native-reanimated`, `react-native-gesture-handler`, `react-native-worklets`,
  `react-native-safe-area-context`, `react-native-svg`, `react-native-screens`,
  `@gorhom/bottom-sheet`).
- `example/src/global.css`, `example/metro.config.js` (`withUniwindConfig` wraps the metro
  config outermost), and `App.tsx` (`GestureHandlerRootView` → `HeroUINativeProvider` →
  `YubiKeyProvider`).
- `example/tsconfig.json` overrides `customConditions` to drop `react-native-strict-api`
  (inherited from the root tsconfig) — that condition changes which `ViewProps`/`PressableProps`
  shape `react-native` resolves to, which broke prop-checking for `heroui-native` and any other
  library not yet built against the strict-api typings. Root `tsconfig.json` now excludes
  `example`/`lib` so `pnpm typecheck` doesn't inadvertently pull in the example app under the
  wrong condition set.
- Added one demo screen per module (`example/src/screens/*Screen.tsx`) behind a lightweight
  in-app router (`example/src/routes.ts` + `App.tsx`, no `react-navigation` dependency), sharing
  discovered-device state via `example/src/context/YubiKeyContext.tsx`.
