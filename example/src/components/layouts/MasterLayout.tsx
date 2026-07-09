import { ScrollView } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export function MasterLayout({ children }: { children: React.ReactNode }) {
  return (
    <SafeAreaView className="flex-1">
      <ScrollView contentContainerClassName="px-4">{children}</ScrollView>
    </SafeAreaView>
  );
}
