import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CYLSearchView', () {
    test('sends every parameter with the iOS names', () {
      final parameters = cylSearchViewParameters(const CYLSearchView(
        suggestions: <String>['Android', 'Swift'],
        suggestionStyle: CYLSearchSuggestionStyle.tags,
        placeholder: 'Search',
        query: 'sw',
        showsSuggestionsForEmptyQuery: true,
        submitsOnSuggestionSelection: true,
        showsEmptyResultsPlaceholder: true,
        emptyResultsScenario: CYLPlaceholderScenario.noContent,
        suggestionCachePolicy: CYLSearchSuggestionCachePolicy.sandboxFile,
        suggestionCacheName: 'Demo',
        focusesSearchFieldOnShow: false,
      ));
      expect(parameters, <String, Object?>{
        'brightness': 'light',
        'suggestions': <String>['Android', 'Swift'],
        'suggestionStyle': 'tags',
        'placeholder': 'Search',
        'query': 'sw',
        'showsSuggestionsForEmptyQuery': true,
        'submitsOnSuggestionSelection': true,
        'showsEmptyResultsPlaceholder': true,
        'emptyResultsScenario': 'noContent',
        'suggestionCachePolicy': 'sandboxFile',
        'suggestionCacheName': 'Demo',
        'focusesSearchFieldOnShow': false,
        'suggestionsFoldControlPosition': 'inline',
        'suggestionsFoldControlContent': 'icon',
        'suggestionsFoldedRowCount': 2,
      });
    });

    test('the native view follows the app brightness', () {
      expect(cylSearchViewParameters(const CYLSearchView(), brightness: Brightness.dark)['brightness'], 'dark');
      expect(cylSearchBarViewParameters(const CYLSearchBarView(), brightness: Brightness.dark)['brightness'], 'dark');
    });

    test('defaults match the native defaults', () {
      final parameters = cylSearchViewParameters(const CYLSearchView());
      expect(parameters['suggestionStyle'], 'list');
      expect(parameters['showsEmptyResultsPlaceholder'], false);
      expect(parameters['emptyResultsScenario'], 'noSearchResults');
      expect(parameters['suggestionCachePolicy'], 'database');
      expect(parameters['suggestionCacheName'], 'CYLSearchView');
      expect(parameters['focusesSearchFieldOnShow'], true);
      expect(parameters['suggestionsFoldControlPosition'], 'inline', reason: 'the last tag is the fold chevron');
      expect(parameters['suggestionsFoldControlContent'], 'icon');
      expect(parameters['suggestionsFoldedRowCount'], 2);
    });

    test('native events reach the callbacks', () {
      final events = <String>[];
      final view = CYLSearchView(
        onTextChanged: (text) => events.add('text $text'),
        onSubmitted: (text) => events.add('submit $text'),
        onSuggestionSelected: (suggestion, index) => events.add('select $suggestion $index'),
        onClose: () => events.add('close'),
      );
      cylSearchViewDispatch(view, const MethodCall('textDidChange', <String, Object?>{'text': 'sw'}));
      cylSearchViewDispatch(view, const MethodCall('didSelectSuggestion', <String, Object?>{'suggestion': 'Swift', 'index': 1}));
      cylSearchViewDispatch(view, const MethodCall('didSubmit', <String, Object?>{'text': 'Swift'}));
      cylSearchViewDispatch(view, const MethodCall('didClose'));
      cylSearchViewDispatch(view, const MethodCall('unknown'));
      expect(events, <String>['text sw', 'select Swift 1', 'submit Swift', 'close']);
    });

    testWidgets('builds the native view of its platform', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: CYLSearchView()));
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.viewType, CYLSearchViewTypes.searchView);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: CYLSearchBarView()));
      expect(tester.widget<PlatformViewLink>(find.byType(PlatformViewLink)).viewType, CYLSearchViewTypes.searchBarView);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('CYLSearchBarView', () {
    test('sends its parameters and forwards its events', () {
      final events = <String>[];
      final bar = CYLSearchBarView(
        placeholder: 'Song',
        showsCancelButton: true,
        fieldShadowOpacity: 0.12,
        onTextChanged: (text) => events.add('text $text'),
        onSubmitted: (text) => events.add('submit $text'),
        onCancel: () => events.add('cancel'),
      );
      expect(cylSearchBarViewParameters(bar),
          <String, Object?>{
            'brightness': 'light',
            'placeholder': 'Song',
            'text': null,
            'showsCancelButton': true,
            'fieldShadowOpacity': 0.12,
            'searchBarStyle': 'plain',
            'showsSearchIcon': true,
            'items': <Object?>[],
          });
      cylSearchBarViewDispatch(bar, const MethodCall('textDidChange', <String, Object?>{'text': 'a'}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSubmit', <String, Object?>{'text': 'a'}));
      cylSearchBarViewDispatch(bar, const MethodCall('didCancel'));
      expect(events, <String>['text a', 'submit a', 'cancel']);
    });

    test('appends items like the FlatDesign tab bar and reports their taps', () {
      final events = <String>[];
      final bar = CYLSearchBarView(
        searchBarStyle: CYLSearchBarStyle.bordered,
        items: <CYLSearchBarItem>[
          CYLSearchBarItem.icon(image: 'camera', title: 'Camera', badgeValue: '', onTap: (selected) => events.add('camera $selected')),
          const CYLSearchBarItem.divider(),
          CYLSearchBarItem.text(title: 'Search', accessibilityIdentifier: 'search', onTap: (_) => events.add('search')),
        ],
        onItemSelected: (item, index) => events.add('selected $index ${item.style.name}'),
      );
      final parameters = cylSearchBarViewParameters(bar);
      expect(parameters['searchBarStyle'], 'bordered');
      final items = parameters['items']! as List<Object?>;
      expect(items.length, 3);
      expect(items[0], <String, Object?>{
        'style': 'icon',
        'title': 'Camera',
        'image': 'camera',
        'accessibilityIdentifier': null,
        'isEnabled': true,
        'isSelectable': false,
        'isSelected': false,
        'badgeValue': '',
      });
      expect((items[1]! as Map<String, Object?>)['style'], 'divider');
      expect((items[2]! as Map<String, Object?>)['accessibilityIdentifier'], 'search');
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 0, 'selected': true}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 2, 'selected': false}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 9}));
      expect(events, <String>['camera true', 'selected 0 icon', 'search', 'selected 2 text']);
    });
  });

  test('CYLTagListView sends its tags and reports taps and its height', () {
    String? tapped;
    final widget = CYLTagListView(tags: const <String>['Swift', 'Kotlin'], onTagSelected: (index, title) => tapped = '$index $title');
    expect(cylTagListViewParameters(widget, brightness: Brightness.dark),
        <String, Object?>{
          'brightness': 'dark',
          'tags': <String>['Swift', 'Kotlin'],
          'foldControlPosition': 'inline',
          'foldControlContent': 'icon',
          'foldedRowCount': 2,
        });
    expect(cylTagListViewDispatch(widget, const MethodCall('didSelectTag', <String, Object?>{'index': 1, 'title': 'Kotlin'})), isNull);
    expect(tapped, '1 Kotlin');
    expect(cylTagListViewDispatch(widget, const MethodCall('didChangeHeight', <String, Object?>{'height': 88})), 88);
  });
}
