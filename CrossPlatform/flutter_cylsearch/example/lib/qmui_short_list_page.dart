import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

/// The "Short list" screen (QMUI issue #1160): three rows under a search bar. The bar scrolls out of sight with a drag
/// and settles fully shown or fully hidden, although the list is shorter than the screen.
class CYLQMUIShortListPage extends StatelessWidget {
  /// Creates the screen.
  const CYLQMUIShortListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Short list')),
        body: CYLSearchListView(
          searchBar: const CYLSearchBarView(placeholder: 'Search'),
          itemCount: 3,
          itemBuilder: (context, index) => ListTile(title: Text('Row ${index + 1}')),
        ),
      );
}
