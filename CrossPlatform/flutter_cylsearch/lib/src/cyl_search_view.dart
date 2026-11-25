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

/// [CYLTagListView.titleMaxLines]: one line, the default; a title too wide for its tag is truncated.
const int cylTagTitleSingleLine = 1;

/// [CYLTagListView.titleMaxLines]: no limit, a title wraps onto as many lines as it needs.
const int cylTagTitleUnlimited = 0;

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

/// Sends calls to the native view of one widget; calls made before the view exists do nothing.
abstract class _CYLPlatformViewController {
  MethodChannel? _channel;

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
    await _invoke<void>('setActive', <String, Object?>{'active': active, 'animated': animated});
  }

  /// Sets the query and, with [submit], submits it (iOS `setQuery(_:submit:)`, Android `setQuery`): the results follow
  /// through [CYLSearchView.onTextChanged], and a submit goes into the history and [CYLSearchView.onSubmitted]. A tapped
  /// recent tag does this natively (with [CYLSearchView.submitsOnSuggestionSelection]); call it for a query of your own.
  Future<void> setQuery(String? query, {bool submit = false}) =>
      _invoke<void>('setQuery', <String, Object?>{'query': query, 'submit': submit});

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
  bool? _showsLeadingView;
  bool? _showsTrailingAccessoryViews;
  bool _animatesAccessoryViews = false;

  /// Shows or hides Cancel, with an animation when [animated] is true (iOS `setShowsCancelButton(_:animated:)`, Android
  /// `setShowsCancelButton`). The last call decides: two quick calls end in the state of the second.
  Future<void> setShowsCancelButton(bool shows, {bool animated = true}) =>
      _invoke<void>('setShowsCancelButton', <String, Object?>{'shows': shows, 'animated': animated});

  /// Focuses the field and raises the keyboard (iOS and Android `showKeyboard()`).
  Future<void> showKeyboard() => _invoke<void>('showKeyboard');

  /// Plays the animation of the item at [index] of [CYLSearchBarView.items] again from the start (iOS and Android
  /// `CYLSearchBarItem.restartAnimation()`); nothing happens for an item without [CYLSearchBarItem.animationURL].
  Future<void> restartItemAnimation(int index) => _invoke<void>('restartItemAnimation', <String, Object?>{'index': index});

  /// Shows or hides [CYLSearchBarView.leadingView], with an animation when [animated] is true (iOS
  /// `setShowsLeadingView(_:animated:)`). The last call decides.
  void setShowsLeadingView(bool shows, {bool animated = true}) {
    _showsLeadingView = shows;
    _animatesAccessoryViews = animated;
    notifyListeners();
  }

  /// Shows or hides [CYLSearchBarView.trailingAccessoryViews], with an animation when [animated] is true (iOS
  /// `setShowsTrailingAccessoryViews(_:animated:)`). The last call decides.
  void setShowsTrailingAccessoryViews(bool shows, {bool animated = true}) {
    _showsTrailingAccessoryViews = shows;
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
    this.suggestionStyle = CYLSearchSuggestionStyle.tags,
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
    this.scrimColor,
    this.supportsSwipeToDismissSearch = false,
    this.highlightsResultMatches = false,
    this.resultMatchHighlightColor,
    this.noResultsText,
    this.onWillShow,
    this.onDidShow,
    this.onWillClose,
    this.onHistoryChanged,
  });

  /// A widget of yours under the search bar while the query is empty, in place of the core's launch area. The core
  /// already has a launch area, the ClassifyMenu tag list with the recent searches, their header and the trash button,
  /// folded with the fold control last: set [suggestions] and [showsSuggestionsForEmptyQuery] and use that. This builder
  /// exists only for content that is not tags, and is Dart because a platform view cannot host a Flutter widget: the page
  /// lays the widget over the native view, from the bottom edge of the native bar down. It gets the submitted queries
  /// (the history, newest first), read again after each change of the history. Null by default.
  final Widget Function(BuildContext context, List<String> history)? launchViewBuilder;

  /// The color of the scrim under the bar while the query is empty (iOS `scrimColor`): the page below the bar is dimmed
  /// with it, and a tap on it ends the search. Null shows no scrim. The native overlay, one view for every platform.
  final Color? scrimColor;

  /// Lets a swipe from the left edge drag the page sideways and end the search when it passes a quarter of the width
  /// (iOS `supportsSwipeToDismissSearch`, the native gesture); a shorter swipe springs back. False by default.
  final bool supportsSwipeToDismissSearch;

  /// Colors the first part of each result that matches the query, ignoring case and diacritics ("e" matches "É"), in
  /// [resultMatchHighlightColor] (iOS `highlightsResultMatches`). False lists plain texts.
  final bool highlightsResultMatches;

  /// The color of the highlighted match (iOS `resultMatchHighlightColor`); null uses the tint color.
  final Color? resultMatchHighlightColor;

  /// The title of the empty results placeholder (iOS `CYLSearchController.noResultsText`): shown with
  /// [showsEmptyResultsPlaceholder] while a query has no result. Null keeps the placeholder's own title.
  final String? noResultsText;

  /// The search is about to open (iOS `searchViewWillShow(_:)`): when the page is built, and when
  /// [CYLSearchViewWidgetController.setActive] opens it again.
  final VoidCallback? onWillShow;

  /// The search is open (iOS `searchViewDidShow(_:)`): the native page exists, or was opened again.
  final VoidCallback? onDidShow;

  /// The search is about to close (iOS `searchViewWillClose(_:)`): [CYLSearchViewWidgetController.setActive] with false,
  /// Cancel, the back arrow or a swipe. [onClose] follows it.
  final VoidCallback? onWillClose;

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

  /// How the suggestions are shown (iOS `suggestionStyle`): tags by default.
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

  /// The search closed, by the back arrow, Cancel, a swipe or [CYLSearchViewWidgetController.setActive] (iOS
  /// `searchViewDidClose(_:)`): pop the route here.
  final VoidCallback? onClose;

  @override
  State<CYLSearchView> createState() => _CYLSearchViewState();
}

