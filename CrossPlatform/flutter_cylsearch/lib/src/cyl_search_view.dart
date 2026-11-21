import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Curves, Theme;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`).
enum CYLSearchSuggestionStyle {
  /// One suggestion per row with its icon.
  list,

  /// Tags that wrap like words (CollectionViewClassifyMenu's tag list).
  tags,
}

/// What a [CYLSearchBarView] holds (iOS and Android `CYLSearchBarMode`).
enum CYLSearchBarMode {
  /// One search field (the default).
  single,

  /// Several searches side by side: the new search button starts one, and a completed search becomes an entry of
  /// `searches`, with an indicator under the selected one and a remove button on it.
  multiple,
}

/// The CYLTableViewPlaceHolder scenario of the empty results placeholder (iOS `CYLPlaceholderScenario`).
enum CYLPlaceholderScenario {
  /// Nothing to show: an illustration and "Nothing here yet".
  noContent,

  /// A search found nothing: an icon, "No matching results" and a hint.
  noSearchResults,
}

/// Where the search page caches submitted queries for its suggestion list (iOS `CYLSearchSuggestionCachePolicy`).
enum CYLSearchSuggestionCachePolicy {
  /// No cache: the list shows only the suggestions.
  none,

  /// A local SQLite database (the default).
  database,

  /// `NSUserDefaults` on iOS, `SharedPreferences` on Android.
  userDefaults,

  /// A JSON file in the app's sandbox.
  sandboxFile,
}

/// Where a tag list's fold control is (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
enum CYLTagFoldControlPosition {
  /// No control: every tag shows.
  none,

  /// A chevron as the last tag (the default).
  inline,

  /// Under the tags.
  bottom,

  /// At the top trailing corner.
  topTrailing,

  /// At the top leading corner.
  topLeading,
}

/// What a tag list's fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`).
enum CYLTagFoldControlContent {
  /// An icon and a title.
  iconAndTitle,

  /// A title.
  title,

  /// An icon (the default).
  icon,
}

/// Whether taps on a tag list select tags (CollectionViewClassifyMenu's `CYLMenuSelectionMode`).
enum CYLTagSelectionMode {
  /// Taps report the tag and select nothing (the default).
  none,

  /// Taps select and deselect tags.
  multiple,
}

/// The image of a [CYLPlaceholderView] (CYLTableViewPlaceHolder's `CYLPlaceholderStyle`).
enum CYLPlaceholderStyle {
  /// An empty tray.
  empty,

  /// A magnifier with a cross.
  noResults,

  /// A person with a slash (no contacts).
  personOff,
}

/// The view types the platform side registers.
@visibleForTesting
class CYLSearchViewTypes {
  CYLSearchViewTypes._();

  /// The native search page (iOS `CYLSearchView`, Android `com.cyl.search.CYLSearchView`).
  static const String searchView = 'cyl_search/search_view';

  /// The native search bar (iOS and Android `CYLSearchBarView`).
  static const String searchBarView = 'cyl_search/search_bar_view';

  /// The native tag list (CollectionViewClassifyMenu's `CYLTagListView`, the tags of `suggestionsTagView`).
  static const String tagListView = 'cyl_search/tag_list_view';

  /// CYLTableViewPlaceHolder's `CYLPlaceholderView`.
  static const String placeholderView = 'cyl_search/placeholder_view';

  /// The channel of the platform view with `id`.
  static String channel(int id) => 'cyl_search/view_$id';
}

/// What a widget state tells its controller about changes the Dart side decides (the start of a close).
abstract interface class _CYLActiveListener {
  void willChangeActive(bool active);
}

/// Sends calls to the native view of one widget; calls made before the view exists do nothing.
abstract class _CYLPlatformViewController {
  MethodChannel? _channel;
  _CYLActiveListener? _owner;

  /// Connects the controller to the channel of its widget's native view, or disconnects it (null).
  @visibleForTesting
  void attach(MethodChannel? channel) => _channel = channel;

  /// True while a native view is connected.
  bool get isAttached => _channel != null;

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    final channel = _channel;
    if (channel == null) return null;
    return channel.invokeMethod<T>(method, arguments);
  }
}

/// Drives a [CYLSearchView] from code (iOS and Android `CYLSearchView` methods): the refresh of its results and their
/// reload. Pass it as [CYLSearchView.controller]; one controller serves one search view at a time.
class CYLSearchViewWidgetController extends _CYLPlatformViewController with ChangeNotifier {
  bool _isActive = true;
  bool _isEmptyViewShowing = false;
  String? _emptyViewText;
  String? _emptyViewDetailText;

  void _setActiveState(bool active) {
    if (_isActive == active) return;
    _isActive = active;
    notifyListeners();
  }

  /// Whether the search is active, that is open (iOS `isActive`, Android `isActive`): true from the moment the page opens
  /// until a Cancel, the back arrow or [setActive] closes it. Listen to this controller to follow it.
  bool get isActive => _isActive;

  /// Opens or closes the search from code (iOS `setActive(_:animated:)`, Android `setActive`). Closing ends with
  /// [CYLSearchView.onClose] (pop the route there); opening again shows the page as it was.
  Future<void> setActive(bool active, {bool animated = true}) async {
    _owner?.willChangeActive(active);
    await _invoke<void>('setActive', <String, Object?>{'active': active, 'animated': animated});
  }

  /// Whether [showEmptyView] has put its placeholder under the bar (iOS `isEmptyViewShowing`).
  bool get isEmptyViewShowing => _isEmptyViewShowing;

  /// Shows CYLTableViewPlaceHolder's placeholder with a title and an optional detail under the bar, over the results
  /// (iOS `showEmptyView(text:detailText:buttonTitle:buttonAction:)`). It shows only while the query is not empty (the
  /// launch view or the dimming is there then), and stays until [hideEmptyView], an emptied query or the close of the search.
  void showEmptyView({String? text, String? detailText}) {
    _isEmptyViewShowing = true;
    _emptyViewText = text;
    _emptyViewDetailText = detailText;
    notifyListeners();
  }

  /// Removes the placeholder of [showEmptyView] (iOS `hideEmptyView()`).
  void hideEmptyView() {
    if (!_isEmptyViewShowing) return;
    _isEmptyViewShowing = false;
    notifyListeners();
  }

  /// The submitted queries kept in the search page's cache, newest first (iOS `historyStore.cachedQueries()`); empty with
  /// [CYLSearchSuggestionCachePolicy.none].
  Future<List<String>> history() async =>
      (await _invoke<List<Object?>>('history'))?.whereType<String>().toList() ?? const <String>[];

  /// Clears that cache (iOS `historyStore.removeAllQueries()`); [CYLSearchView.onHistoryChanged] reports the empty list.
  Future<void> clearHistory() => _invoke<void>('clearHistory');

  /// Starts the refresh of the results, as a pull would; the native view then calls [CYLSearchView.onRefresh] (iOS and
  /// Android `beginRefreshing()`).
  Future<void> beginRefreshing() => _invoke<void>('beginRefreshing');

  /// Stops the refresh of the results (iOS and Android `endRefreshing()`). Call it on every completion path of
  /// [CYLSearchView.onRefresh].
  Future<void> endRefreshing() => _invoke<void>('endRefreshing');

