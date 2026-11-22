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
}
