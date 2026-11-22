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

/// Merge phase 5 (docs/qmui-search-controller.md, "Merge phase 5 log: Flutter"): one implementation per concept.
void main() {
  late List<String> calls;
  late Map<int, Map<String, Object?>> parameters;
  late Map<int, Object?> lastArguments;

  setUp(() {
    calls = <String>[];
    parameters = <int, Map<String, Object?>>{};
    lastArguments = <int, Object?>{};
    var next = 1;
    final ids = <String, int>{};
    cylPlatformViewOverride = (viewType, params, onCreated) {
      // The engine creates a native view once; a rebuild of the widget finds it again.
      if (ids.containsKey(viewType)) return SizedBox.expand(key: ValueKey<String>('native $viewType'));
      final id = ids[viewType] = next++;
      parameters[id] = params;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel('cyl_search/view_$id'), (call) async {
        calls.add('$id:${call.method}');
        lastArguments[id] = call.arguments;
        if (call.method == 'history') return <String>['Helps', 'Liver'];
        return null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => onCreated(id));
      return SizedBox.expand(key: ValueKey<String>('native $viewType'));
    };
  });

  tearDown(() => cylPlatformViewOverride = null);

  group('bar accessories (iOS leadingView and trailingAccessoryViews)', () {
    testWidgets('several trailing widgets sit in order after the native field', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 52,
            child: CYLSearchBarView(
              leadingView: SizedBox(key: Key('lead'), width: 20, height: 20),
              trailingAccessoryViews: <Widget>[SizedBox(key: Key('t1'), width: 20, height: 20), SizedBox(key: Key('t2'), width: 20, height: 20)],
            ),
          ),
        ),
      ));
      await tester.pump();
      final field = tester.getRect(find.byKey(const ValueKey<String>('native cyl_search/search_bar_view')));
      expect(tester.getRect(find.byKey(const Key('lead'))).right, lessThanOrEqualTo(field.left));
      expect(tester.getRect(find.byKey(const Key('t1'))).left, greaterThanOrEqualTo(field.right));
      expect(tester.getRect(find.byKey(const Key('t2'))).left, greaterThan(tester.getRect(find.byKey(const Key('t1'))).left));
    });
  });

  group('CYLSearchView controller', () {
    testWidgets('setQuery goes to the native page, with and without submit', (tester) async {
      final controller = CYLSearchViewWidgetController();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: CYLSearchView(controller: controller))));
      await tester.pump();
      await tester.pump();
      await controller.setQuery('Fat', submit: true);
      expect(calls, contains('1:setQuery'));
      expect(lastArguments[1], <String, Object?>{'query': 'Fat', 'submit': true});
      await controller.setQuery('Liver');
      expect(lastArguments[1], <String, Object?>{'query': 'Liver', 'submit': false});
    });

    testWidgets('a text change from a tapped tag reaches onTextChanged and the query that hides the launch widget', (tester) async {
      final texts = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CYLSearchView(
            onTextChanged: texts.add,
            launchViewBuilder: (context, history) => const Text('custom launch', key: Key('launch')),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('launch')), findsOneWidget);
      // The plugin sends the query of a tapped tag as a text change before the submit.
      await nativeEvent(1, 'textDidChange', <String, Object?>{'text': 'Fat'});
      await nativeEvent(1, 'didSubmit', <String, Object?>{'text': 'Fat'});
      await tester.pump();
      expect(texts, <String>['Fat']);
      expect(find.byKey(const Key('launch')), findsNothing);
    });

    testWidgets('the history signal comes from the native store: Dart adds no event of its own', (tester) async {
      final changes = <List<String>>[];
      final controller = CYLSearchViewWidgetController();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: CYLSearchView(controller: controller, onHistoryChanged: changes.add))));
      await tester.pump();
      await tester.pump();
      await nativeEvent(1, 'historyDidChange', <String, Object?>{'history': <String>['Fat']});
      await controller.clearHistory();
      expect(calls, contains('1:clearHistory'));
      expect(changes, <List<String>>[<String>['Helps', 'Liver'], <String>['Fat']], reason: 'Dart reports the history when the page opens and what the native store sends; clearHistory sends no event of its own');
    });
  });
}