  /// Whether the results refresh (iOS and Android `isRefreshing`); false before the native view exists.
  Future<bool> isRefreshing() async => await _invoke<bool>('isRefreshing') ?? false;

  /// Queries the results again for the current query and reloads their list (iOS and Android `reloadResults()`). A new
  /// [CYLSearchView.results] list reloads them already.
  Future<void> reloadResults() => _invoke<void>('reloadResults');
}

/// Drives a [CYLSearchBarView] in [CYLSearchBarMode.multiple] from code (iOS and Android `CYLSearchBarView`). Pass it as
/// [CYLSearchBarView.controller]; one controller serves one search bar at a time.
class CYLSearchBarWidgetController extends _CYLPlatformViewController with ChangeNotifier {
  bool? _showsLeadingAccessoryView;
  bool? _showsTrailingAccessoryView;
  bool _animatesAccessoryViews = false;

  /// Shows or hides Cancel, with an animation when [animated] is true (iOS `setShowsCancelButton(_:animated:)`, Android
  /// `setShowsCancelButton`). The last call decides: two quick calls end in the state of the second.
  Future<void> setShowsCancelButton(bool shows, {bool animated = true}) =>
      _invoke<void>('setShowsCancelButton', <String, Object?>{'shows': shows, 'animated': animated});

  /// Focuses the field and raises the keyboard (iOS and Android `showKeyboard()`).
  Future<void> showKeyboard() => _invoke<void>('showKeyboard');

  /// Shows or hides [CYLSearchBarView.leadingAccessoryView], with an animation when [animated] is true (iOS
  /// `setShowsLeadingAccessoryView(_:animated:)`). The last call decides.
  void setShowsLeadingAccessoryView(bool shows, {bool animated = true}) {
    _showsLeadingAccessoryView = shows;
    _animatesAccessoryViews = animated;
    notifyListeners();
  }

  /// Shows or hides [CYLSearchBarView.trailingAccessoryView], with an animation when [animated] is true (iOS
  /// `setShowsTrailingAccessoryView(_:animated:)`). The last call decides.
  void setShowsTrailingAccessoryView(bool shows, {bool animated = true}) {
    _showsTrailingAccessoryView = shows;
    _animatesAccessoryViews = animated;
    notifyListeners();
  }

  /// Starts a new search and shows the keyboard (`beginNewSearch()`).
  Future<void> beginNewSearch() => _invoke<void>('beginNewSearch');

  /// Completes the search being typed (`completeSearch()`): it becomes the selected search, or is dropped when it is
  /// too short.
  Future<void> completeSearch() => _invoke<void>('completeSearch');

  /// Adds a completed search without typing it, and selects it (`addSearch(_:)`).
  Future<void> addSearch(String text) => _invoke<void>('addSearch', <String, Object?>{'text': text});

  /// Selects a search, like a tap on it (`selectSearch(at:)`).
  Future<void> selectSearch(int index) => _invoke<void>('selectSearch', <String, Object?>{'index': index});

  /// Removes a search, like a tap on its remove button (`removeSearch(at:)`).
  Future<void> removeSearch(int index) => _invoke<void>('removeSearch', <String, Object?>{'index': index});

  /// The texts of the searches, completed searches first, then the one being typed (`searches`).
  Future<List<String>> searches() async =>
      (await _invoke<List<Object?>>('searches'))?.whereType<String>().toList() ?? const <String>[];

  /// The index of the selected search, or -1 when none is selected (`selectedSearchIndex`; iOS `NSNotFound`).
  Future<int> selectedSearchIndex() async => await _invoke<int>('selectedSearchIndex') ?? -1;
}

/// The recognizers the tag list's platform view joins the gesture arena with. A platform view without one gets its touches only
/// after the arena is decided, and an ancestor scroll view wins every vertical drag, so the native list never saw a long press.
/// With a long press recognizer, a finger that stays still for the long press time wins the pointer for the native list (its drag
/// starts, the held touches reach it) and the scroll view does not scroll with it; a swipe that began earlier scrolls as usual.
Set<Factory<OneSequenceGestureRecognizer>> _tagListGestureRecognizers() => <Factory<OneSequenceGestureRecognizer>>{
      Factory<LongPressGestureRecognizer>(LongPressGestureRecognizer.new),
    };

/// Replaces the native view of every widget of this library, so widget tests can run the Dart side (overlays, callbacks)
/// without a platform view: the builder gets the view type and the creation parameters, and calls `onCreated(id)` as
/// the engine would, after which native events reach the widget on the channel `CYLSearchViewTypes.channel(id)`.
@visibleForTesting
Widget Function(String viewType, Map<String, Object?> creationParams, void Function(int id) onCreated)? cylPlatformViewOverride;

Widget _platformView(
  String viewType,
  Map<String, Object?> creationParams,
  void Function(int id) onCreated, {
  Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
}) {
  final override = cylPlatformViewOverride;
  if (override != null) return override(viewType, creationParams, onCreated);
  const codec = StandardMessageCodec();
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: codec,
        onPlatformViewCreated: onCreated,
        gestureRecognizers: gestureRecognizers,
      );
    case TargetPlatform.android:
      // Hybrid composition: the native view is in the Android view hierarchy, so its keyboard, focus and text
      // selection behave as in a native app.
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) => AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: gestureRecognizers ?? const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        ),
        onCreatePlatformView: (params) {
          final controller = PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: codec,
            onFocus: () => params.onFocusChanged(true),
          );
          controller.addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
          controller.addOnPlatformViewCreatedListener(onCreated);
          controller.create();
          return controller;
        },
      );
    default:
      return Center(child: Text('$viewType is not available on $defaultTargetPlatform'));
  }
}

/// The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`) as a widget: its native
/// search bar at the top of the safe area, the suggestions filtered as the user types (a list or tags), and
/// CYLTableViewPlaceHolder's placeholder for a query without results. With [results] it lists your results instead of
/// the suggestions while the query is not empty, with an optional pull-to-refresh ([refreshEnabled], [onRefresh]). It
/// is open while it is shown; push it as a full screen route so its bar takes the place of the navigation bar, and pop
/// the route in [onClose].
class CYLSearchView extends StatefulWidget {
  /// Creates the search page.
  const CYLSearchView({
    super.key,
    this.controller,
    this.results,
    this.onSelectResult,
    this.refreshEnabled = false,
    this.onRefresh,
    this.suggestions = const <String>[],
    this.suggestionStyle = CYLSearchSuggestionStyle.list,
    this.placeholder,
    this.query,
    this.showsSuggestionsForEmptyQuery = false,
    this.submitsOnSuggestionSelection = false,
    this.showsEmptyResultsPlaceholder = false,
    this.emptyResultsScenario = CYLPlaceholderScenario.noSearchResults,
    this.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.database,
    this.suggestionCacheName = 'CYLSearchView',
    this.focusesSearchFieldOnShow = true,
    this.showsSuggestionCacheHeader = true,
    this.suggestionsFoldControlPosition = CYLTagFoldControlPosition.inline,
    this.suggestionsFoldControlContent = CYLTagFoldControlContent.icon,
    this.suggestionsFoldedRowCount = 2,
    this.onTextChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.onClose,
    this.launchViewBuilder,
    this.dimmingColor,
    this.supportsSwipeToDismissSearch = false,
    this.highlightsResultMatches = false,
    this.onUpdateResults,
    this.onWillPresent,
    this.onDidPresent,
    this.onWillDismiss,
    this.onDidDismiss,
    this.onHistoryChanged,
  });

