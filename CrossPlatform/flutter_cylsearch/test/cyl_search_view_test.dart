import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
        showsSuggestionCacheHeader: false,
      ));
      expect(parameters, <String, Object?>{
        'brightness': 'light',
        'results': null,
        'refreshEnabled': false,
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
        'showsSuggestionCacheHeader': false,
        'suggestionsFoldControlPosition': 'inline',
        'suggestionsFoldControlContent': 'icon',
        'suggestionsFoldedRowCount': 2,
        'highlightsResultMatches': false,
        'resultMatchHighlightColor': null,
        'noResultsText': null,
        'scrimColor': null,
        'supportsSwipeToDismissSearch': false,
      });
    });

    test('the native view follows the app brightness', () {
      expect(cylSearchViewParameters(const CYLSearchView(), brightness: Brightness.dark)['brightness'], 'dark');
      expect(cylSearchBarViewParameters(const CYLSearchBarView(), brightness: Brightness.dark)['brightness'], 'dark');
    });

    test('defaults match the native defaults', () {
      final parameters = cylSearchViewParameters(const CYLSearchView());
      expect(parameters['suggestionStyle'], 'tags');
      expect(
        cylSearchViewParameters(const CYLSearchView(suggestionStyle: CYLSearchSuggestionStyle.list))['suggestionStyle'],
        'list',
      );
      expect(parameters['showsEmptyResultsPlaceholder'], false);
      expect(parameters['emptyResultsScenario'], 'noSearchResults');
      expect(parameters['suggestionCachePolicy'], 'database');
      expect(parameters['suggestionCacheName'], 'CYLSearchView');
      expect(parameters['focusesSearchFieldOnShow'], true);
      expect(parameters['showsSuggestionCacheHeader'], true);
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

    test('sends the results and the refresh switch, and reports result taps and pulls', () {
      final events = <String>[];
      final view = CYLSearchView(
        results: const <String>['Swift', 'Swift UI'],
        refreshEnabled: true,
        onSelectResult: (result, index) => events.add('result $result $index'),
        onRefresh: () => events.add('refresh'),
      );
      final parameters = cylSearchViewParameters(view);
      expect(parameters['results'], <String>['Swift', 'Swift UI']);
      expect(parameters['refreshEnabled'], true);
      expect(cylSearchViewParameters(const CYLSearchView())['results'], isNull, reason: 'null keeps the suggestions only');
      cylSearchViewDispatch(view, const MethodCall('didSelectResult', <String, Object?>{'result': 'Swift UI', 'index': 1}));
      cylSearchViewDispatch(view, const MethodCall('refresh'));
      expect(events, <String>['result Swift UI 1', 'refresh']);
    });

    test('the controller calls the refresh and results methods of the native view', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = MethodChannel('cyl_search/view_test_search');
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return call.method == 'isRefreshing' ? true : null;
      });
      final controller = CYLSearchViewWidgetController();
      expect(await controller.isRefreshing(), false, reason: 'no native view yet');
      await controller.endRefreshing();
      expect(calls, isEmpty);
      controller.attach(channel);
      expect(controller.isAttached, true);
      await controller.beginRefreshing();
      expect(await controller.isRefreshing(), true);
      await controller.endRefreshing();
      await controller.reloadResults();
      expect(calls, <String>['beginRefreshing', 'isRefreshing', 'endRefreshing', 'reloadResults']);
      controller.attach(null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
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
    test('focusesOnAppear is off by default and travels in the parameters', () {
      expect(const CYLSearchBarView().focusesOnAppear, false);
      expect(cylSearchBarViewParameters(const CYLSearchBarView())['focusesOnAppear'], false);
      expect(cylSearchBarViewParameters(const CYLSearchBarView(focusesOnAppear: true))['focusesOnAppear'], true);
    });

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
            'mode': 'single',
            'searches': <String>[],
            'placeholder': 'Song',
            'text': null,
            'showsCancelButton': true,
            'fieldShadowOpacity': 0.12,
            'embedsInNavigationBar': false,
            'showsBackButton': false,
            'searchBarStyle': 'plain',
            'showsSearchIcon': true,
            'navigationFieldStyle': false,
            'focusesOnAppear': false,
            'items': <Object?>[],
            'editingBar': false,
            'actionTitle': null,
            'placeholderColor': null,
            'textColor': null,
            'fontSize': null,
            'centersPlaceholder': false,
            'textFieldMargins': <double>[0, 0, 0, 0],
            'activeTextFieldMargins': <double>[0, 0, 0, 0],
            'cancelButtonMargins': <double>[0, 0, 0, 0],
            'activeCancelButtonMargins': <double>[0, 0, 0, 0],
            'cancelButtonFontSize': null,
            'appearance': null,
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
        'animationURL': null,
        'animationLoops': false,
        'animationSpeed': 1.0,
      });
      expect((items[1]! as Map<String, Object?>)['style'], 'divider');
      expect((items[2]! as Map<String, Object?>)['accessibilityIdentifier'], 'search');
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 0, 'selected': true}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 2, 'selected': false}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectItem', <String, Object?>{'index': 9}));
      expect(events, <String>['camera true', 'selected 0 icon', 'search', 'selected 2 text']);
    });

    test('an item sends its animation file, loops and speed', () {
      final item = CYLSearchBarItem.icon(
        image: 'camera',
        title: 'Camera',
        animationURL: 'asset:///camera.json#loop',
        animationLoops: true,
        animationSpeed: 1.5,
      );
      final map = item.toMap();
      expect(map['animationURL'], 'asset:///camera.json#loop');
      expect(map['animationLoops'], true);
      expect(map['animationSpeed'], 1.5);
      expect(const CYLSearchBarItem.divider().toMap()['animationURL'], isNull);
    });

    test('multiple mode sends its searches and forwards the search events', () {
      final events = <String>[];
      final bar = CYLSearchBarView(
        mode: CYLSearchBarMode.multiple,
        searches: const <String>['Swift', 'Kotlin'],
        onTextChange: (text, index) => events.add('text $text $index'),
        onCompleteSearch: (text, index) => events.add('complete $text $index'),
        onRemoveSearch: (index) => events.add('remove $index'),
        onSelectSearch: (text, index) => events.add('select $text $index'),
        onTextChanged: (text) => events.add('single $text'),
      );
      final parameters = cylSearchBarViewParameters(bar);
      expect(parameters['mode'], 'multiple');
      expect(parameters['searches'], <String>['Swift', 'Kotlin']);
      cylSearchBarViewDispatch(bar, const MethodCall('textDidChangeAtIndex', <String, Object?>{'text': 'Da', 'index': 2}));
      cylSearchBarViewDispatch(bar, const MethodCall('didCompleteSearch', <String, Object?>{'text': 'Dart', 'index': 2}));
      cylSearchBarViewDispatch(bar, const MethodCall('didSelectSearch', <String, Object?>{'text': 'Swift', 'index': 0}));
      cylSearchBarViewDispatch(bar, const MethodCall('didRemoveSearch', <String, Object?>{'index': 1}));
      expect(events, <String>['text Da 2', 'complete Dart 2', 'select Swift 0', 'remove 1']);
    });

    test('the controller calls the multiple-search methods of the native bar', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = MethodChannel('cyl_search/view_test_bar');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'searches':
            return <Object?>['Swift', 'Dart'];
          case 'selectedSearchIndex':
            return 1;
        }
        return null;
      });
      final controller = CYLSearchBarWidgetController();
      expect(await controller.searches(), isEmpty, reason: 'no native view yet');
      expect(await controller.selectedSearchIndex(), -1);
      controller.attach(channel);
      await controller.beginNewSearch();
      await controller.completeSearch();
      await controller.addSearch('Dart');
      await controller.selectSearch(1);
      await controller.removeSearch(0);
      await controller.restartItemAnimation(2);
      expect(await controller.searches(), <String>['Swift', 'Dart']);
      expect(await controller.selectedSearchIndex(), 1);
      expect(calls.map((call) => call.method), <String>[
        'beginNewSearch', 'completeSearch', 'addSearch', 'selectSearch', 'removeSearch', 'restartItemAnimation', 'searches',
        'selectedSearchIndex',
      ]);
      expect(calls[2].arguments, <String, Object?>{'text': 'Dart'});
      expect(calls[3].arguments, <String, Object?>{'index': 1});
      expect(calls[4].arguments, <String, Object?>{'index': 0});
      expect(calls[5].arguments, <String, Object?>{'index': 2});
      controller.attach(null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    testWidgets('a controller is attached to the native view and detached on dispose', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final controller = CYLSearchBarWidgetController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: CYLSearchBarView(controller: controller, mode: CYLSearchBarMode.multiple),
      ));
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      view.onPlatformViewCreated!(7);
      expect(controller.isAttached, true);
      await tester.pumpWidget(const SizedBox());
      expect(controller.isAttached, false);
      debugDefaultTargetPlatformOverride = null;
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
          'tagSubtitles': <String>[],
          'titleMaxLines': 1,
          'tagIds': <String>[],
          'selectedIds': <String>[],
          'selectionMode': 'none',
          'sectionTitle': '',
          'columns': 0,
          'backgroundStyle': '',
          'tagImages': <String>[],
          'tagImageLabels': <String>[],
          'showsClearButton': false,
          'showsRefreshButton': false,
          'editing': false,
          'supportsRenaming': false,
        });
    expect(cylTagListViewDispatch(widget, const MethodCall('didSelectTag', <String, Object?>{'index': 1, 'title': 'Kotlin'})), isNull);
    expect(tapped, '1 Kotlin');
    expect(cylTagListViewDispatch(widget, const MethodCall('didChangeHeight', <String, Object?>{'height': 88})), 88);
  });

  test('CYLTagListView sends ids, selection and editing, and reports the editing events by id', () {
    final events = <String>[];
    final widget = CYLTagListView(
      tags: const <String>['Family', 'Friends'],
      tagIds: const <String>['t1', 't2'],
      selectedIds: const <String>['t2'],
      selectionMode: CYLTagSelectionMode.multiple,
      sectionTitle: 'Recent',
      showsClearButton: true,
      editing: true,
      supportsRenaming: true,
      onTagToggled: (index, id, selected) => events.add('toggle $index $id $selected'),
      onTagDeleted: (index, id) => events.add('delete $index $id'),
      onTagMoved: (from, to) => events.add('move $from $to'),
      onRenameRequested: (index, id, title) => events.add('rename $index $id $title'),
      onClearButtonTapped: () => events.add('clear'),
    );
    final parameters = cylTagListViewParameters(widget);
    expect(parameters['tagIds'], <String>['t1', 't2']);
    expect(parameters['selectedIds'], <String>['t2']);
    expect(parameters['selectionMode'], 'multiple');
    expect(parameters['sectionTitle'], 'Recent');
    expect(parameters['showsClearButton'], true);
    expect(parameters['editing'], true);
    expect(parameters['supportsRenaming'], true);
    cylTagListViewDispatch(widget, const MethodCall('didSelectTag', <String, Object?>{'index': 0, 'title': 'Family', 'id': 't1', 'selected': true}));
    cylTagListViewDispatch(widget, const MethodCall('didDeleteTag', <String, Object?>{'index': 1, 'id': 't2'}));
    cylTagListViewDispatch(widget, const MethodCall('didMoveTag', <String, Object?>{'from': 0, 'to': 1}));
    cylTagListViewDispatch(widget, const MethodCall('didRequestRename', <String, Object?>{'index': 0, 'id': 't1', 'title': 'Family'}));
    cylTagListViewDispatch(widget, const MethodCall('didTapClearButton', <String, Object?>{'section': 0}));
    expect(events, <String>['toggle 0 t1 true', 'delete 1 t2', 'move 0 1', 'rename 0 t1 Family', 'clear']);
  });

  test('CYLSearchBarView sends the editing bar and reports its submit', () {
    String? submitted;
    String? searched;
    final widget = CYLSearchBarView(
      editingBar: true,
      actionTitle: 'Add',
      placeholder: 'Tag name',
      onEditingSubmitted: (text) => submitted = text,
      onSubmitted: (text) => searched = text,
    );
    final parameters = cylSearchBarViewParameters(widget);
    expect(parameters['editingBar'], true);
    expect(parameters['actionTitle'], 'Add');
    cylSearchBarViewDispatch(widget, const MethodCall('didSubmitEditing', <String, Object?>{'text': 'Hiking'}));
    expect(submitted, 'Hiking');
    expect(searched, isNull);
  });

  test('CYLPlaceholderView sends its style and text', () {
    expect(cylPlaceholderViewParameters(const CYLPlaceholderView(placeholderStyle: CYLPlaceholderStyle.noResults, text: 'No matching tags'), brightness: Brightness.dark),
        <String, Object?>{'brightness': 'dark', 'placeholderStyle': 'noResults', 'text': 'No matching tags'});
    expect(CYLSearchViewTypes.placeholderView, 'cyl_search/placeholder_view');
  });
  testWidgets('the tag list platform view joins the gesture arena with a long press recognizer', (tester) async {
    // Without a recognizer the platform view gets its touches only after the arena is decided and an ancestor scroll view wins
    // every vertical drag: the native list never saw a long press. A long press (the finger still) wins the pointer for it.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: CYLTagListView(tags: <String>['Swift'])));
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.gestureRecognizers?.map((factory) => factory.type), contains(LongPressGestureRecognizer));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('CYLTagListView reports the drag state of the native list', () {
    final states = <bool>[];
    final widget = CYLTagListView(tags: const <String>['Swift'], onDraggingChanged: states.add);
    cylTagListViewDispatch(widget, const MethodCall('didChangeDragging', <String, Object?>{'dragging': true}));
    cylTagListViewDispatch(widget, const MethodCall('didChangeDragging', <String, Object?>{'dragging': false}));
    expect(states, <bool>[true, false]);
  });
}
