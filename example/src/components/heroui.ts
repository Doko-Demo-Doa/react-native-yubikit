// TypeScript's JSX checker doesn't apply LibraryManagedAttributes correctly to
// member-expression tags (`<Card.Header>`) for these compound components, so
// every dotted sub-component is re-exported here as a plain identifier and
// imported flat (`<CardHeader>`) everywhere else in the example app.
import { Button, Card, ListGroup, Typography } from 'heroui-native';

export const CardHeader = Card.Header;
export const CardBody = Card.Body;
export const CardFooter = Card.Footer;
export const CardTitle = Card.Title;
export const CardDescription = Card.Description;

export const ListGroupItem = ListGroup.Item;
export const ListGroupItemPrefix = ListGroup.ItemPrefix;
export const ListGroupItemContent = ListGroup.ItemContent;
export const ListGroupItemTitle = ListGroup.ItemTitle;
export const ListGroupItemDescription = ListGroup.ItemDescription;
export const ListGroupItemSuffix = ListGroup.ItemSuffix;

export const ButtonLabel = Button.Label;

export const Heading = Typography.Heading;
export const Paragraph = Typography.Paragraph;

export { Button, Card, ListGroup };