  /// A widget of yours under the search bar while the query is empty (iOS `launchView`): recent searches, hot topics.
  /// It fills the space under the bar, replaces the suggestions and the cached-query list while it shows, and goes as
  /// soon as the person types. It gets the submitted queries (the history, newest first), read again after each submitted
  /// query while it stays on screen (iOS `historyDidChangeNotification`). A native view cannot hold a Flutter widget, so
  /// the page lays this one over the native view, from the bottom edge of the native bar down. Null by default.
  final Widget Function(BuildContext context, List<String> history)? launchViewBuilder;

  /// The color under the bar while the query is empty and there is no [launchViewBuilder] (iOS `dimmingColor`): the
  /// page below the bar is dimmed with it, and a tap on it ends the search. Null shows no dimming.
  final Color? dimmingColor;

  /// Lets a swipe from the left edge drag the page sideways and end the search when it passes a quarter of the width or
  /// is flicked to the right; a shorter swipe springs back (iOS `supportsSwipeToDismissSearch`). It is the page's own
  /// gesture: a route pushed with `fullscreenDialog: true` has no back swipe of its own. False by default.
  final bool supportsSwipeToDismissSearch;

  /// Colors the part of each result that matches the query in the tint color (iOS and Android: the result cell's
  /// attributed text, case sensitive as QMUI's demo). False lists plain texts.
  final bool highlightsResultMatches;

  /// The results should be updated for a query (iOS `searchResultsDelegate.updateResultsFor`): on every change of the
  /// text, also with the empty text (all text deleted, the clear button), and once with the starting query when the page
  /// opens, as UIKit does.
  final ValueChanged<String>? onUpdateResults;

  /// The search is about to open (iOS `willPresentSearchController`): when the page is built, and when
  /// [CYLSearchViewWidgetController.setActive] opens it again.
  final VoidCallback? onWillPresent;

  /// The search is open (iOS `didPresentSearchController`): the native page exists, or was opened again.
  final VoidCallback? onDidPresent;

  /// The search is about to close (iOS `willDismissSearchController`): [CYLSearchViewWidgetController.setActive] with
  /// false, or Cancel, the back arrow or a swipe.
  final VoidCallback? onWillDismiss;

  /// The search closed (iOS `didDismissSearchController`), just before [onClose].
  final VoidCallback? onDidDismiss;

  /// The submitted queries changed (iOS `historyDidChangeNotification`): after a submit and after
  /// [CYLSearchViewWidgetController.clearHistory], with the history, newest first. Also once when the page opens.
  final ValueChanged<List<String>>? onHistoryChanged;

  /// Calls the native view's refresh and results methods; optional.
  final CYLSearchViewWidgetController? controller;

  /// The results of the current query, one row each (iOS and Android `resultsDataSource`, `searchResults`). Non-null
  /// lists them in `resultsTableView` while the query is not empty, instead of the suggestions; an empty list shows the
  /// empty results placeholder when [showsEmptyResultsPlaceholder] is true. Update it as the query changes
  /// ([onTextChanged], [onSubmitted]): a new list reloads the rows. Null (the default) keeps the suggestions only.
  final List<String>? results;

  /// A result row was tapped (iOS `searchView(_:didSelectResult:)`), with the result and its index in [results].
  final void Function(String result, int index)? onSelectResult;

  /// Adds pull-to-refresh to the results list (iOS and Android `refreshHandler`, CYLTableViewPlaceHolder's normal
  /// header). A pull, or [CYLSearchViewWidgetController.beginRefreshing], calls [onRefresh].
  final bool refreshEnabled;

  /// The results list was pulled to refresh (iOS and Android `refreshHandler`). Call
  /// [CYLSearchViewWidgetController.endRefreshing] on every completion path.
  final VoidCallback? onRefresh;

  /// The suggestions to filter as the text changes (iOS `suggestions`).
  final List<String> suggestions;

  /// How the suggestions are shown (iOS `suggestionStyle`).
  final CYLSearchSuggestionStyle suggestionStyle;

  /// The search bar's placeholder (iOS `searchBarView.placeholder`).
  final String? placeholder;

  /// The query to start with (iOS `query`).
  final String? query;

  /// Lists every suggestion while the query is empty (iOS `showsSuggestionsForEmptyQuery`).
  final bool showsSuggestionsForEmptyQuery;

  /// Submits a suggestion as soon as it is tapped (iOS `submitsOnSuggestionSelection`).
  final bool submitsOnSuggestionSelection;

  /// Shows CYLTableViewPlaceHolder's placeholder while a query matches nothing (iOS `showsEmptyResultsPlaceholder`).
  final bool showsEmptyResultsPlaceholder;

  /// The scenario of that placeholder (iOS `emptyResultsScenario`).
  final CYLPlaceholderScenario emptyResultsScenario;

  /// Where submitted queries are cached (iOS `suggestionCachePolicy`): an empty query lists them, newest first, under a
  /// header whose delete button clears them. A local database by default.
  final CYLSearchSuggestionCachePolicy suggestionCachePolicy;

  /// Separates the caches of different search pages (iOS `suggestionCacheName`).
  final String suggestionCacheName;

  /// Focuses the search field when the page opens, which raises the keyboard (iOS `focusesSearchFieldOnShow`). False
  /// shows the suggestion list (or an empty placeholder) with the keyboard down until the field is tapped.
  final bool focusesSearchFieldOnShow;

  /// Shows the header above the cached queries: the title and the trash button (iOS `showsSuggestionCacheHeader`).
  /// False takes it away, for a page that clears the history with its own control.
  final bool showsSuggestionCacheHeader;

  /// Where the tag suggestions' fold control is (iOS `suggestionsFoldControl.position`): a chevron as the last tag by
  /// default.
  final CYLTagFoldControlPosition suggestionsFoldControlPosition;

  /// What that control shows (iOS `suggestionsFoldControl.content`).
  final CYLTagFoldControlContent suggestionsFoldControlContent;

  /// The rows of tag suggestions shown while folded (iOS `suggestionsFoldedRowCount`); 0 shows every row.
  final int suggestionsFoldedRowCount;

  /// The query changed (iOS `searchView(_:textDidChange:)`).
  final ValueChanged<String>? onTextChanged;

  /// The query was submitted (iOS `searchView(_:didSubmitText:)`); the page stays open.
  final ValueChanged<String>? onSubmitted;

  /// A suggestion was tapped (iOS `searchView(_:didSelectSuggestion:at:)`), with its index.
  final void Function(String suggestion, int index)? onSuggestionSelected;

  /// The back arrow or Cancel closed the search (iOS `searchViewDidClose(_:)`): pop the route here.
  final VoidCallback? onClose;

  @override
  State<CYLSearchView> createState() => _CYLSearchViewState();
}

