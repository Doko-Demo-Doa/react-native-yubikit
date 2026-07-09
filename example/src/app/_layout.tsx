import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { HeroUINativeProvider } from 'heroui-native';
import { Stack } from 'expo-router';
import { YubiKeyProvider } from '../context/YubiKeyContext';
import '../global.css';

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <HeroUINativeProvider>
        <YubiKeyProvider>
          <Stack screenOptions={{ headerShown: false }} />
        </YubiKeyProvider>
      </HeroUINativeProvider>
    </GestureHandlerRootView>
  );
}
