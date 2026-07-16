const { withDangerousMod } = require('expo/config-plugins');
const fs = require('fs');
const path = require('path');

// react-native-yubikit's PIV/FIDO2 features (slot metadata, bio metadata, key
// deletion, FIDO2 minPinLength, Management deviceReset) need YubiKit iOS 4.7.0+,
// but CocoaPods trunk only has releases up to 4.4.0. Without this override,
// `pod install` silently resolves an older YubiKit that's missing those APIs,
// and the app fails to compile with "no visible @interface ... declares the
// selector" style errors. Pull the exact tagged release from git instead.
const POD_OVERRIDE =
  "pod 'YubiKit', :git => 'https://github.com/Yubico/yubikit-ios.git', :tag => '4.7.0'";

module.exports = function withYubiKitPodfile(config) {
  return withDangerousMod(config, [
    'ios',
    (cfg) => {
      const podfilePath = path.join(
        cfg.modRequest.platformProjectRoot,
        'Podfile'
      );
      let contents = fs.readFileSync(podfilePath, 'utf-8');

      if (!contents.includes(POD_OVERRIDE)) {
        contents = contents.replace(
          /(use_expo_modules!\n)/,
          `$1\n  ${POD_OVERRIDE}\n`
        );
        fs.writeFileSync(podfilePath, contents);
      }

      return cfg;
    },
  ]);
};