class _CYLSearchViewState extends State<CYLSearchView> with SingleTickerProviderStateMixin implements _CYLActiveListener {
  MethodChannel? _channel;
  late String _query = widget.query ?? '';
  List<String> _history = const <String>[];
  // The bottom edge of the native bar, as the native view reports it; null until it did.
  double? _barBottom;
  bool _announcedWillDismiss = false;
  // The distance the page is dragged to the right by the swipe to dismiss, and the animation that ends it.
  double _swipeOffset = 0;
  late final AnimationController _swipeAnimation = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
    ..addListener(() => setState(() => _swipeOffset = _swipeFrom + (_swipeTo - _swipeFrom) * Curves.easeOut.transform(_swipeAnimation.value)));
  double _swipeFrom = 0;
  double _swipeTo = 0;

  Map<String, Object?> get _parameters => cylSearchViewParameters(widget, brightness: Theme.of(context).brightness);

  @override
  void initState() {
    super.initState();
    widget.controller?._owner = this;
    widget.controller?.addListener(_controllerChanged);
    widget.onWillPresent?.call();
  }

  void _controllerChanged() => setState(() {});

  @override
  void willChangeActive(bool active) {
    if (active) {
      _announcedWillDismiss = false;
      widget.onWillPresent?.call();
    } else if (!_announcedWillDismiss) {
      _announcedWillDismiss = true;
      widget.onWillDismiss?.call();
    }
  }

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    widget.controller?.attach(channel);
    setState(() => _channel = channel);
    widget.onDidPresent?.call();
    // UIKit reports the starting text (also the empty one) to the results delegate when the search starts.
    widget.onUpdateResults?.call(_query);
    channel.invokeMethod<List<Object?>>('history').then((list) {
      if (!mounted || list == null) return;
      _history = list.whereType<String>().toList();
      setState(() {});
      widget.onHistoryChanged?.call(_history);
    });
  }

  Future<Object?> _handle(MethodCall call) async {
    final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
    switch (call.method) {
      case 'textDidChange':
        setState(() => _query = arguments['text'] as String? ?? '');
        // The empty-view placeholder of the controller belongs to one query: an emptied query takes it away.
        if (_query.isEmpty) widget.controller?.hideEmptyView();
      case 'didLayoutSearchBar':
        final bottom = (arguments['bottom'] as num?)?.toDouble();
        if (bottom != null && bottom != _barBottom) setState(() => _barBottom = bottom);
      case 'didShow':
        widget.controller?._setActiveState(true);
      case 'historyDidChange':
        _history = (arguments['history'] as List<Object?>?)?.whereType<String>().toList() ?? const <String>[];
        setState(() {});
      case 'didClose':
        if (!_announcedWillDismiss) willChangeActive(false);
        widget.controller?.hideEmptyView();
        widget.controller?._setActiveState(false);
    }
    cylSearchViewDispatch(widget, call);
    return null;
  }

  @override
  void didUpdateWidget(CYLSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._owner = null;
      oldWidget.controller?.removeListener(_controllerChanged);
      oldWidget.controller?.attach(null);
      widget.controller?._owner = this;
      widget.controller?.addListener(_controllerChanged);
      widget.controller?.attach(_channel);
    }
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The app's theme changed (light / dark): the native view follows it.
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void dispose() {
    _swipeAnimation.dispose();
    widget.controller?._owner = null;
    widget.controller?.removeListener(_controllerChanged);
    widget.controller?.attach(null);
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _close() {
    willChangeActive(false);
    _channel?.invokeMethod<void>('setActive', <String, Object?>{'active': false, 'animated': true});
  }

  void _animateSwipeTo(double target, {VoidCallback? then}) {
    _swipeFrom = _swipeOffset;
    _swipeTo = target;
    _swipeAnimation.forward(from: 0).whenComplete(() => then?.call());
  }

  void _swipeEnded(double velocity, double width) {
    if (_swipeOffset > width / 4 || velocity > 700) {
      _animateSwipeTo(width, then: () {
        // The page is gone from the screen: the native close reports didClose, which ends with onClose.
        _close();
        if (mounted) setState(() => _swipeOffset = 0);
      });
    } else {
      _animateSwipeTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final active = controller?.isActive ?? true;
    final top = _barBottom ?? MediaQuery.paddingOf(context).top + 56;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final queryIsEmpty = _query.isEmpty;
    final launch = widget.launchViewBuilder;
    final dimming = widget.dimmingColor;
    final width = MediaQuery.sizeOf(context).width;
    return Transform.translate(
      offset: Offset(_swipeOffset, 0),
      child: Stack(
        children: <Widget>[
          // The native view first and always: the children after it come and go without creating it again.
          Positioned.fill(child: _platformView(CYLSearchViewTypes.searchView, _parameters, _created)),
          // The launch view or the dimming: only while the query is empty, and only under the bar.
          if (active && queryIsEmpty && launch != null)
            Positioned(left: 0, right: 0, top: top, bottom: 0, child: ColoredBox(color: scaffoldColor, child: launch(context, _history)))
          else if (active && queryIsEmpty && dimming != null)
            Positioned(
              left: 0,
              right: 0,
              top: top,
              bottom: 0,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _close, child: ColoredBox(color: dimming)),
            ),
          // The placeholder of showEmptyView: only for a query that is not empty.
          if (active && !queryIsEmpty && (controller?.isEmptyViewShowing ?? false))
            Positioned(
              left: 0,
              right: 0,
              top: top,
              bottom: 0,
              child: ColoredBox(
                color: scaffoldColor,
                child: Center(child: CYLPlaceholderView(placeholderStyle: CYLPlaceholderStyle.noResults, text: <String>[if (controller!._emptyViewText != null) controller._emptyViewText!, if (controller._emptyViewDetailText != null) controller._emptyViewDetailText!].join('\n'))),
              ),
            ),
          // The edge strip of the swipe to dismiss (iOS: a screen edge pan recognizer).
          if (widget.supportsSwipeToDismissSearch && active)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (_) => _swipeAnimation.stop(),
                onHorizontalDragUpdate: (details) => setState(() => _swipeOffset = (_swipeOffset + details.delta.dx).clamp(0, width)),
                onHorizontalDragEnd: (details) => _swipeEnded(details.primaryVelocity ?? 0, width),
                onHorizontalDragCancel: () => _animateSwipeTo(0),
              ),
            ),
        ],
      ),
    );
  }
}

/// How an item appended to a search bar looks (iOS and Android `CYLSearchBarItemStyle`).
enum CYLSearchBarItemStyle {
  /// An icon button with a 36-point touch area (a camera, a filter).
  icon,

  /// A thin vertical line between two items; screen readers skip it.
  divider,

  /// A text button (a "Search" button).
  text,
}

/// The fixed look of the whole bar (iOS and Android `CYLSearchBarStyle`).
enum CYLSearchBarStyle {
  /// The field as configured by its own parameters.
  plain,

  /// A capsule with a 1-point outline: the field and its items inside one outline.
  bordered,
}

/// One element after the text of a [CYLSearchBarView] (iOS and Android `CYLSearchBarItem`, like the FlatDesign tab
/// bar's items). The field stays; the bar only appends items.
@immutable
class CYLSearchBarItem {
  /// An item of the given style.
  const CYLSearchBarItem({
    required this.style,
    this.title,
    this.image,
    this.accessibilityIdentifier,
    this.isEnabled = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.badgeValue,
    this.onTap,
  });

  /// An icon item; [title] is what screen readers read.
  const CYLSearchBarItem.icon({required String this.image, required String this.title, this.accessibilityIdentifier, this.isEnabled = true, this.isSelectable = false, this.isSelected = false, this.badgeValue, this.onTap})
      : style = CYLSearchBarItemStyle.icon;

