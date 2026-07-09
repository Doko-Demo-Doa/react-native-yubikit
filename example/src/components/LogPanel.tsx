import { ScrollView } from 'react-native';
import { Surface } from 'heroui-native';
import { Button, Paragraph } from './heroui';
import { useYubiKey } from '../context/YubiKeyContext';

export function LogPanel() {
  const { logs, clearLogs } = useYubiKey();

  return (
    <Surface variant="secondary" className="mt-4 rounded-xl p-3">
      <Paragraph type="body-xs" color="muted" className="mb-2 uppercase">
        Activity
      </Paragraph>
      <ScrollView className="max-h-40">
        {logs.length === 0 ? (
          <Paragraph type="body-xs" color="muted">
            Nothing yet.
          </Paragraph>
        ) : (
          logs.map((entry) => (
            <Paragraph
              key={entry.id}
              type="body-xs"
              color={entry.isError ? 'default' : 'muted'}
              className={entry.isError ? 'text-danger' : undefined}
            >
              {entry.message}
            </Paragraph>
          ))
        )}
      </ScrollView>
      {logs.length > 0 ? (
        <Button
          variant="ghost"
          size="sm"
          className="mt-2 self-start"
          onPress={clearLogs}
        >
          Clear
        </Button>
      ) : null}
    </Surface>
  );
}
