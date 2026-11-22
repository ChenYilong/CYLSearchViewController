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

    testWidgets('the dimming shows while the query is empty and a tap ends the search', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CYLSearchView(dimmingColor: const Color(0x66000000))),
      ));
      await tester.pump();
      await tester.pump();
      await nativeEvent(1, 'didLayoutSearchBar', <String, Object?>{'bottom': 60.0});
      await tester.pump();
      await tester.tapAt(const Offset(400, 300));
      expect(calls, contains('1:setActive'));
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': 'a'});
      await tester.pump();
      calls.clear();
      await tester.tapAt(const Offset(400, 300));
      expect(calls, isNot(contains('1:setActive')), reason: 'no dimming while there is a query');
    });

    testWidgets('the callbacks run in the order of the presentation life cycle, and the results also get the empty text', (tester) async {
      final events = <String>[];
      final controller = CYLSearchViewWidgetController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CYLSearchView(
            controller: controller,
            onWillPresent: () => events.add('willPresent'),
            onDidPresent: () => events.add('didPresent'),
            onWillDismiss: () => events.add('willDismiss'),
            onDidDismiss: () => events.add('didDismiss'),
            onClose: () => events.add('close'),
            onUpdateResults: (text) => events.add('update [$text]'),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(events, <String>['willPresent', 'didPresent', 'update []']);
      expect(controller.isActive, true);
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': ''});
      expect(events.last, 'update []');
      await controller.setActive(false);
      expect(calls, contains('1:setActive'));
      await nativeEvent(1, 'didClose');
      await tester.pump();
      expect(events.skip(4).toList(), <String>['willDismiss', 'didDismiss', 'close']);
      expect(controller.isActive, false);
      await nativeEvent(1, 'didShow');
      expect(controller.isActive, true);
    });

    testWidgets('showEmptyView shows only for a non empty query and leaves with the query', (tester) async {
      final controller = CYLSearchViewWidgetController();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: CYLSearchView(controller: controller))));
      await tester.pump();
      await tester.pump();
      controller.showEmptyView(text: 'No matching results');
      await tester.pump();
      expect(controller.isEmptyViewShowing, true);
      expect(find.byType(CYLPlaceholderView), findsNothing, reason: 'not while the query is empty');
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': 'zzz'});
      await tester.pump();
      expect(find.byType(CYLPlaceholderView), findsOneWidget);
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': ''});
      await tester.pump();
      expect(controller.isEmptyViewShowing, false, reason: 'an emptied query takes the placeholder away');
    });

    testWidgets('a swipe from the left edge ends the search past a quarter of the width', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CYLSearchView(supportsSwipeToDismissSearch: true, onWillDismiss: () => events.add('willDismiss'))),
      ));
      await tester.pump();
      await tester.pump();
      // A short swipe springs back.
      await tester.dragFrom(const Offset(5, 300), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(events, isEmpty);
      expect(calls, isNot(contains('1:setActive')));
      // A long swipe closes.
      await tester.dragFrom(const Offset(5, 300), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(events, <String>['willDismiss']);
      expect(calls, contains('1:setActive'));
    });

    testWidgets('without the switch the edge does nothing', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CYLSearchView())));
      await tester.pump();
      await tester.dragFrom(const Offset(5, 300), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(calls, isNot(contains('1:setActive')));
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
