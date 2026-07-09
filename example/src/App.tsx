import './global.css';

import { useState } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { HeroUINativeProvider } from 'heroui-native';
import { YubiKeyProvider } from './context/YubiKeyContext';
import { HomeScreen } from './screens/HomeScreen';
import { CoreScreen } from './screens/CoreScreen';
import { ManagementScreen } from './screens/ManagementScreen';
import { OathScreen } from './screens/OathScreen';
import { PivScreen } from './screens/PivScreen';
import { OpenPgpScreen } from './screens/OpenPgpScreen';
import { YubiOtpScreen } from './screens/YubiOtpScreen';
import { FidoScreen } from './screens/FidoScreen';
import { SupportScreen } from './screens/SupportScreen';
import type { Route } from './routes';

function Screens() {
  const [route, setRoute] = useState<Route>('home');

  switch (route) {
    case 'core':
      return <CoreScreen onNavigate={setRoute} />;
    case 'management':
      return <ManagementScreen onNavigate={setRoute} />;
    case 'oath':
      return <OathScreen onNavigate={setRoute} />;
    case 'piv':
      return <PivScreen onNavigate={setRoute} />;
    case 'openpgp':
      return <OpenPgpScreen onNavigate={setRoute} />;
    case 'yubiotp':
      return <YubiOtpScreen onNavigate={setRoute} />;
    case 'fido':
      return <FidoScreen onNavigate={setRoute} />;
    case 'support':
      return <SupportScreen onNavigate={setRoute} />;
    case 'home':
      return <HomeScreen onNavigate={setRoute} />;
  }
}

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <HeroUINativeProvider>
        <YubiKeyProvider>
          <Screens />
        </YubiKeyProvider>
      </HeroUINativeProvider>
    </GestureHandlerRootView>
  );
}