  /// A text item (a "Search" button).
  const CYLSearchBarItem.text({required String this.title, this.accessibilityIdentifier, this.isEnabled = true, this.onTap})
      : style = CYLSearchBarItemStyle.text,
        image = null,
        isSelectable = false,
        isSelected = false,
        badgeValue = null;

  /// A divider between two items.
  const CYLSearchBarItem.divider()
      : style = CYLSearchBarItemStyle.divider,
        title = null,
        image = null,
        accessibilityIdentifier = null,
        isEnabled = true,
        isSelectable = false,
        isSelected = false,
        badgeValue = null,
        onTap = null;

  /// The look (iOS `style`).
  final CYLSearchBarItemStyle style;

  /// The text of a text item, and the screen reader label of an icon item (iOS `title`).
  final String? title;

  /// The icon: `camera`, `mic`, `search` or `back` (drawn by the core on both platforms), else an image of the app
  /// (an iOS asset or SF Symbol name, an Android drawable name).
  final String? image;

  /// A test identifier of the item view (iOS `itemAccessibilityIdentifier`).
  final String? accessibilityIdentifier;

  /// False dims the item and ignores taps (iOS `isEnabled`).
  final bool isEnabled;

  /// Each tap toggles [isSelected] on the native side (iOS `isSelectable`).
  final bool isSelectable;

  /// The selected state (iOS `isSelected`).
  final bool isSelected;

  /// The badge text; an empty string draws a dot (iOS `badgeValue`).
  final String? badgeValue;

  /// Called on each tap with the selected state after the tap (iOS `handler`).
  final ValueChanged<bool>? onTap;

  /// The parameters the native view builds the item from.
  Map<String, Object?> toMap() => <String, Object?>{
        'style': style.name,
        'title': title,
        'image': image,
        'accessibilityIdentifier': accessibilityIdentifier,
        'isEnabled': isEnabled,
        'isSelectable': isSelectable,
        'isSelected': isSelected,
        'badgeValue': badgeValue,
      };
}

/// The merged default style of a [CYLSearchBarView] (iOS `CYLSearchBarAppearance`, Android `CYLSearchBarAppearance`): the
/// field's colors and corners, the tint and the Cancel title. A null value leaves the native default of that property.
@immutable
class CYLSearchBarAppearance {
  /// An appearance; every value is optional.
  const CYLSearchBarAppearance({
    this.fieldBackgroundColor,
    this.fieldBorderColor,
    this.fieldCornerRadius,
    this.tintColor,
    this.barBackgroundColor,
    this.cancelTitle,
  });

  /// The field's background (iOS `textFieldBackgroundColor`).
  final Color? fieldBackgroundColor;

  /// The field's border (iOS `textFieldBorderColor`).
  final Color? fieldBorderColor;

  /// The field's corner radius; negative makes a capsule (iOS `textFieldCornerRadius`).
  final double? fieldCornerRadius;

  /// The color of Cancel and of the cursor (iOS `tintColor`).
  final Color? tintColor;

  /// The color behind the whole bar (iOS `barBackgroundColor`).
  final Color? barBackgroundColor;

  /// The Cancel button's title (iOS `cancelTitle`).
  final String? cancelTitle;

  /// The parameters the native view applies.
  Map<String, Object?> toMap() => <String, Object?>{
        'fieldBackgroundColor': fieldBackgroundColor?.toARGB32(),
        'fieldBorderColor': fieldBorderColor?.toARGB32(),
        'fieldCornerRadius': fieldCornerRadius,
        'tintColor': tintColor?.toARGB32(),
        'barBackgroundColor': barBackgroundColor?.toARGB32(),
        'cancelTitle': cancelTitle,
      };
}

List<double> _insetsList(EdgeInsets insets) => <double>[insets.left, insets.top, insets.right, insets.bottom];

/// The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`) as a widget: a rounded field with a
/// magnifier, the text, a clear button, appended [items] and an optional Cancel button. With [mode] set to
/// [CYLSearchBarMode.multiple] it holds several searches side by side instead ([searches], [controller]). Give it a
/// height (about 48 logical pixels, 56 in multiple mode).
class CYLSearchBarView extends StatefulWidget {
  /// Creates the search bar.
  const CYLSearchBarView({
    super.key,
    this.controller,
    this.mode = CYLSearchBarMode.single,
    this.searches = const <String>[],
    this.onTextChange,
    this.onCompleteSearch,
    this.onRemoveSearch,
    this.onSelectSearch,
    this.placeholder,
    this.text,
    this.showsCancelButton = false,
    this.fieldShadowOpacity = 0,
    this.searchBarStyle = CYLSearchBarStyle.plain,
    this.showsSearchIcon = true,
    this.items = const <CYLSearchBarItem>[],
    this.onTextChanged,
    this.onSubmitted,
    this.onCancel,
    this.onItemSelected,
    this.editingBar = false,
    this.actionTitle,
    this.onEditingSubmitted,
    this.placeholderColor,
    this.textColor,
    this.fontSize,
    this.centersPlaceholder = false,
    this.textFieldMargins = EdgeInsets.zero,
    this.activeTextFieldMargins,
    this.cancelButtonMargins = EdgeInsets.zero,
    this.activeCancelButtonMargins,
    this.cancelButtonFontSize,
    this.appearance,
    this.leadingAccessoryView,
    this.showsLeadingAccessoryView = true,
    this.leadingAccessoryViewMargins = EdgeInsets.zero,
    this.trailingAccessoryView,
    this.showsTrailingAccessoryView = true,
    this.trailingAccessoryViewMargins = EdgeInsets.zero,
  });

  /// The placeholder's color (iOS `placeholderColor`); null keeps the native default.
  final Color? placeholderColor;

  /// The text's color (iOS `textColor`); null keeps the native default.
  final Color? textColor;

  /// The text and placeholder size in logical pixels (iOS `font`); null keeps the native default.
  final double? fontSize;

  /// Draws the magnifier and the placeholder in the middle of the field while the bar is not edited and has no text, and
  /// at the start otherwise (iOS `centersPlaceholder`, QMUI `qmui_centerPlaceholder`).
  final bool centersPlaceholder;

  /// The space around the field at rest, on top of the native margins (iOS `textFieldMargins`).
  final EdgeInsets textFieldMargins;

  /// The space around the field while the bar is active, that is edited (iOS `textFieldMarginsProvider(bar, true)`);
  /// null uses [textFieldMargins] in both states.
  final EdgeInsets? activeTextFieldMargins;

  /// The space around the Cancel button at rest (iOS `cancelButtonMarginsProvider(bar, false)`). A negative left value
  /// pulls Cancel toward the field.
  final EdgeInsets cancelButtonMargins;

  /// The space around the Cancel button while the bar is active (iOS `cancelButtonMarginsProvider(bar, true)`); null
  /// uses [cancelButtonMargins].
  final EdgeInsets? activeCancelButtonMargins;

  /// The Cancel button's text size (iOS `cancelButtonFont`); null uses the text's.
  final double? cancelButtonFontSize;

  /// The merged default style (iOS `appearanceStyle`); null keeps the native default.
  final CYLSearchBarAppearance? appearance;

