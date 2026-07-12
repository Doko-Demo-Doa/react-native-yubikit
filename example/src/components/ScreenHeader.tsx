import { View } from 'react-native';
import { Heading, Paragraph } from '@/components/heroui';

export function ScreenHeader({
  title,
  description,
}: {
  title: string;
  description?: string;
}) {
  return (
    <View className="mb-4 gap-1">
      <Heading className="text-2xl">{title}</Heading>
      {description ? (
        <Paragraph className="text-muted-foreground">{description}</Paragraph>
      ) : null}
    </View>
  );
}