class _CYLSearchViewState extends State<CYLSearchView> {
  MethodChannel? _channel;
  late String _query = widget.query ?? '';
  List<String> _history = const <String>[];
  // The bottom edge of the native bar, as the native view reports it; null until it did.
  double? _barBottom;

  Map<String, Object?> get _parameters => cylSearchViewParameters(widget, brightness: Theme.of(context).brightness);

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChanged);
    // The native page opens when it is created, before Dart listens to it: the first show is announced here.
    widget.onWillShow?.call();
  }

  void _controllerChanged() => setState(() {});

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    widget.controller?.attach(channel);
    setState(() => _channel = channel);
    widget.onDidShow?.call();
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
      case 'didLayoutSearchBar':
        final bottom = (arguments['bottom'] as num?)?.toDouble();
        if (bottom != null && bottom != _barBottom) setState(() => _barBottom = bottom);
      case 'didShow':
        widget.controller?._setActiveState(true);
      case 'historyDidChange':
        _history = (arguments['history'] as List<Object?>?)?.whereType<String>().toList() ?? const <String>[];
        setState(() {});
      case 'didClose':
        widget.controller?._setActiveState(false);
    }
    cylSearchViewDispatch(widget, call);
    return null;
  }

  @override
  void didUpdateWidget(CYLSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      oldWidget.controller?.attach(null);
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
    widget.controller?.removeListener(_controllerChanged);
    widget.controller?.attach(null);
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.controller?.isActive ?? true;
    final top = _barBottom ?? MediaQuery.paddingOf(context).top + 56;
    final launch = widget.launchViewBuilder;
    return Stack(
      children: <Widget>[
        // The native page first and always: the launch area (tags, history), the scrim, the results, the empty view and
        // the swipe to dismiss are the core's; the children after it come and go without creating it again.
        Positioned.fill(child: _platformView(CYLSearchViewTypes.searchView, _parameters, _created)),
        // A launch widget of yours replaces the core's launch area while the query is empty, under the bar.
        if (active && _query.isEmpty && launch != null)
          Positioned(
            left: 0,
            right: 0,
            top: top,
            bottom: 0,
            child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: launch(context, _history)),
          ),
      ],
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

/// What the default search button of a bar shows (iOS and Android `CYLSearchBarSearchButtonStyle`).
enum CYLSearchBarSearchButtonStyle {
  /// A title, the localized "Search" by default ([CYLSearchBarView.searchButtonTitle] changes it).
  text,

  /// An icon, the core's built-in magnifier, in a filled capsule in the inverse color (28 high, black in light mode, white in dark mode).
  icon,
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
    this.animationURL,
    this.animationLoops = false,
    this.animationSpeed = 1,
    this.onTap,
  });

  /// An icon item; [title] is what screen readers read.
  const CYLSearchBarItem.icon({required String this.image, required String this.title, this.accessibilityIdentifier, this.isEnabled = true, this.isSelectable = false, this.isSelected = false, this.badgeValue, this.animationURL, this.animationLoops = false, this.animationSpeed = 1, this.onTap})
      : style = CYLSearchBarItemStyle.icon;

  /// A text item (a "Search" button).
  const CYLSearchBarItem.text({required String this.title, this.accessibilityIdentifier, this.isEnabled = true, this.onTap})
      : style = CYLSearchBarItemStyle.text,
        image = null,
        isSelectable = false,
        isSelected = false,
        badgeValue = null,
        animationURL = null,
        animationLoops = false,
        animationSpeed = 1;

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
        animationURL = null,
        animationLoops = false,
        animationSpeed = 1,
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

  /// The animated file of the icon (iOS and Android `animationURL`): Lottie `.json`, `.pag`, `.riv`, `.svga` or `.gif`,
  /// with `#` options; null shows [image] still. It plays on each tap, and again after each pass with [animationLoops].
  final String? animationURL;

  /// Whether [animationURL] plays again after each pass (iOS and Android `animationLoops`); false plays once on each tap.
  final bool animationLoops;

  /// The playback speed of [animationURL] (iOS and Android `animationSpeed`); 1 is the file's own.
  final double animationSpeed;

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
        'animationURL': animationURL,
        'animationLoops': animationLoops,
        'animationSpeed': animationSpeed,
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
    this.navigationFieldStyle = false,
    this.showsSearchButton = true,
    this.searchButtonStyle = CYLSearchBarSearchButtonStyle.text,
    this.searchButtonTitle,
    this.searchButtonHandler,
    this.focusesOnAppear = false,
    this.embedsInNavigationBar = false,
    this.showsBackButton = false,
    this.onBackPressed,
    this.animatesBackButton = true,
    this.pushesOnTap = false,
    this.onFirstLevelTap,
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
    this.leadingView,
    this.showsLeadingView = true,
    this.leadingViewMargins = EdgeInsets.zero,
    this.trailingAccessoryViews = const <Widget>[],
    this.showsTrailingAccessoryViews = true,
    this.trailingAccessoryViewsMargins = EdgeInsets.zero,
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

  /// A widget of yours beside the field, before it (iOS `leadingView`), centered on the field. Dart only, on purpose: the
  /// native `leadingView` is a native view, and a platform view cannot host a Flutter widget, so the bar lays this widget
  /// out in a row with the native field, which takes the remaining width. Native icon buttons and text buttons after the
  /// text are [items]. Toggle it with [showsLeadingView] or [CYLSearchBarWidgetController.setShowsLeadingView].
  final Widget? leadingView;

  /// Whether [leadingView] is shown (iOS `showsLeadingView`); true by default.
  final bool showsLeadingView;

  /// The space around [leadingView] (iOS `leadingViewMargins`).
  final EdgeInsets leadingViewMargins;

  /// Widgets of yours beside the field, after it, in order (iOS `trailingAccessoryViews`); Dart only like [leadingView].
  final List<Widget> trailingAccessoryViews;

  /// Whether [trailingAccessoryViews] is shown (iOS `showsTrailingAccessoryViews`); true by default.
  final bool showsTrailingAccessoryViews;

  /// The space around [trailingAccessoryViews] (iOS `trailingAccessoryViewsMargins`).
  final EdgeInsets trailingAccessoryViewsMargins;

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

  /// The core navigation field preset (iOS `applyNavigationFieldStyle()`): bordered capsule radius 18, soft shadow 0.06, no
  /// magnifier, 16 text that scales, an opaque white (light) or black (dark) fill. It wins over [searchBarStyle],
  /// [fieldShadowOpacity] and [showsSearchIcon].
  final bool navigationFieldStyle;

  /// The core's default search button after the field and the items (iOS and Android `showsSearchButton`): true by default; an
  /// editing bar ([editingBar]) and [CYLSearchBarMode.multiple] never show it. A tap submits the text ([onSubmitted]), also when
  /// the text is empty.
  final bool showsSearchButton;

  /// Whether the default search button shows a title (the default) or an icon in a filled capsule (`searchButtonStyle`).
  final CYLSearchBarSearchButtonStyle searchButtonStyle;

  /// The title of the default search button; null is the localized "Search" (`searchButtonTitle`).
  final String? searchButtonTitle;

  /// Called with the text instead of the default submit when the default search button is tapped (`searchButtonHandler`).
  final ValueChanged<String>? searchButtonHandler;

  /// The field focuses itself (and the keyboard shows) every time the bar appears on screen, like a `viewDidAppear`: the first
  /// entry, a tab switch, a push and pop and the return from the background. The native core handles attach, visibility and
  /// resume; this widget adds the route (the route above this one was popped) and [AppLifecycleState.resumed] by sending a
  /// `focus` call. Android filter (owner, 2026-11-26): only a bar embedded in a navigation bar that shows a back button
  /// ([embedsInNavigationBar] with [showsBackButton]) focuses; a root tab or a plain bar never does. Default false.
  final bool focusesOnAppear;

  /// The bar sits in a navigation bar the core creates (`CYLSearchNavigationBar`, 44 pt high, the field 36 pt) instead of
  /// being a plain view: the page always has its search bar in a navigation bar. Place it as the `Scaffold.appBar` of
  /// a `PreferredSize` 44 pt high. Read when the platform view is created. Default false.
  final bool embedsInNavigationBar;

  /// With [embedsInNavigationBar]: the navigation bar has the back button of a second-level page on its leading side and
  /// the search bar takes the width that is left; a tap calls [onBackPressed]. Read when the platform view is created.
  /// Default false.
  final bool showsBackButton;

  /// The back button of the navigation bar was tapped ([showsBackButton]): pop the route.
  final VoidCallback? onBackPressed;

  /// With [showsBackButton]: the bar starts whole (no back button) and the back button slides in while the width shrinks, the
  /// continuation of the first-level bar that pushed this page (native `CYLSearchBarView.showBackButton(animated)`); a later
  /// change of [showsBackButton] animates too. False: the button is in at once. Default true.
  final bool animatesBackButton;

  /// First-level page (with [embedsInNavigationBar]): the bar is shown whole and a tap on its field does not edit. The native core
  /// brings the back button in (animated) and calls [onFirstLevelTap], where the page pushes the second-level search page, whose
  /// bar sets [showsBackButton]. Default false.
  final bool pushesOnTap;

  /// The first-level field was tapped ([pushesOnTap]): push the second-level search page.
  final VoidCallback? onFirstLevelTap;

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

