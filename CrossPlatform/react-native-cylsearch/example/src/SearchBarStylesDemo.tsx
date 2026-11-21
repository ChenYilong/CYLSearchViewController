import { useRef, useState } from 'react';
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  useColorScheme,
  View,
} from 'react-native';
import {
  CYLSearchBarView,
  type CYLSearchBarAccessory,
  type CYLSearchBarHandle,
  type CYLEdgeInsets,
} from 'react-native-cylsearch';

const COLORS = [
  '#FF3B30',
  '#007AFF',
  '#34C759',
  '#FF9500',
  '#AF52DE',
  '#30B0C7',
];

/**
 * A 30 x 30 stroked rounded square in one of QDSearchBarViewController's colors.
 */
function accessory(index: number): CYLSearchBarAccessory {
  return {
    kind: 'square',
    size: 30,
    color: COLORS[index % COLORS.length],
    label: 'Accessory view',
  };
}

/**
 * The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController (QMUIDemo_iOS). Sections Placeholder, Layout
 * and AccessoryView drive one search bar: a centered placeholder, a changed (long) placeholder, margins of the field at
 * rest (32) and of Cancel while searching (-16), and a leading and a trailing accessory view, 30 x 30, shown and hidden
 * with or without animation, Cancel included. The options are props of `CYLSearchBarView` (Android: `CYLSearchBarView`; iOS:
 * waiting for the merge into the base class, TODO in docs/qmui-search-controller.md).
 */
export function SearchBarStylesDemo({ onClose }: { onClose: () => void }) {
  const dark = useColorScheme() === 'dark';
  const color = dark ? '#FFFFFF' : '#000000';
  const bar = useRef<CYLSearchBarHandle>(null);
  const [centered, setCentered] = useState(false);
  const [placeholder, setPlaceholder] = useState('Search');
  const [fieldMargins, setFieldMargins] = useState<CYLEdgeInsets | undefined>();
  const [cancelMargins, setCancelMargins] = useState<
    CYLEdgeInsets | undefined
  >();
  const [animated, setAnimated] = useState(true);
  const [cancel, setCancel] = useState(false);
  const [leading, setLeading] = useState(false);
  const [trailing, setTrailing] = useState(false);
  const [active, setActive] = useState(false);
  const toggle = (shown: boolean, name: string) =>
    `${shown ? 'Hide' : 'Show'} ${name}`;
  const rows: {
    title: string;
    onPress?: () => void;
    value?: boolean;
    onChange?: (value: boolean) => void;
    section?: string;
  }[] = [
    {
      section: 'Placeholder',
      title: 'Center placeholder',
      value: centered,
      onChange: setCentered,
    },
    {
      title: 'Change placeholder',
      onPress: () => setPlaceholder('A very very very long placeholder'),
    },
    {
      section: 'Layout',
      title: 'Adjust the field at rest',
      onPress: () => setFieldMargins({ left: 32, right: 32 }),
    },
    {
      title: 'Adjust Cancel while searching',
      onPress: () => {
        setCancelMargins({ left: -16 });
        // The demo starts the search so that the margins show.
        bar.current?.setActive(true);
      },
    },
    {
      section: 'AccessoryView',
      title: 'Animated',
      value: animated,
      onChange: setAnimated,
    },
    { title: toggle(cancel, 'Cancel'), onPress: () => setCancel(!cancel) },
    {
      title: toggle(leading, 'leading accessory'),
      onPress: () => setLeading(!leading),
    },
    {
      title: toggle(trailing, 'trailing accessory'),
      onPress: () => setTrailing(!trailing),
    },
  ];
  return (
    <View style={styles.fill}>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Back"
        onPress={onClose}
        style={styles.back}
      >
        <Text style={styles.backText}>Back</Text>
      </Pressable>
      {/* The bar sits above the sections in its own row: it never covers a row. */}
      <CYLSearchBarView
        ref={bar}
        style={styles.bar}
        usesDefaultAppearance
        placeholder={placeholder}
        centersPlaceholder={centered}
        showsCancelButton={cancel}
        animatesChanges={animated}
        fieldMargins={fieldMargins}
        cancelMargins={undefined}
        searchingCancelMargins={cancelMargins}
        leadingAccessory={accessory(1)}
        trailingAccessory={accessory(2)}
        showsLeadingAccessory={leading}
        showsTrailingAccessory={trailing}
        onActiveChange={(event) => setActive(event.nativeEvent.active)}
      />
      <Text accessibilityLabel="Bar state" style={styles.status}>
        {`Searching: ${active ? 'yes' : 'no'} | field ${fieldMargins ? '32' : '0'} | Cancel while searching ${cancelMargins ? '-16' : '0'}`}
      </Text>
      <ScrollView style={styles.fill} contentContainerStyle={styles.sections}>
        {rows.map((row) => (
          <View key={row.title}>
            {row.section ? (
              <Text accessibilityRole="header" style={styles.section}>
                {row.section}
              </Text>
            ) : null}
            <Pressable
              accessibilityRole={row.onChange ? 'switch' : 'button'}
              accessibilityLabel={row.title}
              disabled={!row.onPress}
              onPress={row.onPress}
              style={[
                styles.row,
                { backgroundColor: dark ? '#1C1C1E' : '#FFFFFF' },
              ]}
            >
              <Text style={[styles.rowText, { color }]}>{row.title}</Text>
              {row.onChange ? (
                <Switch
                  value={row.value}
                  onValueChange={row.onChange}
                  accessibilityLabel={row.title}
                />
              ) : null}
            </Pressable>
          </View>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  back: { alignSelf: 'flex-start', paddingHorizontal: 16, paddingVertical: 8 },
  backText: { color: '#007AFF', fontSize: 17 },
  bar: { height: 56 },
  status: {
    paddingHorizontal: 16,
    paddingVertical: 4,
    fontSize: 12,
    color: '#888888',
  },
  sections: { paddingBottom: 24 },
  section: {
    fontSize: 13,
    color: '#888888',
    paddingHorizontal: 16,
    paddingTop: 20,
    paddingBottom: 6,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    minHeight: 48,
    paddingHorizontal: 16,
  },
  rowText: { fontSize: 17, flexShrink: 1 },
});
