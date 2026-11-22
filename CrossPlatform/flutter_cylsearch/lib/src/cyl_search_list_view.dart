import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';

/// A list whose first item is a search bar (iOS `CYLSearchTableViewController` with `showsSearchBar`, Android
/// `CYLSearchListView`): the bar scrolls with the rows, can start hidden, can give way to an empty view, and a bar
/// dragged half way settles fully shown or fully hidden, also above a list too short to scroll it out (QMUI issue
/// #1160, iOS `snapsHeaderSearchBar`).
///
/// Pass a [CYLSearchBarView] as [searchBar]; a tap on it calls [onSearchBarTap] (open a `CYLSearchView` route there), as
/// the bar of a list that opens the search page. The bar sits in the list, never over a row.
class CYLSearchListView extends StatefulWidget {
  /// Creates the list.
  const CYLSearchListView({
    super.key,
    required this.searchBar,
    required this.itemCount,
    required this.itemBuilder,
    this.searchBarHeight = 52,
    this.showsSearchBar = true,
    this.hidesSearchBarInitially = false,
    this.hidesSearchBarWhenEmptyViewShowing = false,
    this.emptyView,
    this.snapsHeaderSearchBar = true,
    this.onSearchBarTap,
    this.controller,
  });

  /// The bar, the list's first item; give it no height of its own, [searchBarHeight] sets it.
  final Widget searchBar;

  /// The height of the bar's row.
  final double searchBarHeight;

  /// The number of rows under the bar.
  final int itemCount;

  /// Builds a row.
  final IndexedWidgetBuilder itemBuilder;

  /// Whether the bar is the first item (iOS `showsSearchBar`); false removes it.
  final bool showsSearchBar;

  /// Scrolls the bar out of sight at first, so a pull down shows it (iOS `hidesSearchBarInitially`).
  final bool hidesSearchBarInitially;

  /// Takes the bar away while [emptyView] shows, and puts it back hidden when the empty view goes (iOS
  /// `hidesSearchBarWhenEmptyViewShowing`).
  final bool hidesSearchBarWhenEmptyViewShowing;

  /// A widget that replaces the rows, such as a placeholder (iOS `showEmptyView`); null shows the rows.
  final Widget? emptyView;

  /// Settles the bar fully shown or hidden when scrolling ends, and lets a short list scroll it out (iOS
  /// `snapsHeaderSearchBar`, issue #1160).
  final bool snapsHeaderSearchBar;

  /// The bar was tapped (Android `opensSearchViewOnTap`); the bar's own field then does not take the tap.
  final VoidCallback? onSearchBarTap;

  /// The scroll controller of the list; optional.
  final ScrollController? controller;

  @override
  State<CYLSearchListView> createState() => _CYLSearchListViewState();
}

class _CYLSearchListViewState extends State<CYLSearchListView> {
  ScrollController? _own;
  ScrollController get _controller => widget.controller ?? (_own ??= ScrollController(initialScrollOffset: _initialOffset));

  double get _initialOffset => widget.hidesSearchBarInitially ? widget.searchBarHeight : 0;

  bool get _barShown => widget.showsSearchBar && !(widget.hidesSearchBarWhenEmptyViewShowing && widget.emptyView != null);

  @override
  void didUpdateWidget(CYLSearchListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hidesSearchBarWhenEmptyViewShowing && oldWidget.emptyView != null && widget.emptyView == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(widget.searchBarHeight.clamp(0, _controller.position.maxScrollExtent).toDouble());
      });
    }
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (!widget.snapsHeaderSearchBar || !_barShown || notification.depth != 0) return false;
    final end = notification is ScrollEndNotification;
    final dragEnd = notification is UserScrollNotification && notification.direction == ScrollDirection.idle;
    if (!end && !dragEnd) return false;
    final position = notification.metrics;
    final height = widget.searchBarHeight;
    if (position.pixels <= 0 || position.pixels >= height) return false;
    final target = position.pixels > height / 2 ? height : 0.0;
    // After this frame: the settle starts when the scroll has ended.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.searchBarHeight;
    final bar = SizedBox(
      height: height,
      child: widget.onSearchBarTap == null
          ? widget.searchBar
          : Stack(children: <Widget>[
              Positioned.fill(child: widget.searchBar),
              Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onSearchBarTap)),
            ]),
    );
    return LayoutBuilder(builder: (context, constraints) {
      final empty = widget.emptyView;
      // A short list: the room below its last row makes the content one viewport plus the bar, so the bar scrolls out.
      final snapRoom = widget.snapsHeaderSearchBar && _barShown;
      return NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            if (_barShown) SliverToBoxAdapter(child: bar),
            if (empty != null)
              SliverFillRemaining(hasScrollBody: false, child: empty)
            else ...<Widget>[
              SliverList(delegate: SliverChildBuilderDelegate(widget.itemBuilder, childCount: widget.itemCount)),
              // What a short list lacks to scroll the bar out: the viewport minus the rows, the bar included.
              if (snapRoom)
                SliverLayoutBuilder(
                  builder: (context, sliver) => SliverToBoxAdapter(
                    child: SizedBox(height: (sliver.viewportMainAxisExtent + height - sliver.precedingScrollExtent).clamp(0, double.infinity).toDouble()),
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }
}
