import Yubikit from './NativeYubikit';

export function multiply(a: number, b: number): number {
  return Yubikit.multiply(a, b);
}