  /// A widget of yours beside the field, before it (iOS `leadingAccessoryView`), centered on the field: a native field
  /// cannot hold a Flutter widget, so the bar lays the widget out in a row with the native field, which takes the
  /// remaining width. Toggle it with [showsLeadingAccessoryView] or [CYLSearchBarWidgetController.setShowsLeadingAccessoryView].
  final Widget? leadingAccessoryView;

  /// Whether [leadingAccessoryView] is shown (iOS `showsLeadingAccessoryView`); true by default.
  final bool showsLeadingAccessoryView;

  /// The space around [leadingAccessoryView] (iOS `leadingAccessoryViewMargins`).
  final EdgeInsets leadingAccessoryViewMargins;

  /// A widget of yours beside the field, after it (iOS `trailingAccessoryView`), see [leadingAccessoryView].
  final Widget? trailingAccessoryView;

  /// Whether [trailingAccessoryView] is shown (iOS `showsTrailingAccessoryView`); true by default.
  final bool showsTrailingAccessoryView;

  /// The space around [trailingAccessoryView] (iOS `trailingAccessoryViewMargins`).
  final EdgeInsets trailingAccessoryViewMargins;

  /// The core's editing bar (iOS and Android `CYLSearchBarView.editingBar`) in place of the search bar: a field and an
  /// action button ("Add", "Done") to put above the keyboard. Read when the native view is created; give the widget
  /// another key to switch. Given a new non-empty [text] (a title to rename), it takes the keyboard with the text
  /// selected.
  final bool editingBar;

  /// [editingBar]: the action button's title.
  final String? actionTitle;

  /// [editingBar]: the action button or the return key, with the trimmed text; the field is cleared after it and
  /// [onSubmitted] is not called.
  final ValueChanged<String>? onEditingSubmitted;

  /// Calls the native bar's multiple-search methods; optional.
  final CYLSearchBarWidgetController? controller;

  /// One field, or several searches side by side (iOS and Android `mode`).
  final CYLSearchBarMode mode;

  /// [CYLSearchBarMode.multiple]: the completed searches (iOS and Android `searches`, filled with `addSearch(_:)`).
  /// The native bar takes a list that differs from its own completed searches, unless a search is being typed; keep
  /// it in sync through [onCompleteSearch] and [onRemoveSearch], or leave it empty and let the bar keep its own.
  final List<String> searches;

  /// [CYLSearchBarMode.multiple]: the text of the search being typed changed, with its index (iOS
  /// `searchBarView(_:textDidChange:at:)`). [CYLSearchBarMode.single] reports [onTextChanged] instead.
  final void Function(String text, int index)? onTextChange;

  /// [CYLSearchBarMode.multiple]: a search was completed and became an entry of the searches, with its index (iOS
  /// `searchBarView(_:didCompleteSearch:at:)`).
  final void Function(String text, int index)? onCompleteSearch;

  /// [CYLSearchBarMode.multiple]: a search was removed by its remove button or
  /// [CYLSearchBarWidgetController.removeSearch] (iOS `searchBarView(_:didRemoveSearchAt:)`).
  final ValueChanged<int>? onRemoveSearch;

  /// [CYLSearchBarMode.multiple]: a search was selected by a tap or [CYLSearchBarWidgetController.selectSearch] (iOS
  /// `searchBarView(_:didSelectSearch:at:)`).
  final void Function(String text, int index)? onSelectSearch;

  /// The fixed look of the bar (iOS `searchBarStyle`).
  final CYLSearchBarStyle searchBarStyle;

  /// Draws the magnifier at the start of the field (iOS `searchIcon` set or nil).
  final bool showsSearchIcon;

  /// The items appended after the text, in order (iOS `addItem(_:)`).
  final List<CYLSearchBarItem> items;

  /// An item was tapped, with its index (iOS `searchBarView(_:didSelect:)`), after the item's own `onTap`.
  final void Function(CYLSearchBarItem item, int index)? onItemSelected;

  /// The placeholder (iOS `placeholder`).
  final String? placeholder;

  /// The text (iOS `text`); null keeps what the user typed.
  final String? text;

  /// Shows Cancel after the field (iOS `showsCancelButton`).
  final bool showsCancelButton;

  /// The field's shadow, 0 to 1 (iOS `fieldShadowOpacity`).
  final double fieldShadowOpacity;

  /// [CYLSearchBarMode.single]: the text changed (iOS `searchBarView(_:textDidChange:)`).
  final ValueChanged<String>? onTextChanged;

  /// The search key or the submit button (iOS `searchBarViewSearchButtonClicked(_:)`), with the text.
  final ValueChanged<String>? onSubmitted;

  /// Cancel was tapped (iOS `searchBarViewCancelButtonClicked(_:)`).
  final VoidCallback? onCancel;

  @override
  State<CYLSearchBarView> createState() => _CYLSearchBarViewState();
}

class _CYLSearchBarViewState extends State<CYLSearchBarView> {
  MethodChannel? _channel;
  late bool _showsLeading = widget.showsLeadingAccessoryView;
  late bool _showsTrailing = widget.showsTrailingAccessoryView;
  bool _animatesAccessories = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChanged);
  }

  void _controllerChanged() {
    final controller = widget.controller;
    if (controller == null) return;
    setState(() {
      _showsLeading = controller._showsLeadingAccessoryView ?? _showsLeading;
      _showsTrailing = controller._showsTrailingAccessoryView ?? _showsTrailing;
      _animatesAccessories = controller._animatesAccessoryViews;
    });
  }

  Map<String, Object?> get _parameters => cylSearchBarViewParameters(widget, brightness: Theme.of(context).brightness);

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    widget.controller?.attach(channel);
    setState(() => _channel = channel);
  }

  Future<Object?> _handle(MethodCall call) async {
    cylSearchBarViewDispatch(widget, call);
    return null;
  }

  @override
  void didUpdateWidget(CYLSearchBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      oldWidget.controller?.attach(null);
      widget.controller?.addListener(_controllerChanged);
      widget.controller?.attach(_channel);
    }
    // A changed flag of the widget wins over an earlier call of the controller.
    if (oldWidget.showsLeadingAccessoryView != widget.showsLeadingAccessoryView) _showsLeading = widget.showsLeadingAccessoryView;
    if (oldWidget.showsTrailingAccessoryView != widget.showsTrailingAccessoryView) _showsTrailing = widget.showsTrailingAccessoryView;
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    widget.controller?.attach(null);
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  /// One accessory slot: nothing while hidden, the widget with its margins while shown, animated in width when asked.
  Widget _accessory(Widget? child, bool shows, EdgeInsets margins) {
    final content = child != null && shows ? Padding(padding: margins, child: child) : const SizedBox.shrink();
    return _animatesAccessories
        ? AnimatedSize(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, child: content)
        : content;
  }

  @override
  Widget build(BuildContext context) => Row(
        // The row's structure never changes, so the native view is not created again when an accessory comes or goes.
        children: <Widget>[
          _accessory(widget.leadingAccessoryView, _showsLeading, widget.leadingAccessoryViewMargins),
          Expanded(child: _platformView(CYLSearchViewTypes.searchBarView, _parameters, _created)),
          _accessory(widget.trailingAccessoryView, _showsTrailing, widget.trailingAccessoryViewMargins),
        ],
      );
}

