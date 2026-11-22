// The texts of the two QMUI replica screens, in the languages the iOS example has (en, ja, zh-Hans, zh-Hant): copied
// from the core's string table (Resources/CYLSearchViewController.bundle), `%s` is the iOS `%@`.
import 'dart:ui';

/// The language of the example's texts: the system language, or `--dart-define=CYL_DEMO_LANGUAGE=en|ja|zh-Hans|zh-Hant`.
String cylDemoLanguage() {
  const forced = String.fromEnvironment('CYL_DEMO_LANGUAGE');
  if (forced.isNotEmpty) return forced;
  final locale = PlatformDispatcher.instance.locale;
  if (locale.languageCode == 'ja') return 'ja';
  if (locale.languageCode == 'zh') {
    final traditional = locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK' || locale.countryCode == 'MO';
    return traditional ? 'zh-Hant' : 'zh-Hans';
  }
  return 'en';
}

const Map<String, Map<String, String>> _texts = <String, Map<String, String>>{
  'en': <String, String>{
    'demo.searchBarStyles': 'Search bar styles',
    'styles.section.placeholder': 'Placeholder',
    'styles.section.layout': 'Layout',
    'styles.section.accessory': 'Accessory view',
    'styles.centerPlaceholder': 'Center placeholder',
    'styles.changePlaceholder': 'Change placeholder',
    'styles.longPlaceholder': 'A very very very long placeholder',
    'styles.adjustField': 'Adjust the field at rest',
    'styles.adjustCancel': 'Adjust Cancel while searching',
    'styles.animated': 'Animated',
    'styles.show': 'Show %s',
    'styles.hide': 'Hide %s',
    'styles.cancel': 'Cancel',
    'styles.leading': 'leading accessory',
    'styles.trailing': 'trailing accessory',
    'styles.accessory.label': 'Accessory view',
    'styles.row.hint': 'Changes the search bar above the list',
    'demo.searchController': 'Search controller',
    'controller.noResults': 'No matching results',
  },
  'zh-Hans': <String, String>{
    'demo.searchBarStyles': '搜索栏样式',
    'styles.section.placeholder': '占位文字',
    'styles.section.layout': '布局',
    'styles.section.accessory': '附件视图',
    'styles.centerPlaceholder': '占位文字居中',
    'styles.changePlaceholder': '更换占位文字',
    'styles.longPlaceholder': '很长很长很长的占位文字',
    'styles.adjustField': '调整默认状态输入框布局',
    'styles.adjustCancel': '调整搜索状态取消按钮布局',
    'styles.animated': '以动画形式展示',
    'styles.show': '显示%s',
    'styles.hide': '隐藏%s',
    'styles.cancel': '取消按钮',
    'styles.leading': '左侧附件视图',
    'styles.trailing': '右侧附件视图',
    'styles.accessory.label': '附件视图',
    'styles.row.hint': '修改列表上方的搜索栏',
    'demo.searchController': '搜索控制器',
    'controller.noResults': '没有匹配结果',
  },
  'zh-Hant': <String, String>{
    'demo.searchBarStyles': '搜尋列樣式',
    'styles.section.placeholder': '預留位置文字',
    'styles.section.layout': '版面',
    'styles.section.accessory': '附件檢視',
    'styles.centerPlaceholder': '預留位置文字置中',
    'styles.changePlaceholder': '更換預留位置文字',
    'styles.longPlaceholder': '很長很長很長的預留位置文字',
    'styles.adjustField': '調整預設狀態輸入框版面',
    'styles.adjustCancel': '調整搜尋狀態取消按鈕版面',
    'styles.animated': '以動畫顯示',
    'styles.show': '顯示%s',
    'styles.hide': '隱藏%s',
    'styles.cancel': '取消按鈕',
    'styles.leading': '左側附件檢視',
    'styles.trailing': '右側附件檢視',
    'styles.accessory.label': '附件檢視',
    'styles.row.hint': '修改清單上方的搜尋列',
    'demo.searchController': '搜尋控制器',
    'controller.noResults': '沒有符合的結果',
  },
  'ja': <String, String>{
    'demo.searchBarStyles': '検索バーのスタイル',
    'styles.section.placeholder': 'プレースホルダー',
    'styles.section.layout': 'レイアウト',
    'styles.section.accessory': 'アクセサリビュー',
    'styles.centerPlaceholder': 'プレースホルダーを中央に',
    'styles.changePlaceholder': 'プレースホルダーを変更',
    'styles.longPlaceholder': 'とても とても とても 長いプレースホルダー',
    'styles.adjustField': '通常時の入力欄を調整',
    'styles.adjustCancel': '検索中のキャンセルを調整',
    'styles.animated': 'アニメーションで表示',
    'styles.show': '%sを表示',
    'styles.hide': '%sを非表示',
    'styles.cancel': 'キャンセルボタン',
    'styles.leading': '左のアクセサリ',
    'styles.trailing': '右のアクセサリ',
    'styles.accessory.label': 'アクセサリビュー',
    'styles.row.hint': 'リストの上の検索バーを変更します',
    'demo.searchController': '検索コントローラ',
    'controller.noResults': '一致する結果はありません',
  },
};

/// The text of `key` in the example's language; `arguments` fill the `%s` places in order.
String cylDemoText(String key, [List<String> arguments = const <String>[]]) {
  var text = _texts[cylDemoLanguage()]?[key] ?? _texts['en']![key] ?? key;
  for (final argument in arguments) {
    text = text.replaceFirst('%s', argument);
  }
  return text;
}
