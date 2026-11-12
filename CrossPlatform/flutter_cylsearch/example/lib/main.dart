import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

void main() => runApp(const CYLSearchExampleApp());

/// The suggestions of MaterialSearchView's Default sample, as in the iOS and Android examples.
const List<String> cylSampleSuggestions = <String>[
  'A very very long suggestion that would span multiple lines.', 'Android', 'iOS', 'SCALA', 'Ruby', 'JavaScript',
  'C#', 'Python', 'C', 'C++', 'PHP', 'Go', 'Perl', 'Bash', 'Lua', 'R', 'TCL', 'Haskell', 'Objective C', 'Swift',
  'Kotlin', 'jQuery', 'Development', 'Web', 'Ajax', 'Test', 'Testing', 'CookBook', 'Beagle', 'VMware', 'Less.js',
  'IDE', 'Arduino', 'Xamarin', 'UI', 'Microsoft', 'Application', 'JUnit', 'SQL',
];

/// The example app of flutter_cylsearch.
class CYLSearchExampleApp extends StatelessWidget {
  /// Creates the app.
  const CYLSearchExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CYLSearch',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF007AFF), useMaterial3: true),
        home: const CYLSearchDemoPage(),
      );
}

/// The demo page: the native search bar, and buttons that open the native search page in each style.
class CYLSearchDemoPage extends StatefulWidget {
  /// Creates the page.
  const CYLSearchDemoPage({super.key});

  @override
  State<CYLSearchDemoPage> createState() => _CYLSearchDemoPageState();
}

class _CYLSearchDemoPageState extends State<CYLSearchDemoPage> {
  String _status = 'Text: ';

  void _openSearch(String title, CYLSearchSuggestionStyle style) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        // The native search page fills the route: its search bar sits where a navigation bar would.
        body: CYLSearchView(
          suggestions: cylSampleSuggestions,
          suggestionStyle: style,
          placeholder: title,
          showsEmptyResultsPlaceholder: true,
          onSubmitted: (text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Query: $text'))),
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('flutter_cylsearch')),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 52,
              child: CYLSearchBarView(
                placeholder: 'Streamer, room ID or song',
                showsCancelButton: true,
                fieldShadowOpacity: 0.12,
                onTextChanged: (text) => setState(() => _status = 'Text: $text'),
                onSubmitted: (text) => setState(() => _status = 'Searched: $text'),
                onCancel: () => setState(() => _status = 'Text: '),
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: Text(_status)),
            ListTile(
              title: const Text('Suggestions as a list'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSearch('Search', CYLSearchSuggestionStyle.list),
            ),
            ListTile(
              title: const Text('Suggestions as tags'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSearch('Search', CYLSearchSuggestionStyle.tags),
            ),
          ],
        ),
      );
}
