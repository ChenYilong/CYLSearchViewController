import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'qmui_strings.dart';

/// The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController. The bar is the list's first item; the
/// sections Placeholder, Layout and AccessoryView drive it.
class CYLQMUISearchBarStylesPage extends StatefulWidget {
  /// Creates the screen.
  const CYLQMUISearchBarStylesPage({super.key});

  @override
  State<CYLQMUISearchBarStylesPage> createState() => _CYLQMUISearchBarStylesPageState();
}

enum _Row { centerPlaceholder, changePlaceholder, adjustField, adjustCancel, animated, toggleCancel, toggleLeading, toggleTrailing }

class _CYLQMUISearchBarStylesPageState extends State<CYLQMUISearchBarStylesPage> {
  static const List<List<_Row>> _sections = <List<_Row>>[
    <_Row>[_Row.centerPlaceholder, _Row.changePlaceholder],
    <_Row>[_Row.adjustField, _Row.adjustCancel],
    <_Row>[_Row.animated, _Row.toggleCancel, _Row.toggleLeading, _Row.toggleTrailing],
  ];
  static const List<String> _sectionKeys = <String>['styles.section.placeholder', 'styles.section.layout', 'styles.section.accessory'];

  final CYLSearchBarWidgetController _controller = CYLSearchBarWidgetController();
  bool _centers = false;
  String _placeholder = 'Search';
  bool _fieldAdjusted = false;
  bool _cancelAdjusted = false;
  bool _animated = true;
  bool _showsCancel = false;
  bool _showsLeading = false;
  bool _showsTrailing = false;
  final Color _leadingColor = _randomColor();
  final Color _trailingColor = _randomColor();

  static Color _randomColor() => <Color>[Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal][Random().nextInt(6)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// QMUI's accessory: a 30 x 30 stroked rounded square.
  Widget _accessory(Color color) => Semantics(
        label: cylDemoText('styles.accessory.label'),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(border: Border.all(color: color, width: 3), borderRadius: BorderRadius.circular(6)),
        ),
      );

  String _title(_Row row) {
    String toggle(bool shown, String nameKey) => cylDemoText(shown ? 'styles.hide' : 'styles.show', <String>[cylDemoText(nameKey)]);
    return switch (row) {
      _Row.centerPlaceholder => cylDemoText('styles.centerPlaceholder'),
      _Row.changePlaceholder => cylDemoText('styles.changePlaceholder'),
      _Row.adjustField => cylDemoText('styles.adjustField'),
      _Row.adjustCancel => cylDemoText('styles.adjustCancel'),
      _Row.animated => cylDemoText('styles.animated'),
      _Row.toggleCancel => toggle(_showsCancel, 'styles.cancel'),
      _Row.toggleLeading => toggle(_showsLeading, 'styles.leading'),
      _Row.toggleTrailing => toggle(_showsTrailing, 'styles.trailing'),
    };
  }

  void _select(_Row row) {
    setState(() {
      switch (row) {
        case _Row.changePlaceholder:
          _placeholder = cylDemoText('styles.longPlaceholder');
        case _Row.adjustField:
          _fieldAdjusted = true;
        case _Row.adjustCancel:
          _cancelAdjusted = true;
          // Starts the search so the adjusted Cancel shows.
          _showsCancel = true;
          _controller.showKeyboard();
        case _Row.toggleCancel:
          _showsCancel = !_showsCancel;
          _controller.setShowsCancelButton(_showsCancel, animated: _animated);
        case _Row.toggleLeading:
          _showsLeading = !_showsLeading;
          _controller.setShowsLeadingAccessoryView(_showsLeading, animated: _animated);
        case _Row.toggleTrailing:
          _showsTrailing = !_showsTrailing;
          _controller.setShowsTrailingAccessoryView(_showsTrailing, animated: _animated);
        case _Row.centerPlaceholder || _Row.animated:
          break;
      }
    });
  }

  Widget _row(_Row row) {
    final isSwitch = row == _Row.centerPlaceholder || row == _Row.animated;
    return ListTile(
      key: Key('CYLSearchBarStylesRow${row.index}'),
      title: Text(_title(row)),
      trailing: isSwitch
          ? Switch(
              value: row == _Row.animated ? _animated : _centers,
              onChanged: (value) => setState(() => row == _Row.animated ? _animated = value : _centers = value),
            )
          : null,
      onTap: isSwitch ? null : () => _select(row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Object>[for (var s = 0; s < _sections.length; s++) ...<Object>[s, ..._sections[s]]];
    return Scaffold(
      appBar: AppBar(title: Text(cylDemoText('demo.searchBarStyles'))),
      body: CYLSearchListView(
        searchBar: CYLSearchBarView(
          controller: _controller,
          placeholder: _placeholder,
          centersPlaceholder: _centers,
          textFieldMargins: _fieldAdjusted ? const EdgeInsets.symmetric(horizontal: 32) : EdgeInsets.zero,
          activeTextFieldMargins: EdgeInsets.zero,
          activeCancelButtonMargins: _cancelAdjusted ? const EdgeInsets.only(left: -16) : null,
          showsCancelButton: _showsCancel,
          leadingAccessoryView: _accessory(_leadingColor),
          leadingAccessoryViewMargins: const EdgeInsets.only(left: 8),
          showsLeadingAccessoryView: false,
          trailingAccessoryView: _accessory(_trailingColor),
          trailingAccessoryViewMargins: const EdgeInsets.only(right: 8),
          showsTrailingAccessoryView: false,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is int) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Semantics(header: true, child: Text(cylDemoText(_sectionKeys[item]), style: Theme.of(context).textTheme.titleSmall)),
            );
          }
          return _row(item as _Row);
        },
      ),
    );
  }
}
