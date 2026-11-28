import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';
import 'package:flutter_test/flutter_test.dart';

/// A widget changed before its native view reported its creation (the native view still has the first creation
/// parameters) sends its current parameters when the view is created. Without it the Discover tab root of the Flutter
/// example kept the empty tag it was created with: an empty glass box (docs/task-log.md, TODO (2026-11-27)).
void main() {
  late List<void Function()> pendingCreations;
  late Map<int, List<MethodCall>> calls;

  setUp(() {
    pendingCreations = <void Function()>[];
    calls = <int, List<MethodCall>>{};
    var next = 0;
    final ids = <String, int>{};
    cylPlatformViewOverride = (viewType, params, onCreated) {
      if (!ids.containsKey(viewType)) {
        final id = ids[viewType] = next++;
        calls[id] = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannel('cyl_search/view_$id'), (call) async {
          calls[id]!.add(call);
          return null;
        });
        // The native view reports its creation later, when the test says so.
        pendingCreations.add(() => onCreated(id));
      }
      return const SizedBox.expand();
    };
  });

  tearDown(() => cylPlatformViewOverride = null);

  Future<void> createNativeViews(WidgetTester tester) async {
    for (final create in pendingCreations) {
      create();
    }
    await tester.pump();
  }

  Map<Object?, Object?> lastUpdate(int id) =>
      calls[id]!.lastWhere((call) => call.method == 'update').arguments as Map<Object?, Object?>;

  testWidgets('tag list: tags set before the native view exists reach it', (tester) async {
    Widget page(String title) => MaterialApp(home: Scaffold(body: CYLTagListView(tags: <String>[title], sectionTitle: title)));
    await tester.pumpWidget(page(''));
    await tester.pumpWidget(page('Discover'));
    await createNativeViews(tester);

    expect(lastUpdate(0)['tags'], <String>['Discover']);
    expect(lastUpdate(0)['sectionTitle'], 'Discover');
  });

  testWidgets('placeholder: text set before the native view exists reaches it', (tester) async {
    Widget page(String text) => MaterialApp(home: Scaffold(body: CYLPlaceholderView(text: text)));
    await tester.pumpWidget(page(''));
    await tester.pumpWidget(page('No results'));
    await createNativeViews(tester);

    expect(lastUpdate(0)['text'], 'No results');
  });

  testWidgets('search bar: placeholder set before the native view exists reaches it', (tester) async {
    Widget page(String placeholder) => MaterialApp(home: Scaffold(body: CYLSearchBarView(placeholder: placeholder)));
    await tester.pumpWidget(page(''));
    await tester.pumpWidget(page('Search topics'));
    await createNativeViews(tester);

    expect(lastUpdate(0)['placeholder'], 'Search topics');
  });

  testWidgets('search view: placeholder set before the native view exists reaches it', (tester) async {
    Widget page(String placeholder) => MaterialApp(home: Scaffold(body: CYLSearchView(placeholder: placeholder)));
    await tester.pumpWidget(page(''));
    await tester.pumpWidget(page('Search topics'));
    await createNativeViews(tester);

    expect(lastUpdate(0)['placeholder'], 'Search topics');
  });
}
