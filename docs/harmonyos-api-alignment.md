# HarmonyOS API Alignment

Every public API of the iOS library (`Sources/CYLSearchViewController`) next to its HarmonyOS (ArkTS) counterpart,
made as the [Android table](android-api-alignment.md) was. Rules and prompt: the HarmonyOS TODO in
[android-and-cross-platform.md](android-and-cross-platform.md).

## TODO (2026-11-13): implement every iOS API on HarmonyOS, score to 100

- Columns: the iOS public API; its doc comment; the HarmonyOS counterpart, `TODO` by default.
- After each API is implemented, replace that row's `TODO` with the HarmonyOS API (`N/A: <reason>` for a UIKit-only
  override with no HarmonyOS meaning), then run `python3 scripts/harmonyos-api-alignment.py`: it regenerates the rows
  from the Swift sources, keeps the third column, and prints the score. Repeat until 100.
- Before the search bar: study [Applib-HarmonyOS/FlexibleSearchBar](https://github.com/Applib-HarmonyOS/FlexibleSearchBar)
  and note what is reused.
- Status: `TODO`, score 0 (no HarmonyOS module yet).

## Score log

Score = rows whose third column is not `TODO` / rows × 100.

| Date | Change | Score |
| :--- | :--- | ---: |
| 2026-11-13 | Table listed, no HarmonyOS module | 0 |

## Table

<!-- harmonyos-api-alignment:begin -->
Rows: 302; implemented or N/A 0, TODO 302; score 0/100.

| iOS public API | Doc comment | HarmonyOS |
| :--- | :--- | :--- |
| **protocol `CYLMultiSearchViewDelegate`** | Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:textDidChange:atIndex:` | The text of the search being typed changed (`onTextChanged`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didCompleteSearch:atIndex:` | A search was completed and became an item (`onSearchComplete`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didRemoveItemAtIndex:` | An item was removed (`onSearchItemRemoved`). | TODO |
| `CYLMultiSearchViewDelegate.-multiSearchView:didSelectItem:atIndex:` | An item was selected by a tap (`onItemSelected`). | TODO |
| **class `CYLMultiSearchView`** | Several searches side by side (iammert `MultiSearchView`): the search button starts a new search; a completed search becomes an item in a horizontally scrolling row, with an indicator under the selected item and a remove button on it. Us… | TODO |
| `CYLMultiSearchView.delegate` | Receives the events. | TODO |
| `CYLMultiSearchView.selectedIndex` | The selected item, or `NSNotFound` when there is none. | TODO |
| `CYLMultiSearchView.inSearchMode` | YES while a new search is being typed (`isInSearchMode`). | TODO |
| `CYLMultiSearchView.searchButton` | The button at the trailing end: it starts a search, or completes the one being typed. | TODO |
| `CYLMultiSearchView.placeholder` | The placeholder of a new search (`android:hint`). "Search" by default. | TODO |
| `CYLMultiSearchView.font` | The font of the items (`android:textSize`). The body text style by default, following Dynamic Type. | TODO |
| `CYLMultiSearchView.textColor` | The text color (`android:textColor`). `labelColor` by default. | TODO |
| `CYLMultiSearchView.placeholderColor` | The placeholder color (`android:textColorHint`). `placeholderTextColor` by default. | TODO |
| `CYLMultiSearchView.maximumTextLength` | The longest search a person can type (`android:maxLength`); 0 means no limit. 0 by default. | TODO |
| `CYLMultiSearchView.minimumTextLength` | A search shorter than this is dropped when it is completed. 3 by default, as in MultiSearchView. | TODO |
| `CYLMultiSearchView.returnKeyType` | The return key (`android:imeOptions`). `UIReturnKeySearch` by default. | TODO |
| `CYLMultiSearchView.keyboardType` | The keyboard (`android:inputType`). `UIKeyboardTypeDefault` by default. | TODO |
| `CYLMultiSearchView.autocapitalizationType` | Capitalization (`textCapSentences`). `UITextAutocapitalizationTypeSentences` by default. | TODO |
| `CYLMultiSearchView.indicatorColor` | The color of the indicator under the selected item and of the buttons. `tintColor` by default. | TODO |
| `CYLMultiSearchView.unselectedItemAlpha` | The opacity of items that are not selected. 0.5 by default. | TODO |
| `CYLMultiSearchView.searchFieldWidth` | The width of the field for a new search, in points. 160 by default. | TODO |
| `CYLMultiSearchView.animationDuration` | The length of the animations, in seconds. 0.25 by default. | TODO |
| `CYLMultiSearchView.searchImage` | The search button's icon. `magnifyingglass` by default. | TODO |
| `CYLMultiSearchView.removeImage` | The remove button's icon. `xmark.circle.fill` by default. | TODO |
| `CYLMultiSearchView.searchTexts` | The texts of the items, completed searches first, then the one being typed. | TODO |
| `CYLMultiSearchView.init(frame:)` | — | TODO |
| `CYLMultiSearchView.init(coder:)` | — | TODO |
| `CYLMultiSearchView.tintColorDidChange()` | — | TODO |
| `CYLMultiSearchView.traitCollectionDidChange(_:)` | — | TODO |
| `CYLMultiSearchView.intrinsicContentSize` | — | TODO |
| `CYLMultiSearchView.layoutSubviews()` | — | TODO |
| `CYLMultiSearchView.search()` | Starts a new search and shows the keyboard (`search`). Does nothing while a search is being typed. | TODO |
| `CYLMultiSearchView.completeSearch()` | Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter than `minimumTextLength`. | TODO |
| `CYLMultiSearchView.addSearchText(_:)` | Adds a completed search without typing it and selects it. | TODO |
| `CYLMultiSearchView.selectItem(at:)` | Selects an item, like a tap on it. | TODO |
| `CYLMultiSearchView.removeItem(at:)` | Removes an item, like a tap on its remove button. | TODO |
| `CYLMultiSearchView.textFieldShouldBeginEditing(_:)` | Only the search being typed is editable; a tap on a completed one selects it. | TODO |
| `CYLMultiSearchView.textFieldShouldReturn(_:)` | The return key completes the search. | TODO |
| `CYLMultiSearchView.textField(_:shouldChangeCharactersIn:replacementString:)` | Enforces `maximumTextLength`. | TODO |
| **enum `CYLSearchBarNavigationIcon`** | The icon of the navigation button before the field (lapism `NavigationIconCompat`). | TODO |
| `CYLSearchBarNavigationIcon.none` | No navigation button. | TODO |
| `CYLSearchBarNavigationIcon.arrow` | A back arrow (`chevron.backward`). | TODO |
| `CYLSearchBarNavigationIcon.search` | A magnifier (`magnifyingglass`). | TODO |
| **enum `CYLSearchBarIconPosition`** | Where the search button sits while the bar is iconified. | TODO |
| `CYLSearchBarIconPosition.trailing` | At the trailing end, like an Android `SearchView` in a toolbar. | TODO |
| `CYLSearchBarIconPosition.center` | In the middle, like a floating action button that opens a search card. | TODO |
| `CYLSearchBarIconPosition.leading` | At the leading end. | TODO |
| **enum `CYLSearchBarExpansionAnimation`** | How the field opens and closes when `iconified` changes with animation. | TODO |
| `CYLSearchBarExpansionAnimation.fade` | The field grows from the icon and fades in. | TODO |
| `CYLSearchBarExpansionAnimation.circularReveal` | A circle grows from the icon until it uncovers the whole field (Material circular reveal). | TODO |
| **protocol `CYLSearchBarViewDelegate`** | Events of a `CYLSearchBarView`. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewShouldBeginEditing:` | Asks whether a tap may start editing. Return NO to use the bar as a button that opens another search page (lapism `MaterialSearchBar.setOnClickListener`); `-searchBarViewDidTapWhileNotEditable:` is called instead. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewDidTapWhileNotEditable:` | The bar was tapped while `-searchBarViewShouldBeginEditing:` refused editing. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewDidBeginEditing:` | Editing started. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewDidEndEditing:` | Editing ended. | TODO |
| `CYLSearchBarViewDelegate.-searchBarView:textDidChange:` | The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`). | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewSearchButtonClicked:` | The keyboard's Search key. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewCancelButtonClicked:` | Cancel was tapped. | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewNavigationButtonClicked:` | The navigation button before the field (`navigationIcon`, `navigationImage`). | TODO |
| `CYLSearchBarViewDelegate.-searchBarViewVoiceButtonClicked:` | The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to `-setText:submit:`. | TODO |
| `CYLSearchBarViewDelegate.-searchBarView:shouldSubmitText:` | Asks whether the query may be submitted (the Search key, the submit button or `-setText:submit:` with YES). Return NO to keep it. Without this method, every non-empty query is submitted. | TODO |
| `CYLSearchBarViewDelegate.-searchBarView:didChangeIconified:` | The field opened or closed (`iconified`). | TODO |
| **class `CYLSearchBarView`** | A configurable search bar: a rounded field with a magnifier, text and clear button, views of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and an optional Cancel button. Use i… | TODO |
| `CYLSearchBarView.delegate` | Receives the events. | TODO |
| `CYLSearchBarView.textField` | The text field inside the field. | TODO |
| `CYLSearchBarView.fieldView` | The rounded field that holds the magnifier, the text and `trailingAccessoryViews`. | TODO |
| `CYLSearchBarView.searchIconView` | The magnifier at the start of the field (decorative: hidden from VoiceOver). | TODO |
| `CYLSearchBarView.cancelButton` | The Cancel button after the field (`showsCancelButton`). | TODO |
| `CYLSearchBarView.placeholderLabel` | Draws the placeholder at the full font size, cut off with an ellipsis when it does not fit. | TODO |
| `CYLSearchBarView.navigationButton` | The button before the field. It is shown when `navigationIcon` is not none or `navigationImage` is set, and `leadingView` is nil; taps call `-searchBarViewNavigationButtonClicked:` and `navigationHandler`. | TODO |
| `CYLSearchBarView.voiceButton` | A microphone inside the field, shown while the text is empty; it calls `-searchBarViewVoiceButtonClicked:`. | TODO |
| `CYLSearchBarView.submitButton` | A submit button inside the field, shown while there is text; it submits the query like the Search key. | TODO |
| `CYLSearchBarView.iconButton` | The button shown while `iconified` is YES. VoiceOver reads it as "Search". | TODO |
| `CYLSearchBarView.text` | The text of the field. | TODO |
| `CYLSearchBarView.placeholder` | The placeholder, drawn by `placeholderLabel` and kept on the text field for VoiceOver. | TODO |
| `CYLSearchBarView.font` | The font of the text, the placeholder and Cancel. The body text style by default, following Dynamic Type; a custom font is used as given (pass a `UIFontMetrics` font to scale it). | TODO |
| `CYLSearchBarView.textColor` | The text color. `labelColor` by default. | TODO |
| `CYLSearchBarView.placeholderColor` | The placeholder color. `placeholderTextColor` when nil. | TODO |
| `CYLSearchBarView.cursorColor` | The color of the text cursor (MaterialSearchView `setCursorDrawable`). The tint color by default. | TODO |
| `CYLSearchBarView.fieldHeight` | The height of the field; it grows when the scaled text needs more. 36 by default. | TODO |
| `CYLSearchBarView.contentInsets` | The space around the field. (6, 12, 6, 12) by default. | TODO |
| `CYLSearchBarView.fieldBackgroundColor` | The field's background. `tertiarySystemFillColor` by default. | TODO |
| `CYLSearchBarView.fieldCornerRadius` | The field's corner radius; negative makes a capsule. -1 by default. | TODO |
| `CYLSearchBarView.fieldBorderColor` | The field's border color; nil draws no border. | TODO |
| `CYLSearchBarView.fieldBorderWidth` | The field's border width, used with `fieldBorderColor`. 0 by default. | TODO |
| `CYLSearchBarView.fieldShadowOpacity` | The field's shadow, 0 to 1. 0 by default. | TODO |
| `CYLSearchBarView.searchIcon` | The magnifier; nil shows none. `magnifyingglass` by default. | TODO |
| `CYLSearchBarView.searchIconTintColor` | The magnifier's tint. `secondaryLabelColor` by default. | TODO |
| `CYLSearchBarView.trailingAccessoryViews` | Views of yours inside the field after the text, scaled down when they would squeeze it. | TODO |
| `CYLSearchBarView.leadingView` | A view of yours before the field (a back button); it wins over the navigation button. | TODO |
| `CYLSearchBarView.showsCancelButton` | Shows the Cancel button after the field. NO by default. | TODO |
| `CYLSearchBarView.cancelButtonTitle` | The Cancel title. The localized "Cancel" by default. | TODO |
| `CYLSearchBarView.cancelButtonEndsEditing` | Taps on Cancel also end editing and clear nothing. YES by default. | TODO |
| `CYLSearchBarView.clearsTextOnCancel` | Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). NO by default. | TODO |
| `CYLSearchBarView.clearsTextOnEndEditing` | Ending editing also clears the text (lapism `setTextClearOnClearFocus`). NO by default. | TODO |
| `CYLSearchBarView.navigationIcon` | A built-in navigation icon. `CYLSearchBarNavigationIconNone` by default. | TODO |
| `CYLSearchBarView.navigationImage` | A custom navigation icon; it wins over `navigationIcon`. | TODO |
| `CYLSearchBarView.navigationAccessibilityLabel` | What VoiceOver reads for the navigation button. Defaults to "Back" for the arrow and "Search" for the magnifier. | TODO |
| `CYLSearchBarView.navigationBackgroundColor` | A circle drawn behind the navigation icon. Nil (none) by default. | TODO |
| `CYLSearchBarView.navigationShadowOpacity` | The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default. | TODO |
| `CYLSearchBarView.navigationHandler` | Called on taps on the navigation button, after the delegate. | TODO |
| `CYLSearchBarView.showsVoiceButton` | Shows `voiceButton` while the text is empty. NO by default. | TODO |
| `CYLSearchBarView.voiceImage` | The voice button's icon. `mic` by default. | TODO |
| `CYLSearchBarView.showsSubmitButton` | Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). NO by default. | TODO |
| `CYLSearchBarView.submitImage` | The submit button's icon. `arrow.forward.circle.fill` by default. | TODO |
| `CYLSearchBarView.clearImage` | A custom clear button icon, shown while editing with text. Nil keeps the system clear button. | TODO |
| `CYLSearchBarView.keyboardType` | The keyboard type (Android `inputType`). `UIKeyboardTypeDefault` by default. | TODO |
| `CYLSearchBarView.returnKeyType` | The return key (Android `imeOptions`). `UIReturnKeySearch` by default. | TODO |
| `CYLSearchBarView.autocapitalizationType` | Automatic capitalization. `UITextAutocapitalizationTypeSentences` by default. | TODO |
| `CYLSearchBarView.autocorrectionType` | Automatic correction. `UITextAutocorrectionTypeDefault` by default. | TODO |
| `CYLSearchBarView.isSecureTextEntry` | Hides the typed characters (Android `inputType="textPassword"`). NO by default. | TODO |
| `CYLSearchBarView.maximumTextLength` | The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default. | TODO |
| `CYLSearchBarView.isIconified` | Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens the field and starts editing. NO by default. | TODO |
| `CYLSearchBarView.iconifiedByDefault` | When YES, the field closes back to its icon when editing ends with no text (Android `setIconifiedByDefault`). NO by default. | TODO |
| `CYLSearchBarView.expansionAnimation` | How the field opens and closes. `CYLSearchBarExpansionAnimationFade` by default. | TODO |
| `CYLSearchBarView.iconPosition` | Where `iconButton` sits while iconified; the field opens from there. `CYLSearchBarIconPositionTrailing` by default. | TODO |
| `CYLSearchBarView.animationDuration` | The length of the opening and closing animations, in seconds. 0.3 by default. | TODO |
| `CYLSearchBarView.init(frame:)` | — | TODO |
| `CYLSearchBarView.init(coder:)` | — | TODO |
| `CYLSearchBarView.setText(_:submit:)` | Sets the text and, when `submit` is YES and the text is not empty, submits it as if the Search key were tapped (MaterialSearchView `setQuery`, lapism `setTextQuery`). | TODO |
| `CYLSearchBarView.submit()` | Submits the current text: asks `-searchBarView:shouldSubmitText:`, then calls `-searchBarViewSearchButtonClicked:`. Returns NO when the text is empty or the delegate refused it. | TODO |
| `CYLSearchBarView.showKeyboard()` | Starts editing and shows the keyboard. | TODO |
| `CYLSearchBarView.hideKeyboard()` | Ends editing and hides the keyboard. | TODO |
| `CYLSearchBarView.setIconified(_:animated:)` | Opens or closes the field, with `expansionAnimation` when `animated` is YES. Opening also starts editing. | TODO |
| `CYLSearchBarView.encodeRestorableState(with:)` | Saves the text, whether it is editing and whether it is iconified (`onSaveInstanceState`). | TODO |
| `CYLSearchBarView.decodeRestorableState(with:)` | Restores the text, the iconified state and editing (`onRestoreInstanceState`). | TODO |
| `CYLSearchBarView.traitCollectionDidChange(_:)` | — | TODO |
| `CYLSearchBarView.intrinsicContentSize` | — | TODO |
| `CYLSearchBarView.sizeThatFits(_:)` | — | TODO |
| `CYLSearchBarView.layoutSubviews()` | — | TODO |
| `CYLSearchBarView.textFieldShouldBeginEditing(_:)` | Asks the delegate whether editing may start; a refusal reports a tap instead. | TODO |
| `CYLSearchBarView.textFieldShouldReturn(_:)` | The return key submits the text. | TODO |
| `CYLSearchBarView.textField(_:shouldChangeCharactersIn:replacementString:)` | Enforces `maximumTextLength`; deleting is always allowed. | TODO |
| `CYLSearchBarView.textFieldDidBeginEditing(_:)` | Reports the start of editing. | TODO |
| `CYLSearchBarView.textFieldDidEndEditing(_:)` | Clears the text and closes to the icon when configured, then reports the end of editing. | TODO |
| `CYLSearchBarView.becomeFirstResponder()` | Starts editing in the text field. | TODO |
| `CYLSearchBarView.resignFirstResponder()` | Ends editing; the bar itself also gives up first responder as UIKit expects. | TODO |
| **protocol `CYLSearchControllerDelegate`** | Events of a `CYLSearchController`. | TODO |
| `CYLSearchControllerDelegate.-searchControllerDidCancel:` | Cancel was tapped and the overlay is gone. | TODO |
| **class `CYLSearchController`** | An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController`. Keep the controller while it is presented. | TODO |
| `CYLSearchController.delegate` | Receives the cancel event. | TODO |
| `CYLSearchController.resultsViewController` | The results controller shown inside the overlay. | TODO |
| `CYLSearchController.presented` | YES while the overlay is on screen or animating in. | TODO |
| `CYLSearchController.init(searchDataSource:)` | Creates the overlay with the data source of its results. | TODO |
| `CYLSearchController.init(nibName:bundle:)` | Not available: use `init(searchDataSource:)`. | TODO |
| `CYLSearchController.init(coder:)` | Not available: use `init(searchDataSource:)`. | TODO |
| `CYLSearchController.viewDidLoad()` | — | TODO |
| `CYLSearchController.show(in:)` | Adds a child navigation controller to the host and animates it into view. | TODO |
| `CYLSearchController.hide(_:)` | Completion is called after the overlay is removed, including when not presented. | TODO |
| **enum `CYLSearchPlaceholderKind`** | The common placeholder kinds: an empty list, no search results, or an error. | TODO |
| `CYLSearchPlaceholderKind.empty` | Nothing to show yet. | TODO |
| `CYLSearchPlaceholderKind.noResults` | The search found nothing. | TODO |
| `CYLSearchPlaceholderKind.error` | Loading failed. | TODO |
| **enum `CYLSearchPlaceholderStyle`** | The image of a placeholder; each style has an image in the resource bundle. | TODO |
| `CYLSearchPlaceholderStyle.empty` | The Empty placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.noResults` | The NoResults placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.error` | The Error placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.wifiOff` | The WifiOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.signalWifiOff` | The SignalWifiOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.noInternet` | The NoInternet placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.cloudOff` | The CloudOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.syncProblem` | The SyncProblem placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.syncDisabled` | The SyncDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.networkLocked` | The NetworkLocked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.bluetoothDisabled` | The BluetoothDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.locationOff` | The LocationOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.publicOff` | The PublicOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.errorOutline` | The ErrorOutline placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.warning` | The Warning placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.reportProblem` | The ReportProblem placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.blocked` | The Blocked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.help` | The Help placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.hourglass` | The Hourglass placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.locked` | The Locked placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.visibilityOff` | The VisibilityOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.searchOff` | The SearchOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.folderOff` | The FolderOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.folderOpen` | The FolderOpen placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.downloadOff` | The DownloadOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.uploadOff` | The UploadOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.inbox` | The Inbox placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.brokenImage` | The BrokenImage placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.imageUnavailable` | The ImageUnavailable placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.photoLibrary` | The PhotoLibrary placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.musicOff` | The MusicOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.videoOff` | The VideoOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.personOff` | The PersonOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.groupOff` | The GroupOff placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.eventBusy` | The EventBusy placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.emptyCart` | The EmptyCart placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.favorite` | The Favorite placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.batteryAlert` | The BatteryAlert placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.unknownDevice` | The UnknownDevice placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.phoneDisabled` | The PhoneDisabled placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.wrongLocation` | The WrongLocation placeholder image. | TODO |
| `CYLSearchPlaceholderStyle.count` | The Count placeholder image. | TODO |
| **enum `CYLSearchPlaceholderMessage`** | The localized message of a placeholder. | TODO |
| `CYLSearchPlaceholderMessage.empty` | "No data". | TODO |
| `CYLSearchPlaceholderMessage.noResults` | "No matching results". | TODO |
| `CYLSearchPlaceholderMessage.error` | "Something went wrong". | TODO |
| `CYLSearchPlaceholderMessage.network` | "Check your internet connection". | TODO |
| **class `CYLSearchPlaceholderView`** | An image above a message, centered in its bounds: the empty, no-result and error states of a list. | TODO |
| `CYLSearchPlaceholderView.imageView` | The image, 80 × 80 points, tinted with `secondaryLabelColor` (except the colored empty image). | TODO |
| `CYLSearchPlaceholderView.textLabel` | The message, in the body text style with Dynamic Type. | TODO |
| `CYLSearchPlaceholderView.imageName(for:)` | The name of the image of `style` in the resource bundle. | TODO |
| `CYLSearchPlaceholderView.init(kind:)` | A placeholder of a common kind with its built-in image and message. | TODO |
| `CYLSearchPlaceholderView.init(style:message:)` | A built-in image with a built-in message. | TODO |
| `CYLSearchPlaceholderView.init(style:text:)` | A built-in image with your own text. | TODO |
| `CYLSearchPlaceholderView.init(image:message:)` | Your own image with a built-in message. | TODO |
| `CYLSearchPlaceholderView.init(image:text:)` | Your own image and text. | TODO |
| **class `CYLSearchResources`** | Images and localized strings of `CYLSearchViewController.bundle`, the resource bundle of this pod. | TODO |
| `CYLSearchResources.resourceBundle` | The resource bundle, found next to this class's framework or in the main bundle; nil when it is missing. | TODO |
| `CYLSearchResources.image(named:)` | An image of the resource bundle, or nil (logged) when it is missing. | TODO |
| `CYLSearchResources.localizedString(forKey:)` | The text of `key` in the language the app shows (the preferred languages), English when the key has no translation, or the key itself (logged) when it is missing everywhere. | TODO |
| `CYLSearchResources.localizedString(forKey:language:)` | The text of `key` in `language` (for example "zh-Hans"), or in the preferred languages when `language` is nil. | TODO |
| **protocol `CYLSearchResultsDataSource`** | Supplies the results of a `CYLSearchResultsViewController` and configures their cells. | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:resultsForQuery:` | The results for `query` (an empty string while nothing is typed). | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:configureCell:withResult:` | Shows `result` in `cell`. | TODO |
| `CYLSearchResultsDataSource.-searchResultsViewController:didSelectResult:` | A result was tapped. | TODO |
| **class `CYLSearchResultsViewController`** | A table of search results with a search bar in its navigation item, driven by a `CYLSearchResultsDataSource`. The search bar stays pinned under the title, and the view starts below it, so the bar never covers the list. | TODO |
| `CYLSearchResultsViewController.searchDataSource` | The data source given at creation. | TODO |
| `CYLSearchResultsViewController.searchController` | The search controller installed in the navigation item. | TODO |
| `CYLSearchResultsViewController.searchResults` | The results of the last query. | TODO |
| `CYLSearchResultsViewController.init(searchDataSource:)` | Creates the controller with its data source (plain table style). | TODO |
| `CYLSearchResultsViewController.init(style:)` | Not available: use `init(searchDataSource:)`. | TODO |
| `CYLSearchResultsViewController.init(nibName:bundle:)` | Not available: use `init(searchDataSource:)`. | TODO |
| `CYLSearchResultsViewController.init(coder:)` | Not available: use `init(searchDataSource:)`. | TODO |
| `CYLSearchResultsViewController.viewDidLoad()` | — | TODO |
| `CYLSearchResultsViewController.reloadSearchResults()` | Requeries the data source using the current search text and reloads the table. | TODO |
| `CYLSearchResultsViewController.reloadResultsTableView()` | Override to integrate a custom table reload, such as an empty-state provider. | TODO |
| `CYLSearchResultsViewController.updateSearchResults(for:)` | Requeries the results when the search text changes. | TODO |
| `CYLSearchResultsViewController.tableView(_:numberOfRowsInSection:)` | — | TODO |
| `CYLSearchResultsViewController.tableView(_:cellForRowAt:)` | — | TODO |
| `CYLSearchResultsViewController.tableView(_:didSelectRowAt:)` | — | TODO |
| **enum `CYLSearchSuggestionStyle`** | How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`). | TODO |
| `CYLSearchSuggestionStyle.list` | One suggestion per row with its icon, in `suggestionsTableView`. | TODO |
| `CYLSearchSuggestionStyle.tags` | Tags that wrap like words, in `suggestionsTagView` (CollectionViewClassifyMenu's `CYLTagListView`). | TODO |
| **protocol `CYLSearchViewDelegate`** | Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. | TODO |
| `CYLSearchViewDelegate.-searchViewDidShow:` | The search view finished opening (MaterialSearchView `onSearchViewShown`). | TODO |
| `CYLSearchViewDelegate.-searchViewDidClose:` | The search view finished closing (MaterialSearchView `onSearchViewClosed`). | TODO |
| `CYLSearchViewDelegate.-searchView:textDidChange:` | The query changed (`onQueryTextChange`). | TODO |
| `CYLSearchViewDelegate.-searchView:didSubmitText:` | The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open; return NO (or leave this method out) to let the search view close. | TODO |
| `CYLSearchViewDelegate.-searchView:didChangeFocus:` | The field started or stopped editing (lapism `OnFocusChangeListener`). | TODO |
| `CYLSearchViewDelegate.-searchView:didSelectSuggestion:atIndex:` | A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is submitted when `submitsOnSuggestionSelection` is YES. | TODO |
| `CYLSearchViewDelegate.-searchViewVoiceButtonClicked:` | The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`. | TODO |
| `CYLSearchViewDelegate.-searchViewNavigationButtonClicked:` | The navigation button (the back arrow by default) was tapped. Without this method it closes the search view. | TODO |
| **class `CYLSearchView`** | A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list of suggestions filtered as you type, and an optional content view of yours below (MiguelCatalan and lapism `MaterialSearchVi… | TODO |
| `CYLSearchView.delegate` | Receives the events of the search view. | TODO |
| `CYLSearchView.searchBarView` | The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button). | TODO |
| `CYLSearchView.dividerView` | The line under the search bar. | TODO |
| `CYLSearchView.suggestionsTableView` | The table that lists the suggestions. | TODO |
| `CYLSearchView.suggestionsTagView` | The tags that show the suggestions when `suggestionStyle` is `CYLSearchSuggestionStyleTags` (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: `style`, spacing, rows, colors. | TODO |
| `CYLSearchView.suggestionStyle` | How the suggestions are shown: a list (`CYLSearchSuggestionStyleList`, the default) or tags (`CYLSearchSuggestionStyleTags`). A tapped tag works like a tapped row. | TODO |
| `CYLSearchView.showsEmptyResultsPlaceholder` | Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles. NO by default. | TODO |
| `CYLSearchView.emptyResultsScenario` | The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state. | TODO |
| `CYLSearchView.emptyResultsView` | The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`. | TODO |
| `CYLSearchView.dividerColor` | The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it. | TODO |
| `CYLSearchView.contentView` | A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. Nil by default. | TODO |
| `CYLSearchView.scrimColor` | The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself uses `backgroundColor`, `systemBackgroundColor` by default. | TODO |
| `CYLSearchView.suggestions` | The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`). | TODO |
| `CYLSearchView.suggestionFilter` | Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES. | TODO |
| `CYLSearchView.showsSuggestionsForEmptyQuery` | Lists every suggestion while the query is empty. NO by default. | TODO |
| `CYLSearchView.filteredSuggestions` | The suggestions that match the current query, in their original order. | TODO |
| `CYLSearchView.suggestionImage` | The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil shows none. | TODO |
| `CYLSearchView.suggestionImageTintColor` | The tint of `suggestionImage`. `secondaryLabelColor` by default. | TODO |
| `CYLSearchView.suggestionBackgroundColor` | The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background. | TODO |
| `CYLSearchView.suggestionTextColor` | The color of the suggestion text. `labelColor` by default. | TODO |
| `CYLSearchView.suggestionLineBreakMode` | How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis. | TODO |
| `CYLSearchView.submitsOnSuggestionSelection` | Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the person can edit it. | TODO |
| `CYLSearchView.suggestionCellConfiguration` | Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional. | TODO |
| `CYLSearchView.searchOpen` | YES while the search view is open (MaterialSearchView `isSearchOpen`). | TODO |
| `CYLSearchView.animationDuration` | The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default. | TODO |
| `CYLSearchView.closesOnSubmit` | Closes the search view after a submitted query that the delegate did not handle. YES by default. | TODO |
| `CYLSearchView.query` | The current query (lapism `getTextQuery`). | TODO |
| `CYLSearchView.backgroundColor` | The page background (the view itself only shows the scrim). `systemBackgroundColor` by default. | TODO |
| `CYLSearchView.init(frame:)` | — | TODO |
| `CYLSearchView.init(coder:)` | — | TODO |
| `CYLSearchView.layoutSubviews()` | — | TODO |
| `CYLSearchView.safeAreaInsetsDidChange()` | — | TODO |
| `CYLSearchView.install(in:)` | Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key window's root view when the search view has no superview. | TODO |
| `CYLSearchView.showSearch()` | Opens the search view with animation and starts editing (`showSearch`). | TODO |
| `CYLSearchView.showSearch(animated:)` | Opens the search view and starts editing (`showSearch(animate)`). | TODO |
| `CYLSearchView.closeSearch()` | Closes the search view with animation and ends editing (`closeSearch`). | TODO |
| `CYLSearchView.closeSearch(animated:)` | Closes the search view and ends editing. | TODO |
| `CYLSearchView.encodeRestorableState(with:)` | Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a `restorationIdentifier` inside a restored view controller. | TODO |
| `CYLSearchView.decodeRestorableState(with:)` | Restores the query and reopens the search view when it was open (`onRestoreInstanceState`). | TODO |
| `CYLSearchView.accessibilityPerformEscape()` | — | TODO |
| `CYLSearchView.attach(to:)` | Makes a bar button item open the search view (`setMenuItem`). | TODO |
| `CYLSearchView.setQuery(_:submit:)` | Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`). | TODO |
| `CYLSearchView.showSuggestions()` | Lists the suggestions that match the current query (`showSuggestions`). | TODO |
| `CYLSearchView.dismissSuggestions()` | Hides the suggestions (`dismissSuggestions`). | TODO |
| `CYLSearchView.searchBarView(_:textDidChange:)` | Filters the suggestions and reports the change. | TODO |
| `CYLSearchView.searchBarViewSearchButtonClicked(_:)` | Reports the submitted query and closes unless the delegate handled it. | TODO |
| `CYLSearchView.searchBarViewNavigationButtonClicked(_:)` | Reports the navigation button, or closes the search view. | TODO |
| `CYLSearchView.searchBarViewVoiceButtonClicked(_:)` | Reports the voice button. | TODO |
| `CYLSearchView.searchBarViewCancelButtonClicked(_:)` | Cancel closes the search view. | TODO |
| `CYLSearchView.searchBarViewDidBeginEditing(_:)` | Reports focus. | TODO |
| `CYLSearchView.searchBarViewDidEndEditing(_:)` | Reports the loss of focus. | TODO |
| `CYLSearchView.tableView(_:numberOfRowsInSection:)` | One row per matching suggestion while the suggestions are shown. | TODO |
| `CYLSearchView.tableView(_:cellForRowAt:)` | A suggestion row: icon, text, background, then `suggestionCellConfiguration`. | TODO |
| `CYLSearchView.tableView(_:didSelectRowAt:)` | Fills the field with the suggestion, reports it, and submits it when `submitsOnSuggestionSelection` is YES. | TODO |
<!-- harmonyos-api-alignment:end -->
