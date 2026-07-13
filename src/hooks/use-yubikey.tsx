import { useContext } from 'react';
import { YubiKeyContext, type YubiKeyContextValue } from './yubikey-provider';

export function useYubiKey(): YubiKeyContextValue {
  const ctx = useContext(YubiKeyContext);
  if (!ctx) {
    throw new Error('useYubiKey must be used within a <YubiKeyProvider>');
  }
  return ctx;
}