/// The parameters a [CYLSearchView] sends to its native view, at creation and on every update. `brightness` is the
/// app's theme brightness: the native view uses its light or dark colors, whatever the system setting is.
@visibleForTesting
Map<String, Object?> cylSearchViewParameters(CYLSearchView widget, {Brightness brightness = Brightness.light}) => <String, Object?>{
      'brightness': brightness.name,
      'results': widget.results,
      'refreshEnabled': widget.refreshEnabled,
      'suggestions': widget.suggestions,
      'suggestionStyle': widget.suggestionStyle.name,
      'placeholder': widget.placeholder,
      'query': widget.query,
      'showsSuggestionsForEmptyQuery': widget.showsSuggestionsForEmptyQuery,
      'submitsOnSuggestionSelection': widget.submitsOnSuggestionSelection,
      'showsEmptyResultsPlaceholder': widget.showsEmptyResultsPlaceholder,
      'emptyResultsScenario': widget.emptyResultsScenario.name,
      'suggestionCachePolicy': widget.suggestionCachePolicy.name,
      'suggestionCacheName': widget.suggestionCacheName,
      'focusesSearchFieldOnShow': widget.focusesSearchFieldOnShow,
      'showsSuggestionCacheHeader': widget.showsSuggestionCacheHeader,
      'suggestionsFoldControlPosition': widget.suggestionsFoldControlPosition.name,
      'suggestionsFoldControlContent': widget.suggestionsFoldControlContent.name,
      'suggestionsFoldedRowCount': widget.suggestionsFoldedRowCount,
      'highlightsResultMatches': widget.highlightsResultMatches,
    };

