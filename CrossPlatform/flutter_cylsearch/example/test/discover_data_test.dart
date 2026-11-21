import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_cylsearch_example/discover_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the language folder follows the locale as the native .lproj choice does', () {
    expect(CYLSearchDiscoverData.languageFolder(const Locale('en', 'NZ')), 'en');
    expect(CYLSearchDiscoverData.languageFolder(const Locale('ja')), 'ja');
    expect(CYLSearchDiscoverData.languageFolder(const Locale('zh', 'CN')), 'zh-Hans');
    expect(CYLSearchDiscoverData.languageFolder(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')), 'zh-Hant');
    expect(CYLSearchDiscoverData.languageFolder(const Locale('zh', 'TW')), 'zh-Hant');
    expect(CYLSearchDiscoverData.languageFolder(const Locale('fr')), 'en');
  });

  test('.strings lines parse, with %@ arguments', () {
    final strings = CYLSearchDiscoverData.parseStrings('/* c */\n"discover.searching" = "Searching: %@";\n"a" = "say \\"hi\\"";\n');
    expect(strings, <String, String>{'discover.searching': 'Searching: %@', 'a': 'say "hi"'});
  });

  testWidgets('the bundled data loads and refresh picks other topics', (tester) async {
    final data = await CYLSearchDiscoverData.load();
    expect(data.recentSearches, isNotEmpty);
    expect(data.initialTopics.length, data.discoverCount);
    expect(data.discover.any((topic) => topic.hot), isTrue);
    expect(data.text('discover.searching', 'x'), isNot('discover.searching'));
    final next = data.randomTopics(data.initialTopics, Random(1));
    expect(next.length, data.discoverCount);
    expect(next.where(data.initialTopics.contains), isEmpty);
  });
}
