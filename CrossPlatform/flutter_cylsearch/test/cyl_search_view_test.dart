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
          <String, Object?>{'brightness': 'light', 'placeholder': 'Song', 'text': null, 'showsCancelButton': true, 'fieldShadowOpacity': 0.12});
      cylSearchBarViewDispatch(bar, const MethodCall('textDidChange', <String, Object?>{'text': 'a'}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSubmit', <String, Object?>{'text': 'a'}));
      cylSearchBarViewDispatch(bar, const MethodCall('didCancel'));
      expect(events, <String>['text a', 'submit a', 'cancel']);
    });
  });
}
