import 'package:flutter_cylsearch_example/qmui_search_controller_page.dart';
import 'package:flutter_cylsearch_example/qmui_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the results are the matching keywords, twenty rows each, case sensitive', () {
    expect(cylQMUIResults(''), isEmpty);
    expect(cylQMUIResults('Health'), List<String>.filled(20, 'Health') + List<String>.filled(20, 'Healthy'));
    expect(cylQMUIResults('health'), isEmpty, reason: 'no match: the screen shows "No matching results"');
    expect(cylQMUIResults('Fat'), List<String>.filled(20, 'Fat'));
  });

  test('every text of the two screens exists in four languages', () {
    const keys = <String>[
      'demo.searchBarStyles', 'demo.searchController', 'styles.section.placeholder', 'styles.section.layout', 'styles.section.accessory',
      'styles.centerPlaceholder', 'styles.changePlaceholder', 'styles.longPlaceholder', 'styles.adjustField', 'styles.adjustCancel',
      'styles.animated', 'styles.show', 'styles.hide', 'styles.cancel', 'styles.leading', 'styles.trailing', 'styles.accessory.label',
      'controller.recent', 'controller.noResults', 'controller.launch.label', 'search.clearRecent',
    ];
    final english = <String, String>{for (final key in keys) key: cylDemoText(key)};
    expect(english['controller.noResults'], 'No matching results');
    expect(cylDemoText('styles.show', <String>['Cancel']), 'Show Cancel');
    for (final key in keys) {
      expect(english[key], isNot(key), reason: 'the English text of $key');
    }
  });
}
