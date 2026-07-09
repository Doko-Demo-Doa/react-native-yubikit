import { View } from 'react-native';
import { router } from 'expo-router';
import { Button, ButtonLabel, Heading, Paragraph } from './heroui';

export function ScreenHeader({
  title,
  description,
}: {
  title: string;
  description?: string;
}) {
  return (
    <View className="mb-4 gap-1">
      <Button
        variant="ghost"
        size="sm"
        className="self-start"
        onPress={() => router.back()}
      >
        <ButtonLabel>{'←'} Back</ButtonLabel>
      </Button>
      <Heading className="text-2xl">{title}</Heading>
      {description ? (
        <Paragraph className="text-muted-foreground">{description}</Paragraph>
      ) : null}
    </View>
  );
}
