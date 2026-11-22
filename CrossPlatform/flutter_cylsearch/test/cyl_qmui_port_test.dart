import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sends a native event of the platform view `id` to Dart, as the plugin does.
Future<void> nativeEvent(int id, String method, [Map<String, Object?>? arguments]) async {
  const codec = StandardMethodCodec();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage('cyl_search/view_$id', codec.encodeMethodCall(MethodCall(method, arguments)), (_) {});
}

void main() {
  late List<String> calls;
  late Map<int, Map<String, Object?>> parameters;

  setUp(() {
    calls = <String>[];
    parameters = <int, Map<String, Object?>>{};
    var next = 1;
    final ids = <String, int>{};
    cylPlatformViewOverride = (viewType, params, onCreated) {
      // The engine creates a native view once; a rebuild of the widget finds it again.
      if (ids.containsKey(viewType)) return SizedBox.expand(key: ValueKey<String>('native $viewType'));
      final id = ids[viewType] = next++;
      parameters[id] = params;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('cyl_search/view_$id'), (call) async {
        calls.add('$id:${call.method}');
        if (call.method == 'history') return <String>['Helps', 'Liver'];
        return null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => onCreated(id));
      return SizedBox.expand(key: ValueKey<String>('native $viewType'));
    };
  });

  tearDown(() => cylPlatformViewOverride = null);

  group('CYLSearchBarView QMUI options', () {
    test('sends the style options and the margins of both states', () {
      final map = cylSearchBarViewParameters(const CYLSearchBarView(
        centersPlaceholder: true,
        placeholderColor: Color(0xFF112233),
        textColor: Color(0xFF445566),
        fontSize: 15,
        textFieldMargins: EdgeInsets.fromLTRB(32, 0, 32, 0),
        activeCancelButtonMargins: EdgeInsets.only(left: -16),
        cancelButtonFontSize: 13,
        appearance: CYLSearchBarAppearance(tintColor: Color(0xFF0068F8), cancelTitle: 'Done'),
      ));
      expect(map['centersPlaceholder'], true);
      expect(map['placeholderColor'], 0xFF112233);
      expect(map['textColor'], 0xFF445566);
      expect(map['fontSize'], 15);
      expect(map['textFieldMargins'], <double>[32, 0, 32, 0]);
      expect(map['activeTextFieldMargins'], <double>[32, 0, 32, 0], reason: 'null uses the margins at rest');
      expect(map['cancelButtonMargins'], <double>[0, 0, 0, 0]);
      expect(map['activeCancelButtonMargins'], <double>[-16, 0, 0, 0]);
      expect(map['cancelButtonFontSize'], 13);
      expect((map['appearance']! as Map<String, Object?>)['tintColor'], 0xFF0068F8);
      expect((map['appearance']! as Map<String, Object?>)['cancelTitle'], 'Done');
      expect(cylSearchBarViewParameters(const CYLSearchBarView())['appearance'], isNull);
    });

    testWidgets('accessory widgets sit beside the native field and follow the controller', (tester) async {
      final controller = CYLSearchBarWidgetController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 52,
            child: CYLSearchBarView(
              controller: controller,
              leadingView: const SizedBox(key: Key('leading'), width: 30, height: 30),
              leadingViewMargins: const EdgeInsets.only(left: 8),
              trailingAccessoryViews: const <Widget>[SizedBox(key: Key('trailing'), width: 30, height: 30)],
              showsTrailingAccessoryViews: false,
            ),
          ),
        ),
      ));
      await tester.pump();
      final field = find.byKey(const ValueKey<String>('native cyl_search/search_bar_view'));
      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('trailing')), findsNothing, reason: 'hidden first');
      expect(tester.getSize(field).width, 800 - 38, reason: 'the field gives up the accessory and its margin');
      controller.setShowsTrailingAccessoryViews(true, animated: false);
      await tester.pump();
      expect(find.byKey(const Key('trailing')), findsOneWidget);
      expect(tester.getSize(field).width, 800 - 38 - 30);
      // Two quick calls end in the state of the second (animated).
      controller.setShowsLeadingView(false);
      controller.setShowsLeadingView(true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('leading')), findsOneWidget);
    });

    test('Cancel is shown or hidden through the native view', () async {
      final controller = CYLSearchBarWidgetController();
      const channel = MethodChannel('cyl_search/view_cancel');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
      controller.attach(channel);
      await controller.setShowsCancelButton(true, animated: false);
      expect(calls.single.method, 'setShowsCancelButton');
      expect(calls.single.arguments, <String, Object?>{'shows': true, 'animated': false});
    });
  });

  group('CYLSearchView controller options', () {
    test('sends the highlight switch', () {
      expect(cylSearchViewParameters(const CYLSearchView(highlightsResultMatches: true))['highlightsResultMatches'], true);
      expect(cylSearchViewParameters(const CYLSearchView())['highlightsResultMatches'], false);
    });

    testWidgets('the launch view shows under the bar while the query is empty and reads the history again', (tester) async {
      List<String>? launchHistory;
      final changes = <List<String>>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CYLSearchView(
            launchViewBuilder: (context, history) {
              launchHistory = history;
              return Text('launch ${history.join(',')}', key: const Key('launch'));
            },
            onHistoryChanged: changes.add,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      await nativeEvent(1, 'didLayoutSearchBar', <String, Object?>{'bottom': 60.0});
      await tester.pump();
      expect(find.byKey(const Key('launch')), findsOneWidget);
      expect(tester.getTopLeft(find.byKey(const Key('launch'))).dy, 60, reason: 'under the bar, covering nothing of it');
      expect(launchHistory, <String>['Helps', 'Liver']);
      // A submitted query changes the history while the launch view stays on screen.
      await nativeEvent(1, 'historyDidChange', <String, Object?>{'history': <String>['Fat', 'Helps']});
      await tester.pump();
      expect(launchHistory, <String>['Fat', 'Helps']);
      // Typing takes it away; an emptied query brings it back.
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': 'h'});
      await tester.pump();
      expect(find.byKey(const Key('launch')), findsNothing);
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': ''});
      await tester.pump();
      expect(find.byKey(const Key('launch')), findsOneWidget);
      expect(changes.first, <String>['Helps', 'Liver']);
    });

    test('the scrim, the swipe, the highlight color and the empty text go to the native page', () {
      final map = cylSearchViewParameters(const CYLSearchView(
        scrimColor: Color(0x66000000),
        supportsSwipeToDismissSearch: true,
        resultMatchHighlightColor: Color(0xFFFF0000),
        noResultsText: 'No matching results',
      ));
      expect(map['scrimColor'], 0x66000000);
      expect(map['supportsSwipeToDismissSearch'], true);
      expect(map['resultMatchHighlightColor'], 0xFFFF0000);
      expect(map['noResultsText'], 'No matching results');
      final none = cylSearchViewParameters(const CYLSearchView());
      expect(none['scrimColor'], isNull);
      expect(none['supportsSwipeToDismissSearch'], false);
      expect(none['noResultsText'], isNull);
    });

    testWidgets('the callbacks follow the native events: will and did show, will close, close', (tester) async {
      final events = <String>[];
      final controller = CYLSearchViewWidgetController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CYLSearchView(
            controller: controller,
            onWillShow: () => events.add('willShow'),
            onDidShow: () => events.add('didShow'),
            onWillClose: () => events.add('willClose'),
            onClose: () => events.add('close'),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(events, <String>['willShow', 'didShow'], reason: 'the first open happens before Dart listens to the native page');
      expect(controller.isActive, true);
      await controller.setActive(false);
      expect(calls, contains('1:setActive'));
      expect(events, hasLength(2), reason: 'the will event is the native one: nothing is announced by Dart itself');
      await nativeEvent(1, 'willClose');
      await nativeEvent(1, 'didClose');
      await tester.pump();
      expect(events.skip(2).toList(), <String>['willClose', 'close']);
      expect(controller.isActive, false);
      await nativeEvent(1, 'willShow');
      await nativeEvent(1, 'didShow');
      expect(events.skip(4).toList(), <String>['willShow', 'didShow']);
      expect(controller.isActive, true);
    });

    testWidgets('no Dart overlay is built for the scrim, the empty view or the swipe', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CYLSearchView(scrimColor: const Color(0x66000000), supportsSwipeToDismissSearch: true, showsEmptyResultsPlaceholder: true, noResultsText: 'None'),
        ),
      ));
      await tester.pump();
      await tester.pump();
      await nativeEvent(1, 'didLayoutSearchBar', <String, Object?>{'bottom': 60.0});
      await tester.pump();
      expect(find.byType(CYLPlaceholderView), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });
  });

  group('CYLSearchListView', () {
    Widget list({int count = 3, bool hidesInitially = false, Widget? empty, bool hidesWhenEmpty = false, bool snaps = true, VoidCallback? onTap, ScrollController? controller}) =>
        MaterialApp(
          home: Scaffold(
            body: CYLSearchListView(
              controller: controller,
              searchBar: const ColoredBox(key: Key('bar'), color: Colors.blue),
              searchBarHeight: 50,
              itemCount: count,
              itemBuilder: (context, index) => SizedBox(height: 56, child: Text('row $index')),
              hidesSearchBarInitially: hidesInitially,
              emptyView: empty,
              hidesSearchBarWhenEmptyViewShowing: hidesWhenEmpty,
              snapsHeaderSearchBar: snaps,
              onSearchBarTap: onTap,
            ),
          ),
        );

    testWidgets('the bar is the first item and covers no row', (tester) async {
      await tester.pumpWidget(list());
      final bar = tester.getRect(find.byKey(const Key('bar')));
      final row = tester.getRect(find.text('row 0'));
      expect(bar.bottom, lessThanOrEqualTo(row.top));
    });

    testWidgets('hidesSearchBarInitially starts with the bar scrolled out', (tester) async {
      await tester.pumpWidget(list(hidesInitially: true));
      await tester.pump();
      expect(tester.getRect(find.byKey(const Key('bar'), skipOffstage: false)).bottom, lessThanOrEqualTo(0.5));
    });

    testWidgets('a short list lets the bar scroll out, and half way settles fully hidden or shown (#1160)', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(list(controller: controller));
      expect(controller.position.maxScrollExtent, greaterThanOrEqualTo(50), reason: 'three rows are shorter than the screen');
      // Drag the bar 40 px out (more than half) and release: it settles hidden.
      await tester.drag(find.text('row 0'), const Offset(0, -40));
      await tester.pumpAndSettle();
      expect(controller.offset, 50);
      // Drag it back 30 px (less than half out) and release: fully shown.
      await tester.drag(find.text('row 0'), const Offset(0, 30));
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
    });

    testWidgets('without snapping a short list cannot scroll the bar out', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(list(snaps: false, controller: controller));
      expect(controller.position.maxScrollExtent, 0);
    });

    testWidgets('an empty view replaces the rows and takes the bar away; the bar returns hidden', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(list(empty: const Text('Nothing'), hidesWhenEmpty: true, controller: controller));
      expect(find.byKey(const Key('bar')), findsNothing);
      expect(find.text('Nothing'), findsOneWidget);
      await tester.pumpWidget(list(hidesWhenEmpty: true, controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('row 0'), findsOneWidget);
      expect(controller.offset, 50, reason: 'back hidden');
    });

    testWidgets('a tap on the bar calls onSearchBarTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(list(onTap: () => taps++));
      await tester.tap(find.byKey(const Key('bar')));
      expect(taps, 1);
    });
  });
}
