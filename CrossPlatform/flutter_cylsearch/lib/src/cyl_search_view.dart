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

/// The view types the platform side registers.
@visibleForTesting
class CYLSearchViewTypes {
  CYLSearchViewTypes._();

  /// The native search page (iOS `CYLSearchView`, Android `com.cyl.search.CYLSearchView`).
  static const String searchView = 'cyl_search/search_view';

  /// The native search bar (iOS and Android `CYLSearchBarView`).
  static const String searchBarView = 'cyl_search/search_bar_view';

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
