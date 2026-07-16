import { Platform, View } from 'react-native';
import { Paragraph } from '@/components/heroui';

/**
 * Renders nothing when `platform` matches the current OS. Use this to flag
 * module functionality that's a documented YubiKit iOS SDK gap rather than a
 * bug, so tapping the button doesn't look like the library silently failing.
 */
export function PlatformNotice({
  platform,
  message,
}: {
  platform: 'android' | 'ios';
  message: string;
}) {
  if (Platform.OS === platform) return null;

  return (
    <View className="mb-4 rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2">
      <Paragraph className="text-xs text-amber-600">{message}</Paragraph>
    </View>
  );
}
