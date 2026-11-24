import 'package:flutter/widgets.dart';
import 'package:flutter_cylsearch_example/discover_page.dart';
import 'package:flutter_cylsearch_example/example_texts.dart';
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

  testWidgets('the bundled data loads; refresh shows the next page and the hot topic moves', (tester) async {
    final data = await CYLSearchDiscoverData.load();
    expect(data.recentSearches, isNotEmpty);
    expect(data.initialTopics.length, data.discoverCount);
    expect(data.pageCount, greaterThanOrEqualTo(2));
    expect(data.discover.length % data.discoverCount, 0, reason: 'whole pages');
    expect(data.text('discover.searching', 'x'), isNot('discover.searching'));
    var page = 0;
    int? previousSlot;
    for (var refresh = 0; refresh < 2 * data.pageCount; refresh++) {
      final topics = data.topicsOnPage(page);
      final hot = <int>[for (var slot = 0; slot < topics.length; slot++) if (topics[slot].hot) slot];
      expect(hot.length, 1, reason: 'one hot topic on page $page');
      expect(hot.first, isNot(previousSlot), reason: 'the hot slot moves on every refresh');
      previousSlot = hot.first;
      page = data.nextPage(page);
    }
    expect(page, 0, reason: 'the pages are cyclic');
  });

  test('the example texts: a known English label is looked up, any other text stays as it is', () {
    // The test binding's locale is English: the text is the English one.
    expect(cylExampleText('List style'), 'List style');
    expect(cylExampleText('Not a label of the example'), 'Not a label of the example');
  });
}
