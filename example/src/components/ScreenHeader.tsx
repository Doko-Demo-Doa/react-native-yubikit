import { View } from 'react-native';
import { Button, ButtonLabel, Heading, Paragraph } from './heroui';

export function ScreenHeader({
  title,
  description,
  onBack,
}: {
  title: string;
  description?: string;
  onBack: () => void;
}) {
  return (
    <View className="mb-4 gap-1">
      <Button variant="ghost" size="sm" className="self-start" onPress={onBack}>
        <ButtonLabel>{'←'} Back</ButtonLabel>
      </Button>
      <Heading className="text-2xl">{title}</Heading>
      {description ? (
        <Paragraph className="text-muted-foreground">{description}</Paragraph>
      ) : null}
    </View>
  );
}
