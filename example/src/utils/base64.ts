import { fromByteArray } from 'react-native-quick-base64';

/** Random bytes, base64-encoded - good enough for demo WebAuthn challenges/user IDs. */
export function randomBase64(byteLength: number): string {
  const bytes = new Uint8Array(byteLength);
  for (let i = 0; i < byteLength; i++) {
    bytes[i] = Math.floor(Math.random() * 256);
  }
  return fromByteArray(bytes);
}