class _CYLSearchBarViewState extends State<CYLSearchBarView> with WidgetsBindingObserver {
  MethodChannel? _channel;
  late bool _showsLeading = widget.showsLeadingView;
  late bool _showsTrailing = widget.showsTrailingAccessoryViews;
  bool _animatesAccessories = false;
  Animation<double>? _secondaryAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  // focusesOnAppear: the return from the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _focusIfAppearing();
  }

  // focusesOnAppear: the route above this one was popped (its secondary animation is dismissed again).
  void _secondaryAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) _focusIfAppearing();
  }

  void _watchRoute() {
    final animation = ModalRoute.of(context)?.secondaryAnimation;
    if (animation == _secondaryAnimation) return;
    _secondaryAnimation?.removeStatusListener(_secondaryAnimationStatus);
    _secondaryAnimation = animation?..addStatusListener(_secondaryAnimationStatus);
  }

  void _focusIfAppearing() {
    if (!widget.focusesOnAppear || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    _channel?.invokeMethod<void>('focus');
  }

  void _controllerChanged() {
    final controller = widget.controller;
    if (controller == null) return;
    setState(() {
      _showsLeading = controller._showsLeadingView ?? _showsLeading;
      _showsTrailing = controller._showsTrailingAccessoryViews ?? _showsTrailing;
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
    if (oldWidget.showsLeadingView != widget.showsLeadingView) _showsLeading = widget.showsLeadingView;
    if (oldWidget.showsTrailingAccessoryViews != widget.showsTrailingAccessoryViews) _showsTrailing = widget.showsTrailingAccessoryViews;
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchRoute();
    _channel?.invokeMethod<void>('update', _parameters);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secondaryAnimation?.removeStatusListener(_secondaryAnimationStatus);
    widget.controller?.removeListener(_controllerChanged);
    widget.controller?.attach(null);
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  /// One accessory slot: nothing while hidden, the widget with its margins while shown, animated in width when asked.
  Widget _accessory(List<Widget> children, bool shows, EdgeInsets margins) {
    final content = children.isNotEmpty && shows
        ? Padding(padding: margins, child: Row(mainAxisSize: MainAxisSize.min, children: children))
        : const SizedBox.shrink();
    return _animatesAccessories
        ? AnimatedSize(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, child: content)
        : content;
  }

  @override
  Widget build(BuildContext context) => Row(
        // The row's structure never changes, so the native view is not created again when an accessory comes or goes.
        children: <Widget>[
          _accessory(<Widget>[if (widget.leadingView != null) widget.leadingView!], _showsLeading, widget.leadingViewMargins),
          Expanded(child: _platformView(CYLSearchViewTypes.searchBarView, _parameters, _created)),
          _accessory(widget.trailingAccessoryViews, _showsTrailing, widget.trailingAccessoryViewsMargins),
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
      'resultMatchHighlightColor': widget.resultMatchHighlightColor?.toARGB32(),
      'noResultsText': widget.noResultsText,
      'scrimColor': widget.scrimColor?.toARGB32(),
      'supportsSwipeToDismissSearch': widget.supportsSwipeToDismissSearch,
    };

/// Calls the [CYLSearchView] callback of an event from its native view.
@visibleForTesting
void cylSearchViewDispatch(CYLSearchView widget, MethodCall call) {
  final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  switch (call.method) {
    case 'textDidChange':
      widget.onTextChanged?.call(arguments['text'] as String? ?? '');
    case 'didSubmit':
      widget.onSubmitted?.call(arguments['text'] as String? ?? '');
    case 'didSelectSuggestion':
      widget.onSuggestionSelected?.call(arguments['suggestion'] as String? ?? '', arguments['index'] as int? ?? 0);
    case 'willShow':
      widget.onWillShow?.call();
    case 'didShow':
      widget.onDidShow?.call();
    case 'willClose':
      widget.onWillClose?.call();
    case 'historyDidChange':
      widget.onHistoryChanged?.call((arguments['history'] as List<Object?>?)?.whereType<String>().toList() ?? const <String>[]);
    case 'didClose':
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
      'navigationFieldStyle': widget.navigationFieldStyle,
      'showsSearchButton': widget.showsSearchButton,
      'searchButtonStyle': widget.searchButtonStyle.name,
      'searchButtonTitle': widget.searchButtonTitle,
      'hasSearchButtonHandler': widget.searchButtonHandler != null,
      'focusesOnAppear': widget.focusesOnAppear,
      'embedsInNavigationBar': widget.embedsInNavigationBar,
      'showsBackButton': widget.showsBackButton,
      'animatesBackButton': widget.animatesBackButton,
      'pushesOnTap': widget.pushesOnTap,
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
    case 'didTapSearchButton':
      widget.searchButtonHandler?.call(arguments['text'] as String? ?? '');
    case 'didTapFirstLevel':
      widget.onFirstLevelTap?.call();
    case 'didTapBackButton':
      widget.onBackPressed?.call();
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
    this.tagSubtitles = const <String>[],
    this.titleMaxLines = cylTagTitleSingleLine,
    this.onTagSelected,
    this.tagIds = const <String>[],
    this.selectedIds = const <String>[],
    this.selectionMode = CYLTagSelectionMode.none,
    this.sectionTitle = '',
    this.columns = 0,
    this.backgroundStyle = '',
    this.tagImages = const <String>[],
    this.tagImageLabels = const <String>[],
    this.showsClearButton = false,
    this.showsRefreshButton = false,
    this.editing = false,
    this.supportsRenaming = false,
    this.onTagToggled,
    this.onTagDeleted,
    this.onTagMoved,
    this.onRenameRequested,
    this.onClearButtonTapped,
    this.onRefreshButtonTapped,
    this.onDraggingChanged,
  });

  /// The tags' ids, one per title (iOS `menuIdentifierForItem(at:)`): kept by renaming and reordering, and reported by
  /// the callbacks. Empty: the titles are the ids.
  final List<String> tagIds;

  /// The subtitle of each tag, parallel to [tags] ('' none). A long press on a tag with one shows it in a small callout with
  /// an arrow (CollectionViewClassifyMenu's `longPressAction` callout, `menuSubtitleForItem`); a tap is unchanged.
  final List<String> tagSubtitles;

  /// The most lines a tag's title may wrap onto: [cylTagTitleSingleLine] (default, one line, truncated), [cylTagTitleUnlimited],
  /// or a count (ClassifyMenu's `titleMaxLines`).
  final int titleMaxLines;

  /// The ids of the selected tags ([CYLTagSelectionMode.multiple]).
  final List<String> selectedIds;

  /// Whether taps select tags (`selectionMode`).
  final CYLTagSelectionMode selectionMode;

  /// The section's header title; with [showsClearButton] or a title, the header shows.
  final String sectionTitle;

  /// More than 0 shows the tags as a grid of that many plain titles per row (CollectionViewClassifyMenu's
  /// `gridStyle(itemsPerRow:)`, the iOS example's discover topics); 0 (default) is the flowing capsule tags.
  final int columns;

  /// The background of every tag: 'liquidGlass' is the Liquid Glass material (flat where the system draws none),
  /// '' or 'flat' (default) the tag's own colors. The one parameter that turns a list into Liquid Glass tags
  /// (CollectionViewClassifyMenu's `backgroundStyle`).
  final String backgroundStyle;

  /// An image after each tag's title, one Flutter asset key per tag ('' for none), shown at its own size: the discover
  /// topics' hot icon. The 2.0x and 3.0x variants beside the asset are used as Flutter does.
  final List<String> tagImages;

  /// The accessibility label of each tag's image, localized, parallel to [tagImages] ('' for none): VoiceOver and
  /// TalkBack read it as the tag's value (for the hot icon, "Hot").
  final List<String> tagImageLabels;

  /// A trash button in the header (iOS `menuShowsClearButton(forSection:)`): [onClearButtonTapped].
  final bool showsClearButton;

  /// A refresh icon (the SF Symbol "arrow.clockwise", a localized VoiceOver label) at the trailing end of the header,
  /// in place of the three dots of the More button: [onRefreshButtonTapped]. One header action: it wins over
  /// [showsClearButton].
  final bool showsRefreshButton;

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

  /// The refresh icon of the header was tapped ([showsRefreshButton]).
  final VoidCallback? onRefreshButtonTapped;

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
        oldWidget.columns != widget.columns ||
        oldWidget.backgroundStyle != widget.backgroundStyle ||
        !listEquals(oldWidget.tagImages, widget.tagImages) ||
        !listEquals(oldWidget.tagImageLabels, widget.tagImageLabels) ||
        oldWidget.showsClearButton != widget.showsClearButton ||
        oldWidget.showsRefreshButton != widget.showsRefreshButton ||
        oldWidget.editing != widget.editing ||
        oldWidget.supportsRenaming != widget.supportsRenaming ||
        oldWidget.foldControlPosition != widget.foldControlPosition ||
        oldWidget.foldControlContent != widget.foldControlContent ||
        oldWidget.foldedRowCount != widget.foldedRowCount ||
        !listEquals(oldWidget.tagSubtitles, widget.tagSubtitles) ||
        oldWidget.titleMaxLines != widget.titleMaxLines) {
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
      'tagSubtitles': widget.tagSubtitles,
      'titleMaxLines': widget.titleMaxLines,
      'tagIds': widget.tagIds,
      'selectedIds': widget.selectedIds,
      'selectionMode': widget.selectionMode.name,
      'sectionTitle': widget.sectionTitle,
      'columns': widget.columns,
      'backgroundStyle': widget.backgroundStyle,
      'tagImages': widget.tagImages,
      'tagImageLabels': widget.tagImageLabels,
      'showsClearButton': widget.showsClearButton,
      'showsRefreshButton': widget.showsRefreshButton,
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
    case 'didTapRefreshButton':
      widget.onRefreshButtonTapped?.call();
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
