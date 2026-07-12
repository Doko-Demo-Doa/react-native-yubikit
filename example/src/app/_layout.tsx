import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { HeroUINativeProvider } from 'heroui-native';
import { Stack } from 'expo-router';

import { YubiKeyProvider } from '@/context/YubiKeyContext';
import '../global.css';

export default function RootLayout() {
  return (
    <GestureHandlerRootView>
      <HeroUINativeProvider>
        <YubiKeyProvider>
          <Stack>
            <Stack.Screen name="index" options={{ title: 'Home' }} />
          </Stack>
        </YubiKeyProvider>
      </HeroUINativeProvider>
    </GestureHandlerRootView>
  );
}
