import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cylsearch_example/discover_page.dart';
import 'package:flutter_cylsearch_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the status bar icons are dark on the pale light gradient and light on the dark one', () {
    final light = cylStatusBarStyle(Brightness.light);
    expect(light.statusBarIconBrightness, Brightness.dark, reason: 'Android icons');
    expect(light.statusBarBrightness, Brightness.light, reason: 'iOS: a light page gets dark text');
    expect(light.statusBarColor, Colors.transparent);
    final dark = cylStatusBarStyle(Brightness.dark);
    expect(dark.statusBarIconBrightness, Brightness.light);
    expect(dark.statusBarBrightness, Brightness.dark);
  });

  testWidgets('the Discover page opens with Liquid Glass tag lists and a bar embedded in the navigation bar with its back button', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(home: CYLSearchDiscoverPage()));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      final params = <Map<Object?, Object?>>[
        for (final view in tester.widgetList<UiKitView>(find.byType(UiKitView))) (view.creationParams as Map<Object?, Object?>?) ?? const <Object?, Object?>{},
      ];
      final bars = params.where((p) => p['embedsInNavigationBar'] == true).toList();
      expect(bars, hasLength(1), reason: 'the native bar sits in the navigation bar from its first layout');
      expect(bars.single['showsBackButton'], true);
      final lists = params.where((p) => p.containsKey('backgroundStyle')).toList();
      expect(lists, hasLength(2), reason: 'recent searches and topics');
      expect(lists.map((p) => p['backgroundStyle']), everyElement('liquidGlass'), reason: 'glass is the default, the switch keeps flat');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
