import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Theme;
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

  /// The channel of the platform view with `id`.
  static String channel(int id) => 'cyl_search/view_$id';
}

Widget _platformView(
  String viewType,
  Map<String, Object?> creationParams,
  void Function(int id) onCreated,
) {
  const codec = StandardMessageCodec();
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: codec,
        onPlatformViewCreated: onCreated,
      );
    case TargetPlatform.android:
      // Hybrid composition: the native view is in the Android view hierarchy, so its keyboard, focus and text
      // selection behave as in a native app.
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) => AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
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
/// CYLTableViewPlaceHolder's placeholder for a query without results. It is open while it is shown; push it as a full
/// screen route so its bar takes the place of the navigation bar, and pop the route in [onClose].
class CYLSearchView extends StatefulWidget {
  /// Creates the search page.
  const CYLSearchView({
    super.key,
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
    this.suggestionsFoldControlPosition = CYLTagFoldControlPosition.inline,
    this.suggestionsFoldControlContent = CYLTagFoldControlContent.icon,
    this.suggestionsFoldedRowCount = 2,
    this.onTextChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.onClose,
  });

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

class _CYLSearchViewState extends State<CYLSearchView> {
  MethodChannel? _channel;

  Map<String, Object?> get _parameters => cylSearchViewParameters(widget, brightness: Theme.of(context).brightness);

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    setState(() => _channel = channel);
  }

  Future<Object?> _handle(MethodCall call) async {
    cylSearchViewDispatch(widget, call);
    return null;
  }

  @override
  void didUpdateWidget(CYLSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _platformView(CYLSearchViewTypes.searchView, _parameters, _created);
}

/// The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`) as a widget: a rounded field with a
/// magnifier, the text, a clear button and an optional Cancel button. Give it a height (about 48 logical pixels).
class CYLSearchBarView extends StatefulWidget {
  /// Creates the search bar.
  const CYLSearchBarView({
    super.key,
    this.placeholder,
    this.text,
    this.showsCancelButton = false,
    this.fieldShadowOpacity = 0,
    this.onTextChanged,
    this.onSubmitted,
    this.onCancel,
  });

  /// The placeholder (iOS `placeholder`).
  final String? placeholder;

  /// The text (iOS `text`); null keeps what the user typed.
  final String? text;

  /// Shows Cancel after the field (iOS `showsCancelButton`).
  final bool showsCancelButton;

  /// The field's shadow, 0 to 1 (iOS `fieldShadowOpacity`).
  final double fieldShadowOpacity;

  /// The text changed (iOS `searchBarView(_:textDidChange:)`).
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

  Map<String, Object?> get _parameters => cylSearchBarViewParameters(widget, brightness: Theme.of(context).brightness);

  void _created(int id) {
    final channel = MethodChannel(CYLSearchViewTypes.channel(id));
    channel.setMethodCallHandler(_handle);
    setState(() => _channel = channel);
  }

  Future<Object?> _handle(MethodCall call) async {
    cylSearchBarViewDispatch(widget, call);
    return null;
  }

  @override
  void didUpdateWidget(CYLSearchBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel?.invokeMethod<void>('update', _parameters);
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
  Widget build(BuildContext context) => _platformView(CYLSearchViewTypes.searchBarView, _parameters, _created);
}

/// The parameters a [CYLSearchView] sends to its native view, at creation and on every update. `brightness` is the
/// app's theme brightness: the native view uses its light or dark colors, whatever the system setting is.
@visibleForTesting
Map<String, Object?> cylSearchViewParameters(CYLSearchView widget, {Brightness brightness = Brightness.light}) => <String, Object?>{
      'brightness': brightness.name,
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
      'suggestionsFoldControlPosition': widget.suggestionsFoldControlPosition.name,
      'suggestionsFoldControlContent': widget.suggestionsFoldControlContent.name,
      'suggestionsFoldedRowCount': widget.suggestionsFoldedRowCount,
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
    case 'didClose':
      widget.onClose?.call();
  }
}

/// The parameters a [CYLSearchBarView] sends to its native view, at creation and on every update (`brightness`: see
/// [cylSearchViewParameters]).
@visibleForTesting
Map<String, Object?> cylSearchBarViewParameters(CYLSearchBarView widget, {Brightness brightness = Brightness.light}) => <String, Object?>{
      'brightness': brightness.name,
      'placeholder': widget.placeholder,
      'text': widget.text,
      'showsCancelButton': widget.showsCancelButton,
      'fieldShadowOpacity': widget.fieldShadowOpacity,
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
  });

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
        child: _platformView(CYLSearchViewTypes.tagListView, _parameters, _created),
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
    };

/// Calls the [CYLTagListView] callback of an event from its native view; returns the height it reported, if any.
@visibleForTesting
double? cylTagListViewDispatch(CYLTagListView widget, MethodCall call) {
  final arguments = (call.arguments as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  switch (call.method) {
    case 'didSelectTag':
      widget.onTagSelected?.call(arguments['index'] as int? ?? 0, arguments['title'] as String? ?? '');
    case 'didChangeHeight':
      return (arguments['height'] as num?)?.toDouble();
  }
  return null;
}