/// Calls the [CYLSearchView] callback of an event from its native view.
@visibleForTesting
void cylSearchViewDispatch(CYLSearchView widget, MethodCall call) {
  final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  switch (call.method) {
    case 'textDidChange':
      widget.onTextChanged?.call(arguments['text'] as String? ?? '');
      widget.onUpdateResults?.call(arguments['text'] as String? ?? '');
    case 'didSubmit':
      widget.onSubmitted?.call(arguments['text'] as String? ?? '');
    case 'didSelectSuggestion':
      widget.onSuggestionSelected?.call(arguments['suggestion'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'didShow':
      widget.onDidPresent?.call();
    case 'historyDidChange':
      widget.onHistoryChanged?.call((arguments['history'] as List<Object?>?)?.whereType<String>().toList() ?? const <String>[]);
    case 'didClose':
      widget.onDidDismiss?.call();
      widget.onClose?.call();
    case 'didSelectResult':
      widget.onSelectResult?.call(arguments['result'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'refresh':
      widget.onRefresh?.call();
  }
}

/// The parameters a [CYLSearchBarView] sends to its native view, at creation and on every update (`brightness`: see
/// [cylSearchViewParameters]).
@visibleForTesting
Map<String, Object?> cylSearchBarViewParameters(CYLSearchBarView widget, {Brightness brightness = Brightness.light}) => <String, Object?>{
      'brightness': brightness.name,
      'mode': widget.mode.name,
      'searches': widget.searches,
      'placeholder': widget.placeholder,
      'text': widget.text,
      'showsCancelButton': widget.showsCancelButton,
      'fieldShadowOpacity': widget.fieldShadowOpacity,
      'searchBarStyle': widget.searchBarStyle.name,
      'showsSearchIcon': widget.showsSearchIcon,
      'items': widget.items.map((item) => item.toMap()).toList(),
      'editingBar': widget.editingBar,
      'actionTitle': widget.actionTitle,
      'placeholderColor': widget.placeholderColor?.toARGB32(),
      'textColor': widget.textColor?.toARGB32(),
      'fontSize': widget.fontSize,
      'centersPlaceholder': widget.centersPlaceholder,
      'textFieldMargins': _insetsList(widget.textFieldMargins),
      'activeTextFieldMargins': _insetsList(widget.activeTextFieldMargins ?? widget.textFieldMargins),
      'cancelButtonMargins': _insetsList(widget.cancelButtonMargins),
      'activeCancelButtonMargins': _insetsList(widget.activeCancelButtonMargins ?? widget.cancelButtonMargins),
      'cancelButtonFontSize': widget.cancelButtonFontSize,
      'appearance': widget.appearance?.toMap(),
    };

/// Calls the [CYLSearchBarView] callback of an event from its native view.
@visibleForTesting
void cylSearchBarViewDispatch(CYLSearchBarView widget, MethodCall call) {
  final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  switch (call.method) {
    case 'textDidChange':
      widget.onTextChanged?.call(arguments['text'] as String? ?? '');
    case 'didSubmit':
      widget.onSubmitted?.call(arguments['text'] as String? ?? '');
    case 'didCancel':
      widget.onCancel?.call();
    case 'didSubmitEditing':
      widget.onEditingSubmitted?.call(arguments['text'] as String? ?? '');
    case 'textDidChangeAtIndex':
      widget.onTextChange?.call(arguments['text'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'didCompleteSearch':
      widget.onCompleteSearch?.call(arguments['text'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'didRemoveSearch':
      widget.onRemoveSearch?.call(arguments['index'] as int? ?? 0);
    case 'didSelectSearch':
      widget.onSelectSearch?.call(arguments['text'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'didSelectItem':
      final index = arguments['index'] as int? ?? -1;
      if (index < 0 || index >= widget.items.length) return;
      final item = widget.items[index];
      item.onTap?.call(arguments['selected'] as bool? ?? false);
      widget.onItemSelected?.call(item, index);
  }
}

/// CollectionViewClassifyMenu's tag list (iOS and Android `CYLTagListView`, the view of `CYLSearchView`'s tag style) as
/// a widget: the tags wrap like words. It takes the height its tags need at its width, so put it in a scrolling or
/// unbounded column.
class CYLTagListView extends StatefulWidget {
  /// Creates the tag list.
  const CYLTagListView({
    super.key,
    this.tags = const <String>[],
    this.foldControlPosition = CYLTagFoldControlPosition.inline,
    this.foldControlContent = CYLTagFoldControlContent.icon,
    this.foldedRowCount = 2,
    this.onTagSelected,
    this.tagIds = const <String>[],
    this.selectedIds = const <String>[],
    this.selectionMode = CYLTagSelectionMode.none,
    this.sectionTitle = '',
    this.showsClearButton = false,
    this.editing = false,
    this.supportsRenaming = false,
    this.onTagToggled,
    this.onTagDeleted,
    this.onTagMoved,
    this.onRenameRequested,
    this.onClearButtonTapped,
    this.onDraggingChanged,
  });

  /// The tags' ids, one per title (iOS `menuIdentifierForItem(at:)`): kept by renaming and reordering, and reported by
  /// the callbacks. Empty: the titles are the ids.
  final List<String> tagIds;

  /// The ids of the selected tags ([CYLTagSelectionMode.multiple]).
  final List<String> selectedIds;

  /// Whether taps select tags (`selectionMode`).
  final CYLTagSelectionMode selectionMode;

  /// The section's header title; with [showsClearButton] or a title, the header shows.
  final String sectionTitle;

  /// A trash button in the header (iOS `menuShowsClearButton(forSection:)`): [onClearButtonTapped].
  final bool showsClearButton;

  /// Editing mode (iOS `setEditing(_:animated:)`): a cross on each tag ([onTagDeleted]) and dragging ([onTagMoved]).
  final bool editing;

  /// While [editing], an edit icon before each cross; it and a title tap call [onRenameRequested] (rename by id and
  /// send the new [tags]).
  final bool supportsRenaming;

  /// A tag was tapped, with its index, id and whether it is now selected ([CYLTagSelectionMode.multiple]).
  final void Function(int index, String id, bool selected)? onTagToggled;

  /// A tag's cross was tapped; the list already dropped it: update [tags] and [tagIds].
  final void Function(int index, String id)? onTagDeleted;

  /// A tag was dragged from one index to another; the list already moved it.
  final void Function(int from, int to)? onTagMoved;

  /// The edit icon or the title of a tag was tapped while [editing] with [supportsRenaming].
  final void Function(int index, String id, String title)? onRenameRequested;

  /// The header's clear button was tapped.
  final VoidCallback? onClearButtonTapped;

  /// A drag of a tag or a smear selection started (true) or ended or was cancelled (false), the counterpart of the mini
  /// program's `reorderingchange` and `smearingchange`. The list already keeps an ancestor scroll view from scrolling with
  /// the drag (a long press wins the pointer in the gesture arena); nothing else is needed in the app.
  final ValueChanged<bool>? onDraggingChanged;

  /// The titles of the tags (`setTagsWithTitles`).
  final List<String> tags;

  /// Where the fold control is (`foldControl.position`): a chevron as the last tag by default.
  final CYLTagFoldControlPosition foldControlPosition;

  /// What the fold control shows (`foldControl.content`).
  final CYLTagFoldControlContent foldControlContent;

  /// The rows shown while folded (`defaultVisibleRows`); 0 shows every row.
  final int foldedRowCount;

  /// A tag was tapped (`tagClickHandler`), with its index and title.
  final void Function(int index, String title)? onTagSelected;

  @override
  State<CYLTagListView> createState() => _CYLTagListViewState();
}

class _CYLTagListViewState extends State<CYLTagListView> {
  MethodChannel? _channel;

  /// Until the native view reports its height: about one row of tags.
  double _height = 44;

  Map<String, Object?> get _parameters => cylTagListViewParameters(widget, brightness: Theme.of(context).brightness);

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    setState(() => _channel = channel);
  }

  Future<Object?> _handle(MethodCall call) async {
    final height = cylTagListViewDispatch(widget, call);
    if (height != null && height != _height && mounted) setState(() => _height = height);
    return null;
  }

  @override
  void didUpdateWidget(CYLTagListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.tags, widget.tags) ||
        !listEquals(oldWidget.tagIds, widget.tagIds) ||
        !listEquals(oldWidget.selectedIds, widget.selectedIds) ||
        oldWidget.selectionMode != widget.selectionMode ||
        oldWidget.sectionTitle != widget.sectionTitle ||
        oldWidget.showsClearButton != widget.showsClearButton ||
        oldWidget.editing != widget.editing ||
        oldWidget.supportsRenaming != widget.supportsRenaming ||
        oldWidget.foldControlPosition != widget.foldControlPosition ||
        oldWidget.foldControlContent != widget.foldControlContent ||
        oldWidget.foldedRowCount != widget.foldedRowCount) {
      _channel?.invokeMethod<void>('update', _parameters);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: _height,
        child: _platformView(CYLSearchViewTypes.tagListView, _parameters, _created, gestureRecognizers: _tagListGestureRecognizers()),
      );
}

/// The parameters a [CYLTagListView] sends to its native view (`brightness`: see [cylSearchViewParameters]).
@visibleForTesting
Map<String, Object?> cylTagListViewParameters(CYLTagListView widget, {Brightness brightness = Brightness.light}) => <String, Object?>{
      'brightness': brightness.name,
      'tags': widget.tags,
      'foldControlPosition': widget.foldControlPosition.name,
      'foldControlContent': widget.foldControlContent.name,
      'foldedRowCount': widget.foldedRowCount,
      'tagIds': widget.tagIds,
      'selectedIds': widget.selectedIds,
      'selectionMode': widget.selectionMode.name,
      'sectionTitle': widget.sectionTitle,
      'showsClearButton': widget.showsClearButton,
      'editing': widget.editing,
      'supportsRenaming': widget.supportsRenaming,
    };

/// Calls the [CYLTagListView] callback of an event from its native view; returns the height it reported, if any.
@visibleForTesting
double? cylTagListViewDispatch(CYLTagListView widget, MethodCall call) {
  final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  switch (call.method) {
    case 'didSelectTag':
      final index = arguments['index'] as int? ?? 0;
      final title = arguments['title'] as String? ?? '';
      widget.onTagSelected?.call(index, title);
      widget.onTagToggled?.call(index, arguments['id'] as String? ?? title, arguments['selected'] as bool? ?? false);
    case 'didDeleteTag':
      widget.onTagDeleted?.call(arguments['index'] as int? ?? 0, arguments['id'] as String? ?? '');
    case 'didMoveTag':
      widget.onTagMoved?.call(arguments['from'] as int? ?? 0, arguments['to'] as int? ?? 0);
    case 'didRequestRename':
      widget.onRenameRequested?.call(
          arguments['index'] as int? ?? 0, arguments['id'] as String? ?? '', arguments['title'] as String? ?? '');
    case 'didTapClearButton':
      widget.onClearButtonTapped?.call();
    case 'didChangeDragging':
      widget.onDraggingChanged?.call(arguments['dragging'] as bool? ?? false);
    case 'didChangeHeight':
      return (arguments['height'] as num?)?.toDouble();
  }
  return null;
}

/// CYLTableViewPlaceHolder's placeholder (iOS and Android `CYLPlaceholderView`): the image of a [CYLPlaceholderStyle]
/// above a text, centred in the size it is given.
class CYLPlaceholderView extends StatefulWidget {
  /// Creates the placeholder.
  const CYLPlaceholderView({super.key, this.placeholderStyle = CYLPlaceholderStyle.empty, this.text = ''});

  /// The image.
  final CYLPlaceholderStyle placeholderStyle;

  /// The text under the image.
  final String text;

  @override
  State<CYLPlaceholderView> createState() => _CYLPlaceholderViewState();
}

class _CYLPlaceholderViewState extends State<CYLPlaceholderView> {
  MethodChannel? _channel;

  Map<String, Object?> get _parameters => cylPlaceholderViewParameters(widget, brightness: Theme.of(context).brightness);

  void _created(int id) => setState(() => _channel = MethodChannel(CYLSearchViewTypes.channel(id)));

  @override
  void didUpdateWidget(CYLPlaceholderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeholderStyle != widget.placeholderStyle || oldWidget.text != widget.text) {
      _channel?.invokeMethod<void>('update', _parameters);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  Widget build(BuildContext context) => _platformView(CYLSearchViewTypes.placeholderView, _parameters, _created);
}

/// The parameters a [CYLPlaceholderView] sends to its native view.
@visibleForTesting
Map<String, Object?> cylPlaceholderViewParameters(CYLPlaceholderView widget, {Brightness brightness = Brightness.light}) =>
    <String, Object?>{'brightness': brightness.name, 'placeholderStyle': widget.placeholderStyle.name, 'text': widget.text};
