> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Test index (738 test names found in 78 files)

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.
Names only; **no test was run** in this pass.

## `android/iammert-MultiSearchView/app/src/androidTest/java/com/iammert/library/ui/multisearchview/ExampleInstrumentedTest.kt` (1)

- L19 useAppContext

## `android/iammert-MultiSearchView/app/src/test/java/com/iammert/library/ui/multisearchview/ExampleUnitTest.kt` (1)

- L14 addition_isCorrect

## `android/merged/app/src/test/kotlin/com/cyl/search/example/contacttags/CYLContactTagStoreTest.kt` (3)

- L25 bundledDataHasIdsAndEveryLanguageHasTheSameKeys
- L44 searchCreateRenameAndDeleteKeepIds
- L70 serverSectionsApplyAndCacheASurvivesALaunch

## `android/merged/app/src/test/kotlin/com/cyl/search/example/CYLBackdropSourceTest.kt` (2)

- L28 everyNestedTagListGetsThePlateAsItsBackdropSource
- L54 theExamplePagesSetTheBackdropSourceAndDrawTheGradientOnlyOnThePlate

## `android/merged/app/src/test/kotlin/com/cyl/search/example/CYLSearchDiscoverDataTest.kt` (4)

- L27 theFirstScreenIsThePageZero
- L35 refreshShowsTheNextPageCyclically
- L48 everyPageHasOneHotRecordAndItsSlotMovesFromPageToPage
- L63 anEmptyPoolHasNoPages

## `android/merged/app/src/test/kotlin/com/cyl/search/example/CYLSearchPortScreensTest.kt` (6)

- L74 keywordsAndMatchesAreQMUIs
- L91 searchControllerConfiguresTheCoreThroughTheApiOnly
- L149 searchBarStylesRowsDriveTheBar
- L194 shortListScrollsTheBarOutAndSnaps
- L205 menuListsTheNewScreens
- L215 everyTextOfTheScreensExistsInFourLanguages

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarDefaultColorsTest.kt` (5)

- L43 lightModeDefaults
- L56 darkModeDefaults
- L67 aHostTintAndPlaceholderColorWin
- L80 theDividerIsOneByTwenty
- L91 aLiveSwitchReResolvesTheColorsAndNothingDisappears

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarEditingBarTest.kt` (1)

- L26 editingBarSubmitsTrimmedTextAndPinsToTheContainer

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarEmbedInToolbarTest.kt` (5)

- L39 embeddedBarAsksForTheWholeWidthLeftBesideTheBackArrow
- L60 aPlainBarKeepsItsOwnLayoutParams
- L67 withoutAToolbarTheCoreCreatesOneAtTheTopOfTheContent
- L80 theCapsuleStartsWhereTheToolbarContentStartsAfterABackArrowAndOnTheTagInsetWithout
- L109 aHostShorterThanTheFieldKeepsAllFourEdgesOfTheField

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarFirstLevelTest.kt` (9)

- L37 firstLevelBarFillsTheWholeWidthWithoutBackButton
- L45 showAndHideBackButtonWithoutAnimationSwitchTheStateAndTheInset
- L60 progressByHandMovesTheNavigationIconAndTheInset
- L72 animatedStateEndsWhereTheUnanimatedOneIs
- L85 tapOnTheFieldPushesAndShowsTheBackButton
- L99 withoutAHandlerATapDoesNothingSpecial
- L107 theBackButtonCallsTheHandler
- L117 interceptingATouchOverTheFieldIsOffWithoutAHandler
- L125 theWholeFieldBesideACenteredPlaceholderIsTheTapTargetButItemsAreNot

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarFlatLookTest.kt` (2)

- L26 borderedFieldIsWhiteWithTheVisibleSecondaryLabelBorder
- L35 embeddedBarFitsTheFortyFourDpNavigationBarSlot

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarFocusesOnAppearTest.kt` (7)

- L34 offByDefaultNeverFocuses
- L43 focusesOnFirstEntryAndEveryReattach
- L59 firstLevelPageNeverFocuses
- L73 focusesWhenBecomingVisibleAgain
- L88 focusesWhenTheActivityResumes
- L103 turningItOnWhileOnScreenFocusesAtOnce
- L113 theDepthComesFromTheFragmentBackStackByDefault

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarItemTest.kt` (2)

- L39 itemsFollowTheAnimatedItemDisplayPriority
- L63 itemsAreAppendedLikeFlatDesignTabBarItems

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarMultipleModeBackTest.kt` (2)

- L21 backCompletesTypingOnlyWhileTyping
- L35 singleModeNeverTakesTheBackGesture

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarNavigationFieldStyleTest.kt` (1)

- L26 presetSetsTheDiscoverLook

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarQMUIPortTest.kt` (10)

- L69 placeholderIsCenteredAtRestAndLeadingWhileEditing
- L94 fieldMarginsApplyPerStateAndTheProviderWins
- L113 cancelMarginsFontAndTheNegativeValueNeverCoverTheField
- L131 cancelShowsAndHidesAnimatedOrNot
- L154 cancelAppearsWhileEditingWhenAsked
- L167 accessoryViewsShowHideAndShrinkTheField
- L221 oldAccessoryNamesForwardToTheOneSlot
- L250 defaultAppearanceLandsOnTheBar
- L269 darkAppearanceUsesTheDarkField
- L274 shortGapsKeepTheBarFromCoveringAnything

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarSearchButtonTest.kt` (8)

- L46 theBarKeepsAnIconButtonByDefaultAndTheTextStyleIsOptIn
- L61 aDividerPrecedesTheButtonOnlyWhenAnItemDoes
- L69 hidingAndTheEditingAndMultipleBarsLeaveNoButton
- L81 aTapSubmitsTheTextAndTellsTheDelegateAlsoForEmptyText
- L94 theHandlerReplacesTheDefaultAction
- L106 theTitleAndStyleRebuildTheButton
- L125 theItemGainedCornerRadiusBorderAndHeight
- L135 theIconPillIsConcentricInTheField

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBarTrailingGroupTest.kt` (4)

- L54 gapsBesideTheDividerAreEqual
- L69 aPlainIconItemHugsItsGlyphAndTheCapsuleKeepsItsSize
- L79 aTouchBesideTheGlyphWithin36DpReachesTheItem
- L125 aTapBesideTheFirstItemThroughTheBarReachesItsClickHandler

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBehaviorTest.kt` (16)

- L63 suggestionsFilterIgnoringCaseAndDiacritics
- L78 submitClosesUnlessTheDelegateHandlesIt
- L101 navigationButtonClosesByDefault
- L110 selectingASuggestionFillsTheQuery
- L130 searchBarSubmitAsksTheDelegateAndSkipsBlankText
- L148 searchBarLimitsTheTextAndReportsTyping
- L165 searchBarIconifiedShowsOnlyTheButton
- L183 multipleModeCompletesSelectsAndRemoves
- L227 multipleModeSharesTheBarProperties
- L241 resources
- L262 resultsDataSourceListsResultsInsteadOfSuggestions
- L307 focusAloneChangesNothingBelowTheResults
- L321 refreshApiOfTheResultsList
- L349 refreshApiOfAnotherScrollView
- L380 showSearchInAHostAndCloseWithACompletion
- L403 emptyResultsShowTheCYLTableViewPlaceHolderPlaceholder

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchControllerAlignmentTest.kt` (16)

- L58 aBackgroundImageIsTheColorWithABottomBorder
- L70 theAppearanceDrawsTheBarBackground
- L94 aBarWithoutAnyBackgroundIsTransparentUnlessItsStyleSaysOtherwise
- L104 theFieldTakesTheBackgroundImageOfTheStyle
- L112 theCancelButtonStaysEnabledUnlessTheFieldMustBeEdited
- L123 scopeTitlesMakeASegmentedControlThatTheBarGrowsFor
- L138 theBackgroundViewIsTheBarAndTheHeaderFlagIsOffByDefault
- L147 theBuiltInLaunchViewShowsTheSuggestionsOfAnEmptyQuery
- L162 aLaunchViewOfYoursReplacesTheBuiltInOne
- L170 theResultsListEvenForAnEmptyQueryWhenTheyAlwaysShow
- L182 alwaysShowingTheResultsClearsTheLaunchViews
- L191 theResultsHeaderIsOneRowAboveTheResults
- L209 theCacheFooterIsAButtonBelowTheListOfSuggestions
- L223 theResultsTableViewIsHandedOverOnce
- L238 theHeaderBarOfAListOpensTheSearchAndSettles
- L260 aNavigationBarHoldsTheSearchBarAndForwardsTheBackTap

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchFoldControlTest.kt` (2)

- L80 tenSuggestionsFoldToTwoRowsAndTheLastTagIsTheFoldControl
- L118 eightSuggestionsFitTwoRowsSoThereIsNothingToFoldAndNoControl

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchListViewTest.kt` (6)

- L65 barIsTheFirstItemAndScrollsWithTheRows
- L79 shortListGetsTheRoomToScrollTheBarOutAndSnaps
- L103 withoutSnappingAShortListCannotScrollTheBarOut
- L112 hidesSearchBarInitiallyScrollsTheBarOut
- L120 emptyViewRemovesTheBarAndHidingItPutsItBackHidden
- L139 aTapOnTheBarOpensTheSearchViewOrEditsInPlace

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchMergePhase5bTest.kt` (8)

- L62 theInsetsAreOnlyThePartOfTheBarsThatLiesOverTheView
- L84 aViewAtTheTopOfTheWindowKeepsTheFullInsets
- L95 theInsetsAreAppliedAgainWhenTheViewMoves
- L111 cancelButtonFontCarriesASize
- L125 theTagsAreFilledAgainOnceThePageHasAWidth
- L143 theTrashButtonReachesTheHistoryListener
- L163 noResultsTextIsTheOnlyEmptyViewEvenWithTheScenarioPlaceholderOn
- L181 aTappedTagReportsTextDidChangeBeforeTheSubmit

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchMergePhase5Test.kt` (11)

- L87 oneSlotHoldsEveryEmptyViewOfTheSearchView
- L109 theSlotKeepsItsViewInTheHostAndTakesItOut
- L136 theMatchIgnoresCaseAndDiacritics
- L152 highlightIsOffByDefaultAndTakesTheTintOrYourColor
- L170 aReusedRowDoesNotKeepTheHighlightOfAnotherQuery
- L192 noResultsTextShowsTheEmptyViewWhileNothingIsListed
- L215 anotherViewOfTheSameHistoryRefreshesAnOpenViewAndReachesTheListeners
- L242 aStoreOfYourOwnIsAnnouncedByTheCoreAndMatchedByIdentity
- L266 theViewsOwnSubmitIsNotListedAgainBySignal
- L279 aTappedSuggestionSubmitsAndTheResultsFollow
- L306 everyWayToCloseSendsWillAndDidOnce

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchSuggestionCacheTest.kt` (8)

- L25 everyPolicyKeepsSubmittedQueriesNewestFirst
- L53 theSearchViewCachesSubmittedQueriesAndClearsThemFromTheHeader
- L89 focusesSearchFieldOnShowDecidesWhenTheKeyboardAppears
- L104 focusAloneChangesNothingBelowTheSearchBar
- L130 tagSuggestionsEndWithTheFoldButtonByDefault
- L176 suggestionsAreTagsFoldedToTwoRowsByDefaultAndTheLastTagIsTheFoldControl
- L213 tagSuggestionsThatFitTheFoldedRowsShowNoFoldControl
- L224 theListStyleStaysAvailable

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchTagListStyleTest.kt` (11)

- L33 defaultsAreTheIosRecentSearchesLook
- L50 glassTagsAreATranslucentTintWithoutBorder
- L63 glassByNameClearsTheFillSoTheFrostedTintDraws
- L77 backgroundStyleNamesMatchIos
- L85 theRadiusAndAnyOtherValueCanBeCustomized
- L95 flatTagsAreWhiteWithTheIosSeparatorBorder
- L106 theGridIsBorderlessLikeTheIosDiscoverTopicsAndShowsImagesAtTheirOwnSize
- L115 theGridKeepsTitlesAndIconsOffTheRimLikeTheDefaultStyleFlatAndGlass
- L132 theGridKeepsTheHeaderLookAndOneRowPerThirtySixDp
- L143 darkAppearanceUsesTheLabelColorAndADarkFill
- L155 lightAppearanceAndNoContextKeepTheBlackLabel

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchViewEmptySearchButtonTest.kt` (3)

- L54 emptyButtonTapDoesNothingInASearchView
- L65 buttonTapWithTextStillSubmitsAndRecords
- L75 aPlainBarStillTellsItsDelegateForEmptyText

## `android/merged/cylsearch/src/test/kotlin/com/cyl/search/CYLSearchViewQMUIPortTest.kt` (10)

- L74 resultsCallbackAlsoReceivesTheEmptyText
- L92 presentationCallbacksAndIsActive
- L110 launchViewShowsWhileTheQueryIsEmptyAndWinsOverTheHistory
- L131 dimmingColorIsTheScrimAndATapEndsTheSearch
- L150 emptyViewShowsOnlyWithTextAndLeavesWithTheSearch
- L175 submittedQueriesAreTheHistoryAndNotifyTheListeners
- L200 backSwipeDragsThePageAndCompletingEndsTheSearch
- L220 withoutTheSwitchTheBackSwipeDoesNotMoveThePage
- L231 backGoesToAPageThatCoversTheOpenSearch
- L265 searchBarMaxYIsTheBottomOfTheBar

## `CrossPlatform/flutter_cylsearch/example/ios/RunnerTests/RunnerTests.swift` (1)

- L16 testGetPlatformVersion

## `CrossPlatform/flutter_cylsearch/example/test/discover_data_test.dart` (4)

- L7 the language folder follows the locale as the native .lproj choice does
- L16 .strings lines parse, with %@ arguments
- L21 the bundled data loads; refresh shows the next page and the hot topic moves
- L41 the example texts: a known English label is looked up, any other text stays as it is

## `CrossPlatform/flutter_cylsearch/example/test/discover_platform_test.dart` (3)

- L8 the status bar icons are dark on the pale light gradient and light on the dark one
- L18 the app bar foreground follows the theme brightness over the gradient
- L23 the Discover page opens with Liquid Glass tag lists and a bar embedded in the navigation bar with its back button

## `CrossPlatform/flutter_cylsearch/example/test/qmui_screens_test.dart` (2)

- L6 the results are the matching keywords, twenty rows each, case sensitive
- L13 every text of the two screens exists in four languages

## `CrossPlatform/flutter_cylsearch/test/cyl_created_update_test.dart` (4)

- L46 tag list: tags set before the native view exists reach it
- L56 placeholder: text set before the native view exists reaches it
- L65 search bar: placeholder set before the native view exists reaches it
- L74 search view: placeholder set before the native view exists reaches it

## `CrossPlatform/flutter_cylsearch/test/cyl_merge_p5_test.dart` (4)

- L44 several trailing widgets sit in order after the native field
- L65 setQuery goes to the native page, with and without submit
- L77 a text change from a tapped tag reaches onTextChanged and the query that hides the launch widget
- L98 the history signal comes from the native store: Dart adds no event of its own

## `CrossPlatform/flutter_cylsearch/test/cyl_qmui_port_test.dart` (14)

- L40 sends the style options and the margins of both states
- L65 accessory widgets sit beside the native field and follow the controller
- L97 Cancel is shown or hidden through the native view
- L113 sends the highlight switch
- L118 the launch view shows under the bar while the query is empty and reads the history again
- L153 the scrim, the swipe, the highlight color and the empty text go to the native page
- L170 the callbacks follow the native events: will and did show, will close, close
- L202 no Dart overlay is built for the scrim, the empty view or the swipe
- L236 the bar is the first item and covers no row
- L243 hidesSearchBarInitially starts with the bar scrolled out
- L249 a short list lets the bar scroll out, and half way settles fully hidden or shown (#1160)
- L263 without snapping a short list cannot scroll the bar out
- L269 an empty view replaces the rows and takes the bar away; the bar returns hidden
- L280 a tap on the bar calls onSearchBarTap

## `CrossPlatform/flutter_cylsearch/test/cyl_search_view_test.dart` (22)

- L10 sends every parameter with the iOS names
- L52 the native view follows the app brightness
- L57 defaults match the native defaults
- L75 native events reach the callbacks
- L91 sends the results and the refresh switch, and reports result taps and pulls
- L108 the controller calls the refresh and results methods of the native view
- L131 builds the native view of its platform
- L144 focusesOnAppear is off by default and travels in the parameters
- L152 sends its parameters and forwards its events
- L204 default search button: shown by default, style, title and handler are sent, a tap calls searchButtonHandler
- L221 first-level bar: pushesOnTap and the animated back button are sent, a tap calls onFirstLevelTap
- L236 appends items like the FlatDesign tab bar and reports their taps
- L272 an item sends its animation file, loops and speed
- L287 multiple mode sends its searches and forwards the search events
- L308 the controller calls the multiple-search methods of the native bar
- L346 a controller is attached to the native view and detached on dispose
- L362 CYLTagListView sends its tags and reports taps and its height
- L392 CYLTagListView sends ids, selection and editing, and reports the editing events by id
- L425 CYLSearchBarView sends the editing bar and reports its submit
- L443 CYLPlaceholderView sends its style and text
- L448 the tag list platform view joins the gesture arena with a long press recognizer
- L461 CYLTagListView reports the drag state of the native list

## `CrossPlatform/react-native-cylsearch/src/__tests__/index.test.tsx` (22)

- L37 sends the items without their handlers
- L55 sends the animation options of an item
- L75 calls the tapped item with its selected state
- L88 lists results only when they are given, unless showsResults says otherwise
- L97 shows tags unless the app asks for the list
- L105 sends margins as [top, left, bottom, right], none as an empty list
- L111 sends an accessory as a 30 point square unless it says otherwise
- L132 sends the appearance values that are set
- L143 lets the iOS names win over the first QMUI port names
- L163 answers the presentation events under both spellings, the core names first
- L180 forwards the first port accessory names to the iOS ones
- L200 sends the cancel button font and the views after the text
- L220 splits a result around the first match, case and diacritic insensitive
- L243 keeps the text as written when an accent is typed or not
- L261 shows only the results that belong to the text
- L268 has one component per core class plus the list, the tag list and the placeholder
- L283 pads and trims the subtitles to one entry per tag
- L290 names the title line limits
- L297 the search bar takes showsSearchButton, searchButtonStyle, searchButtonTitle and searchButtonHandler
- L318 goBack sends the goBack command to the native bar (hardware back plays the arrow animation)
- L325 sends nothing before the native bar exists
- L336 keeps setActive and restartItemAnimation

## `CrossPlatform/wechat-miniprogram-cylsearch/test/absolute_image_path.test.js` (3)

- L11 a relative package image becomes an absolute path from the component path
- L18 absolute paths, URLs, empty values and an unknown component path stay as they are
- L25 the bar gives its items and its search button absolute images

## `CrossPlatform/wechat-miniprogram-cylsearch/test/components.test.js` (15)

- L55 cyl-search-bar in the multiple mode: new search, complete, select, remove, with the indexed events
- L75 cyl-search-bar in the single mode: text, submit, items and Cancel
- L92 cyl-search: results from the property, selection, empty placeholder, suggestions for an empty query
- L109 cyl-search: a data source in JavaScript, configured rows, reloadResults
- L125 cyl-search: the refresh API drives CYLTableViewPlaceHolder cyl-refresh and sends refresh once
- L150 cyl-search: the empty-text submit of the search button does nothing and keeps the keyboard
- L166 cyl-search: submit closes the overlay with its transition, Cancel closes it with the completion
- L184 cyl-search-bar passes GIF stills, duration, autoplay and embedded on to cyl-tag-button
- L202 cyl-search-bar draws each item with cyl-tag-button: title, image, badge, animationURL, transparent
- L235 cyl-search-bar editing bar: every new title takes the keyboard, also when focus is already set
- L263 cyl-search: the content page is the one scroller and holds its scrolling only while a drag or a smear is active
- L283 cyl-search: tags are the default suggestion style: CollectionViewClassifyMenu\
- L313 cyl-search-refresh-button shows the built-in icon, reads the localized label and sends tap
- L322 cyl-search-navigation-bar sits below the status bar and ends before the menu button
- L350 cyl-search-bar appearance: its cancelTitle and clearIconImage are drawn, the bar\

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_animation_playback.test.js` (3)

- L9 a speed is clamped to the slider range and rounded to its step
- L17 a value that is not a number plays at the standard speed
- L22 the accessibility value names the speed and the loop

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_bar_view.test.js` (8)

- L7 items are appended like the FlatDesign tab bar items and report their taps
- L44 an item is built from plain values and gives them back
- L56 the text is cut to maximumTextLength and submitted unless the delegate refuses it
- L72 the multiple mode completes, selects and removes searches with the indexed events
- L108 the restorable state keeps the text, the icon state and the searches
- L123 editing bar submits the trimmed text from its action button and the confirm key
- L146 default colors: placeholder and divider are the secondary label, items the label color (accent when selected)
- L157 a host tint (the bar tint, then the item tint) overrides the state colors

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_core_classes.test.js` (10)

- L24 CYLSearchBarAppearance: every iOS key, a copy, the CSS of the images and the hidden background
- L45 CYLSearchBarView: appearanceStyle maps onto the bar, setItems keeps the items when only the playback differs
- L69 CYLSearchBar: the knobs read and write the bar view
- L101 CYLSearchResources: the shared store, its change event and the history notification name
- L119 CYLSearchView: the will events, the results header, the cache footer, the highlight color and the snapping flag
- L142 CYLSearchController: forwards to the search view, tells the delegate, loads the results once
- L195 CYLSearchController: the empty view for a scenario needs text; the edge swipe needs the swipe on and the search open
- L205 CYLSearchTableViewController: the bar is created on viewDidLoad, the hooks run, the empty view hides the bar
- L237 CYLSearchNavigationBar: the holding bar is set up, the back button calls the handler and keeps the items
- L256 CYLSearchTagListStyle: the defaults, the customizer, the grid, the glass name and the refresh icon

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_refresh_button_label.test.js` (4)

- L26 the label of the refresh button is tagList.refresh in the language of WeChat
- L32 the label property overrides the localized label
- L36 the icon is the built-in refresh image and a tap sends tap
- L43 the template makes the button a labelled button and hides the icon from screen readers

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_resources.test.js` (8)

- L14 strings fall back to English, then to the key; language tags map to the tables
- L24 formats keep the iOS and Android forms
- L29 the navigation bar is centered on the menu button and ends before it
- L36 every policy keeps submitted queries newest first, without repeats
- L53 the cache keeps at most maximumCount queries, separates names and shares the user defaults key
- L68 the refresh icon and its label tagList.refresh are built into the core in four languages
- L79 the field embedded in the navigation bar is 36 high, with or without a menu button
- L84 the navigation bar measures the width left for the bar beside the back button and the menu button

## `CrossPlatform/wechat-miniprogram-cylsearch/test/cyl_search_view.test.js` (13)

- L18 the search view lists the cache first, filters while typing and caches on submit
- L39 focusesSearchFieldOnShow decides whether the keyboard is asked for, and focus alone changes nothing below
- L57 showSearch and closeSearch run their completion once the animation is over, also when nothing changes
- L71 empty results show the placeholder only for a non-empty query that matches nothing
- L81 submit tells the delegate, closes unless handled, and selecting a suggestion can submit
- L100 the back arrow and Cancel close the search view unless the delegate takes the navigation button
- L116 the results of the data source replace the suggestions for a non-empty query
- L138 a result row is configured by the data source and its selection goes to the delegate
- L151 refresh: beginRefreshing calls the handler once, endRefreshing ends it, the static API reaches any target
- L188 the restorable state reopens the search view with its query
- L200 showsSuggestionCacheHeader: false hides the "Recent searches" header, the cached queries stay
- L220 the suggestions are tags by default, folded to two rows with the fold control as the last tag
- L230 the fold control content is the icon by default and can be icon and title or a title

## `CrossPlatform/wechat-miniprogram-cylsearch/test/default_search_button.test.js` (8)

- L53 a bar keeps a default search button; never for an editing bar or in multiple mode
- L67 text style: the localized "Search" (en, zh-Hans, zh-Hant, ja), a custom title wins; icon style: filled capsule 28 high
- L92 item API: cornerRadius, borderColor, borderWidth, itemHeight reach the tag style
- L110 a tap submits the text; the listener also fires for empty text; the handler runs after
- L121 the icon pill is concentric: gap above == gap below == gap at the right
- L134 cyl-search-bar: divider only after an owner item, icon style padding, tap submits, editing and multiple have none
- L165 first-level: a tap on the field pushes, a tap on the search button submits
- L177 examples: every one shows the default search button, none adds its own Search item or hides it

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_contact_tags.test.js` (5)

- L9 bundled data has ids and every language has the same contact tags keys
- L26 search, create, rename and delete keep the ids
- L48 downloaded sections replace My Tags and keep only existing recent ids
- L58 the other-device edit adds a tag and swaps the first two
- L65 Edit Tags puts its lists into the core content page and never creates or switches a scroller itself

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_corner_radius.test.js` (4)

- L25 the capsule constant comes from the library (cyl-animated-item, synced at the pin) and is 1000
- L31 no example source gives a corner radius the literal 1000 or 0.001
- L37 the Discover bar takes its look from navigationFieldStyle, no radius of its own
- L46 no 0.001 radius is left in the sources: the search bar item square is 0

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_discover.test.js` (11)

- L11 tags that fit in two rows are not folded
- L16 folded tags keep the first two rows with the chevron after the last visible tag
- L27 refresh shows the next page, cyclically, with no random pick
- L43 every language: 4 pages of 6, exactly one hot record per page, its slot differs from the next page
- L64 a search moves the query to the front of the recent searches, once
- L70 a bar in the navigation bar is centered on the menu button and ends before it
- L77 the topics are the tags of the ClassifyMenu tag cloud: a hot topic carries the hot icon and its label
- L87 the grid style is the iOS discoverStyle() over the base style of the cloud and does not change the base
- L109 the synced tag cloud renders the grid cell of a hot topic
- L124 the hot label is Hot, 人気, 热门 and 熱門 and every language passes it as the imageLabel of the hot topic
- L144 the Discover page passes discover.hot to the hot topics

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_qmui_search.test.js` (4)

- L46 Search controller: ten keywords, twenty rows per match, the core options do the launch view, the highlight and the empty view
- L66 Search bar styles: sections, rows and the bar calls of QDSearchBarViewController
- L96 Short list: three rows under the bar, the matching rows, the empty view
- L109 the screens are registered, in the menu after the contact tags, and the texts exist in four languages

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_tag_glass.test.js` (4)

- L17 the Discover topics grid carries backgroundStyle liquidGlass and no fill or border of its own
- L29 the contact tags carry backgroundStyle liquidGlass, no own fill or border, and a SELECTED green tint that survives the glass
- L43 the Discover recent tags stay opaque white, flat, and are no tag list
- L53 the only liquidGlass the example pages set is the topics style (through cylDiscoverCloudStyle) and the contact tags (through cylContactTagStyle)

## `CrossPlatform/wechat-miniprogram-cylsearch/test/example_text.test.js` (5)

- L7 WeChat languages map to the iOS localizations
- L16 iOS formats are filled in order and by position
- L23 the example texts are the iOS ones in every language
- L35 the embedded discover data equals the json copies the sync script checks
- L44 the discover data has the same topics in every language

## `CrossPlatform/wechat-miniprogram-cylsearch/test/first_level_navigation.test.js` (12)

- L14 a request for the state the back button has is a no-op, else applies at once or animated
- L22 the progress is clamped and the slot and the inset derive from it
- L32 the bar is the whole width inside the safe area at 0 and shrinks monotonically towards 1
- L44 a tap pushes only on a first-level bar whose back button is not shown yet; the root page has no back button
- L52 CYLSearchNavigationBar: showBackButton and hideBackButton, the tap hook and the sync with the shown page
- L75 presets: five distinct looks, applied by CYLSearchBarView.applyPreset
- L104 cyl-search-navigation-bar: a first-level tap shows the back button animated, fires the event and pushes; onShow reverses it
- L127 cyl-search-navigation-bar: showsBack is the initial state, shown at once; a plain bar never pushes
- L137 the component lays the bar out by flex and CSS transitions, never by a page-set width
- L147 the example: every tab shows its own preset as the whole bar and pushes on tap
- L166 the example pages never animate the back button or set the bar width themselves
- L177 a showsBack set after the bar was attached (a page sets it in onLoad) shows the back button

## `CrossPlatform/wechat-miniprogram-cylsearch/test/focus_on_appear.test.js` (5)

- L11 focuses only when on, on a second-level or deeper page, drawn (not iconified) and editable
- L21 second level or deeper means more than one page in the stack; the arrow icon no longer counts
- L28 cyl-search-bar has focusesOnAppear (false by default), used on attached and on page show, toggling focus
- L37 cyl-search passes focusesOnAppear to its inline bar only
- L43 the Discover and Search tab examples turn it on

## `CrossPlatform/wechat-miniprogram-cylsearch/test/navigation_field_style.test.js` (5)

- L12 the preset: bordered capsule radius 18, shadow 0.06, no magnifier, 16 text, opaque white / black fill
- L18 CYLSearchBarView.applyNavigationFieldStyle sets the preset on the model
- L50 cyl-search-bar: the property navigationFieldStyle and the method applyNavigationFieldStyle apply the preset
- L65 the component draws an opaque fill in light and dark for the preset
- L72 example pages call the preset and never set its values; no system search input

## `CrossPlatform/wechat-miniprogram-cylsearch/test/package.test.js` (9)

- L19 the entry exports the three core modules with the iOS names
- L35 src has four components (search bar, search, refresh button, navigation bar) and the core modules
- L59 the search package depends on no other search library: CYLTableViewPlaceHolder and CollectionViewClassifyMenu, pinned by commit
- L78 the published files are the sources, the readme and the license
- L87 every relative require names a file, as a mini program needs
- L98 no file of the package or the example names a removed component
- L115 cyl-search-bar and cyl-search declare the four engine slots and forward them, with no engine of their own
- L133 the synced CollectionViewClassifyMenu package has cyl-animated-item at the pinned CYLTabBarController commit
- L142 every search bar of the example passes its engines: cyl-lottie and cyl-svga, placeholders for PAG and Rive

## `CrossPlatform/wechat-miniprogram-cylsearch/test/qmui_search_port.test.js` (29)

- L77 CYLSearchBarAppearance: the merged defaults land on the bar, explicit properties win
- L96 cyl-search-bar: placeholder and text style properties exist (placeholder / placeholderColor / textColor / font)
- L103 centersPlaceholder: centred at rest, leading while editing or with text
- L118 field margins per state: properties, and a provider (bar, active) that wins
- L136 Cancel: margins per state, font, provider, and setShowsCancelButton(shows, animated)
- L157 leading view and trailing accessory views: shown by default, margins, animated, fast toggling ends in the last request
- L183 launch view: shown while the query is empty and no results show, gone when text is typed
- L195 dimming: a color under the bar while the query is empty and there is no launch view; a tap ends the search
- L209 updateresults: every change of the text, also "" on activation and on clear
- L218 will / did present and dismiss events, setActive and isActive
- L230 empty view with text: not for an empty query, hidden when the search ends, button action, isEmptyViewShowing
- L249 history: submitted queries are kept newest first, historychange follows a submit and a clear
- L267 results mark the match: parts of a title around the first match
- L283 swipe to dismiss: from the left edge, more than a quarter of the width or fast
- L314 snapsHeaderSearchBar (I4, #1160): a half scrolled bar settles fully shown or hidden
- L337 list screen: focusing the header bar starts the search, Cancel shows with it and ends it
- L359 hidesSearchBarInitially / hidesSearchBarWhenEmptyViewShowing: the content empty view takes the bar away
- L374 the search bar of the list screen is the one bar: its slots reach the accessory slots
- L387 the bar model keeps the iOS names for the new members
- L399 launch view: the suggestion area itself, history newest first with the header, else the suggestions; a tapped tag submits
- L429 scrim: scrimColor is the one overlay color, dimmingColor forwards to it
- L448 noResultsText: the empty view shows while the query is not empty and the results are empty, and goes with them
- L474 highlight: highlightsResultMatches and resultMatchHighlightColor, case and diacritic insensitive, the old names still work
- L496 the suggestion filter ignores case and diacritics like iOS
- L505 swipe to dismiss: the touch begins the swipe itself (24 px edge, 10 px slop, more sideways than vertical)
- L530 events: a present that starts during a dismiss overtakes it, no diddismiss for it
- L543 leading view and trailing accessory views: the earlier names forward, a set earlier property wins
- L564 no component of the package lays tags out by itself: the tag list is CollectionViewClassifyMenu\
- L578 launch tags: ten suggestions and no history go to the tag list whole, 2 folded rows, the fold control at the tail

## `CrossPlatform/wechat-miniprogram-cylsearch/test/svga-tab-icons.test.js` (3)

- L18 three tabs have SVGA icons, each with a size
- L26 every SVGA icon is in the package and decodes as an SVGA 2.x movie
- L41 the SVGA icons keep their license notice

## `CrossPlatform/wechat-miniprogram-cylsearch/test/trailing_group_layout.test.js` (6)

- L26 gap glyph-to-divider equals divider-to-capsule
- L34 the capsule keeps its size, a plain item widens only its touch area to 36
- L42 a plain text item hugs its title; with a background it keeps at least 36
- L51 items report hugsContent: plain icon hugs, the icon search button capsule does not
- L63 the component spaces the group by one margin and hugs plain items
- L75 the first and the last item keep their widened hit area: nothing clips it

## `CYLSearchExampleTests/CYLSearchAPIFenceTests.swift` (7)

- L96 testEnumsKeepEveryCase
- L108 testSearchBarViewMembers
- L261 testSearchBarItemMembers
- L310 testSearchViewMembers
- L428 testSearchBarAppearanceMembers
- L455 testSearchControllerMembers
- L509 testSearchTableViewControllerMembers

## `CYLSearchExampleTests/CYLSearchControllerDemoTests.swift` (7)

- L27 testScreenIsSetUpLikeQMUI
- L40 testResultsAreTwentyRowsPerMatchWithTheMatchInTheTintColor
- L64 testLaunchViewHoldsTheRecentSearchesAsTags
- L83 testSubmittedSearchesFormTheHistoryOfTheLaunchView
- L114 testTappedTagSetsTheQueryAndSubmitsIt
- L141 testSubmittedQueryPostsHistoryDidChange
- L169 testStringsExistInFourLanguages

## `CYLSearchExampleTests/CYLSearchControllerLaunchViewTests.swift` (34)

- L28 testE15LaunchViewFillsTheSpaceUnderTheBar
- L73 testLaunchViewSetAfterTheViewIsLoadedIsAdded
- L90 testE18AlwaysShowsSearchResultsController
- L111 testE19DimmingViewColorPlacementAndTap
- L167 testTheCustomLaunchViewPathStillWorks
- L189 testTagsAreFoldedAndTheFoldControlIsLast
- L209 testLaunchContentIsNeverCoveredByTheBar
- L242 testHistoryChangesOfOneNameReachTheLaunchContentOnScreen
- L283 testAStoreOfTheAppsOwnIsCoveredToo
- L358 testEveryScreenShowsTheSamePlaceholderClass
- L401 testEmptyViewFactoryAndSlot
- L435 testControllerEmptyViewEndsAtTheKeyboard
- L457 testSearchViewTablesHideTheTopEdgeEffect
- L468 testHighlightIsOffByDefaultAndMarksTheFirstMatchInCYLSearchView
- L501 testHighlightWorksOnListContentConfigurationsAndKeepsItsRules
- L522 testHighlightDoesNotLeakIntoAReusedLabel
- L542 testHighlightInCYLSearchControllerThroughAForwardingDataSource
- L576 testScrimAndDimmingColorAreTheSameOverlayAndATapEndsTheSearch
- L606 testSearchViewRefreshesWhileOpenWhenAnotherViewChangesTheHistory
- L645 testSuggestionAreaResolvesHistoryElseSuggestions
- L678 testSearchViewActiveStateEventsAndAliases
- L704 testSearchViewActiveStateWithAnimation
- L723 testShowDuringCloseKeepsTheViewOnScreen
- L744 testPresentationStateMovesThroughItsPhases
- L766 testControllerActiveStateAndAliases
- L788 testEdgeSwipeRuleIsShared
- L798 testSearchViewSwipeToDismiss
- L867 testNoResultsTextManagesTheEmptyView
- L886 testClearFooterClearsTheCache
- L916 testResultsHeaderTitlesTheResults
- L976 testSearchViewNoResultsTextTitlesTheEmptyResultsPlaceholder
- L1001 testHistoryNotificationCarriesPolicyAndName
- L1023 testSearchViewSnapsAHeaderOfAHostTable
- L1047 testTappedSuggestionReportsTextDidChangeBeforeSubmit

## `CYLSearchExampleTests/CYLSearchControllerLifecycleTests.swift` (16)

- L22 testSearchBarIsTheCoreField
- L36 testE2PopToRootWhileSearchingReleasesContents
- L63 testE3ReplacingRootWhileSearchingReleasesContents
- L90 testE8EmptyViewIsNotShownForEmptyText
- L112 testE9EmptyViewFillsThePageUnderTheBarAndIsHiddenOnDismiss
- L133 testE10UpdateResultsAlsoReceivesEmptyText
- L147 testE16SearchBarMaxYIsTheBarsBottomInTheWindow
- L156 testE17ActivateWithoutAnimationLaysThePageOutBelowTheBar
- L180 testHistoryStoreReceivesTheSubmittedQueries
- L204 testDelegateLifecycleOrder
- L221 testI1PopWhileSearchingRemovesThePage
- L246 testI1DismissWhileSearchingRemovesThePage
- L271 testI1LeavingTheSearchRemovesThePage
- L288 testI3SizeChangeLaysThePageOutAgain
- L308 testI2ResultsControllerGetsAppearanceCalls
- L321 testI2PopWhileSearchingTellsTheResultsControllerItDisappears

## `CYLSearchExampleTests/CYLSearchControllerSwipeTests.swift` (2)

- L18 testNoGestureWithoutTheOption
- L26 testGestureExistsWithTheOption

## `CYLSearchExampleTests/CYLSearchCoreObjectiveCSmokeTests.m` (13)

- L199 testSearchBarViewFromObjectiveC
- L216 testSearchViewFromObjectiveC
- L232 testSearchTableViewControllerFromObjectiveC
- L252 testSearchControllerFromObjectiveC
- L312 testResourcesFromObjectiveC
- L329 testSearchBarViewObjectiveCMembersAreFenced
- L454 testSearchBarItemObjectiveCMembersAreFenced
- L500 testSearchViewObjectiveCMembersAreFenced
- L598 testSearchBarAppearanceObjectiveCMembersAreFenced
- L622 testSearchControllerObjectiveCMembersAreFenced
- L664 testSearchTableViewControllerObjectiveCMembersAreFenced
- L686 testEnumsKeepEveryCaseFromObjectiveC
- L704 testProtocolsKeepEveryMethodFromObjectiveC

## `CYLSearchExampleTests/CYLSearchExampleCacheFocusItemTests.swift` (11)

- L25 testEverySuggestionCachePolicyKeepsSubmittedQueriesNewestFirst
- L63 testTheSearchViewCachesSubmittedQueriesAndClearsThemFromTheHeader
- L111 testFocusesSearchFieldOnShowDecidesWhenTheKeyboardAppears
- L132 testFocusAloneChangesNothingBelowTheSearchBar
- L173 testTagSuggestionsEndWithTheFoldButtonByDefault
- L231 testSuggestionsAreTagsFoldedToTwoRowsByDefaultAndTheLastTagIsTheFoldControl
- L277 testTagSuggestionsStartBelowTheSearchBarWithoutAnEdgeBlur
- L308 testTagSuggestionsThatFitTheFoldedRowsShowNoFoldControl
- L327 testTheListStyleStaysAvailable
- L349 testSearchBarItemsFollowTheAnimatedItemDisplayPriority
- L385 testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems

## `CYLSearchExampleTests/CYLSearchExampleContactTagsTests.swift` (6)

- L23 testContactTagsDemoSearchesCreatesAndKeepsItsStrings
- L84 testContactTagsDemoShowsCYLPlaceholderViewWhenEmpty
- L147 testContactTagsManageEditsInPlaceSavesAndOpensContacts
- L226 testContactTagsUploadSyncAndLoadTheServerCopy
- L309 testContactTagsRenameKeepsTheTagIDAndItsContacts
- L378 testEditingBarSubmitsAndRidesOnTheKeyboard

## `CYLSearchExampleTests/CYLSearchExampleParityTests.swift` (6)

- L23 testSearchBarViewParityOptions
- L122 testSearchViewSuggestionsOpenAndClose
- L202 testSearchBarViewMultipleModeFlow
- L280 testSwiftPortsOfOtherLibrariesLoad
- L355 testEmptyResultsShowTheCYLTableViewPlaceHolderPlaceholder
- L388 testEmptyResultsPlaceholderStaysAboveTheKeyboard

## `CYLSearchExampleTests/CYLSearchExampleSearchBarTests.swift` (30)

- L23 testSearchBarViewLayoutStyleAndEvents
- L68 testSearchBarViewSupportsVoiceOverAndDynamicType
- L123 testOriginalDemoRebuiltOnTheCore
- L173 testSearchBarDemoRow
- L209 testTabBarComesFromTheConfigurationFile
- L260 testPlusButtonIsRaisedAboveTheTabBar
- L281 testSearchBarNeverCoversTheViewControllersView
- L301 testSearchBarsCoverNoView
- L574 testItemDictionaryReadsAnimationLoopsAndSpeedWithDefaults
- L593 testSetItemsKeepsTheItemsWhenOnlyLoopsAndSpeedChange
- L621 testSpeedOnlyChangeKeepsTheLoadedAnimationView
- L652 testItemSpeedReachesTheTagButtonAndFollowsChanges
- L676 testTagListStyleSpeedSurvivesBarItemsAtSpeedOne
- L708 testBarCapsuleLinesUpWithTheTagListInset
- L720 testTagListHeaderRefreshIconIsAnIconWithALocalizedLabel
- L736 testDefaultTagStyleMatchesTheExampleRecentSearchesAndCanBeCustomized
- L778 testDiscoverRefreshShowsTheNextPageWithTheHotTopicMoving
- L810 testEmbedInNavigationBarCreatesTheBarWhenTheViewControllerHasNone
- L841 testEmbedInNavigationBarUsesTheNavigationControllersBar
- L862 testNavigationBarHoldingTheBarCanShowABackButton
- L881 testEmbeddedBarAsksForTheWholeWidthAndAPlainBarKeepsItsOwn
- L900 testFocusesOnAppearEveryTimeTheBarReappears
- L957 testDefaultSearchButton
- L1008 testDividerGapsAreEven
- L1039 testFirstLevelBarPushesOnTapAndNeverEdits
- L1064 testPresetsAndTheBackButtonAPI
- L1105 testFirstLevelPageInstallsAPushingBar
- L1132 testDefaultSearchButtonWithEmptyTextDoesNothingInASearchView
- L1162 testIconSearchButtonHasAnEqualGapOnThreeSides
- L1182 testSearchKeyAndOutsideTouchHidesTheKeyboard

## `CYLSearchExampleTests/CYLSearchExampleSearchTests.swift` (10)

- L23 testLocalPodsConfigureSearchAndRefresh
- L48 testPackagedResourcesAndLocalization
- L69 testIndependentPlaceholderStylesAndMessages
- L92 testPlaceholderMessagesAreLocalized
- L105 testPlaceholderGalleryNavigation
- L148 testSearchViewShowsResultsOfItsDataSource
- L218 testSearchViewRefreshWrapsThePullToRefresh
- L259 testRefreshBlockDoesNotRetainController
- L274 testRefreshReloadsSearchResults
- L291 testOverlayOpensACYLSearchViewWithTheSameData

## `CYLSearchExampleTests/CYLSearchExampleTestSupport.swift` (1)

- L136 testWindow

## `CYLSearchExampleTests/CYLSearchIssueScenarioTests.swift` (8)

- L58 testI1BarDoesNotJumpOnActivation
- L86 testI2PlainSubviewBarStaysInTheSafeArea
- L129 testI2PlainBarInAnExtendedViewStaysInPlace
- L156 testI3NavigationItemInstallSurvivesASearch
- L209 testI4ShortListHeaderSettlesFullyShownOrHidden
- L268 testI4ControlPlainTableOnThisSystem
- L291 testI4BottomInsetFillsWhatUIKitDoesNotPad
- L345 testI5BarInContainerReturnsToItsFrameAfterCancel

## `CYLSearchExampleTests/CYLSearchTableViewControllerTests.swift` (6)

- L53 testObjectiveCNamesAndDefaults
- L69 testShowsSearchBarWaitsForViewDidLoad
- L99 testTurningShowsSearchBarOffRemovesEverything
- L122 testHidesSearchBarWhenEmptyViewShowing
- L164 testViewWillAppearClearsTheResultsSelection
- L187 testUpdateResultsReachesTheSubclass

## `harmonyos/entry/src/ohosTest/ets/test/CYLSearchCore.test.ets` (23)

- L47 cacheKeepsNewestFirstWithoutDuplicates
- L59 cacheIgnoresBlankQueries
- L69 noCachePolicyGivesNoCache
- L74 localizedStringFollowsLanguage
- L79 emptyResultsUseTheTableViewPlaceHolderScenario
- L91 handleBackPressOnlyWhenOpen
- L100 closeSearchCallsItsCompletion
- L115 resultsFollowTheQuery
- L136 reloadResultsAsksTheDataSourceAgain
- L153 refreshHandlerAndStaticRefresh
- L175 multipleModeCompletesOnBack
- L188 multipleModeReportsItsEvents
- L221 multipleModeDropsShortSearchesAndSelectsTheNextAfterRemoval
- L235 singleModeIgnoresNewSearches
- L242 suggestionsFoldAccentsAndTrimTheQuery
- L252 setQueryReportsTheChangeOnceAndRefusesBlankSubmit
- L271 searchBarKeepsItemsInOrder
- L278 searchBarItemTintFollowsStateAndHostOverrides
- L299 searchBarItemsAreDrawnByTagButtons
- L335 suggestionStyleDefaultsToFoldedTags
- L347 foldControlPositionNone
- L354 clearSuggestionCacheWithoutContextDoesNotThrow
- L360 databasePolicyKeepsQueriesInSQLite

## `harmonyos/entry/src/ohosTest/ets/test/CYLSearchMerge.test.ets` (12)

- L85 suggestionAreaIsTheClassifyMenuTagList
- L102 oldFoldControlTypesForwardToTheTagList
- L123 aTappedLaunchTagSubmits
- L137 aTappedTagOutsideTheLaunchContentOnlyFillsTheField
- L145 launchContentAndCustomLaunchViewReplaceEachOther
- L158 oneScrimOverlayAndDimmingColorForwardsToIt
- L170 oneHistorySignalForEveryViewOfTheCache
- L193 aCacheOfYourOwnIsAnnouncedOnceBySubmitAndClear
- L207 noResultsTextShowsAndHidesTheEmptyView
- L227 theEmptyViewIsOnePlaceholderWithTextHintAndButton
- L244 accessoryNamesOfTheQMUIPortForwardToTheIOSNames
- L265 highlightAndSwipeOptionsDefaultOffLikeIOS

## `harmonyos/entry/src/ohosTest/ets/test/CYLSearchQMUIPort.test.ets` (12)

- L28 appearanceStyleAppliesTheDefaultStyle
- L37 appearanceCopyIsIndependent
- L50 textFieldMarginsProviderWinsAndFollowsTheActiveState
- L64 cancelButtonMarginsProviderAndAutomaticCancel
- L76 placeholderIsCenteredOnlyAtRest
- L88 showsCancelAndAccessoriesEndInTheLastRequest
- L102 updateResultsReportsEmptyTextOnShowAndEveryChange
- L112 presentationCallbacksComeInOrderAndActiveFollows
- L131 emptyViewIsNotShownForEmptyTextAndHidesOnClose
- L147 submittedQueryGoesToTheHistoryAndTellsTheLaunchView
- L167 launchViewShowsOnlyWhileTheQueryIsEmpty
- L182 tableViewHeaderRules

## `harmonyos/entry/src/ohosTest/ets/test/CYLSearchUI.test.ets` (10)

- L166 searchTabShowsResultsAndReproductionToggle
- L179 examplesMenuOpensPlaceholderStyles
- L193 overlayShowsResultsOfTheDataSource
- L222 reproductionListPullsToRefresh
- L236 multipleModeSearchBarAddsSearches
- L255 tagStyleSampleSearchClosesOnBack
- L271 searchFlowByLabels
- L295 searchControllerScreenUsesTheCoreOptions
- L322 discoverTabShowsRecentSearches
- L340 discoverRefreshButtonHasItsLabel

## `harmonyos/scripts/host-logic-test.mjs` (110)

- L40 removes accents and lowercases
- L47 matches accents folded and the query trimmed
- L55 shows the cached queries for an empty query
- L59 shows every suggestion for an empty query without a cache, with showsAllForEmptyQuery
- L63 lists matching cached queries first, then the other matches once
- L67 uses a custom filter
- L74 trims, moves to the front and keeps at most the maximum
- L77 keeps at least one query
- L80 ignores a blank query
- L86 finds the first match, ignoring case
- L91 ignores accents in the text and in the query
- L99 is undefined for an empty query or no match
- L106 begins at the left edge, moving right past the slop and more than vertically
- L113 ends the search past a quarter of the width
- L121 cuts to the limit, or keeps the text with no limit
- L128 needs a non-empty text of at least the minimum length, not trimmed
- L137 selects the next item when the selected one is removed
- L140 selects the previous item when the last one is removed
- L143 keeps the same item when an earlier one is removed
- L146 keeps the selection when a later one is removed
- L149 selects the item at the removed place when nothing was selected
- L152 selects nothing when no item is left
- L158 refuses blank text
- L170 draws a text item with its title, its icon, its badge and its animation file
- L176 draws an icon item with its icon only; the title is what screen readers read
- L182 draws nothing on a divider
- L187 lets an animated image replace the icon and the selected icon
- L195 uses the item insets, else 0 for the divider, 4 for a text item with a shape and 0 for the others (owner, 2026-11-26)
- L208 a plain icon or text item hugs, a divider and a shaped item do not
- L216 glyph-to-divider equals divider-to-capsule within 1 vp
- L223 a hugging item is its glyph wide with a 36 wide touch area; the capsule keeps its size
- L231 a point 6 vp beside the first and the last plain item is inside its hit region (inside the row too)
- L241 a text search button hugs its title and the gaps stay even
- L250 grows a 36 vp item to a 44 vp touch target around its center
- L253 keeps a larger item as it is
- L260 centers the placeholder only at rest, empty, with a placeholder
- L267 lets the provider win over the fixed margins
- L274 draws Cancel when asked for, or automatically while active
- L283 shows the empty view only for a non-empty query
- L288 shows the launch view while the query is empty
- L293 ignores the dimming when a launch view is set or the query is not empty
- L302 adds only what the rows leave of the viewport
- L307 settles a half-hidden header fully shown or fully hidden
- L312 leaves a header alone outside the header band
- L335 wraps around and counts a negative page from the end
- L342 every language has 4 pages of 6, one hot record per page and a hot slot that differs from the next page
- L372 gives the bar the width left beside the back button with layoutWeight(1)
- L376 lets the example page pass no width, margin or padding to the bar
- L397 reads cyl_tagList_refresh as the accessibility text of the symbol button
- L402 has the iOS text in base, ja_JP, zh_CN and zh_TW
- L405 has a label in every language the library localizes
- L424 has Hot, 人気, 热门 and 熱門 in base, ja_JP, zh_CN and zh_TW
- L427 leads the hint of a hot topic with the label and leaves other topics alone
- L434 passes discover_hot to the data source and the hint through cylDiscoverItemHint
- L453 takes the capsule constant from the library (cylanimateditem, 1000), with no repo-local copy
- L463 gives no radius in the entry or library sources the literal 1000, 999 or 0.001
- L468 gives the Discover bar its look through applyNavigationFieldStyle, never its own values
- L472 draws the search bar item square with 0, and CYLTagCornerRadiusSquare is gone
- L495 sets the one parameter on the Discover topics grid and the contact tags, and imports the enum
- L501 gives the glass tags no fill and no border of their own; the selected tint keeps visible after the glass
- L514 keeps the Discover recent tags opaque white and flat (no glass in recentTag)
- L526 ignores the playback keys and the key order
- L530 tells another value apart
- L533 keeps the items only when the shapes and the item count are the same
- L543 is always on with alwaysEnablesCancelButton, else only while editing
- L552 asks the provider only while results show
- L556 shows no header without a provider or when it answers nothing
- L563 lets a swipe begin only inside the search view
- L568 pushes the navigation bar away only while searching
- L573 asks the status bar providers only while searching
- L581 forwards the appearance only when asked for and searching
- L586 reports the search bar edge only while searching
- L594 holds the field with 4 above and below and no side inset, and never pops by itself
- L601 names the glass background case-insensitively and everything else is flat
- L607 leaves the list alone for 0 or fewer columns
- L612 has the metrics of the iOS example recent searches
- L624 has the metrics of the discover topics grid
- L634 splits 42 sections into chunks of 6 and clamps past the end
- L640 shows one more chunk when the scroll reaches the end, never more than exist
- L648 is a bordered capsule radius 18, shadow 0.06, no magnifier, 16 fp text
- L652 uses an opaque white (light) and black (dark) fill resource
- L658 is exposed on the core view and called, never copied, by the example screens
- L666 leaves no system Search() or TextInput in the example sources
- L676 is ignored by the view only: blank text, never real text
- L682 the view delegate returns before recording and keeps the keyboard
- L692 focuses only when on, on a second-level or deeper page, drawn and not editing
- L699 feeds the depth from the Navigation stack and ignores the back button
- L707 treats hidden to visible as an appearance, not a change between visible ratios
- L712 is off by default and enabled in the Discover and Search examples
- L722 asking for the state the button has is a no-op, else applies at once or animated
- L729 clamps the progress and derives the slot and the inset from it
- L738 shrinks the bar smoothly: full width within the safe area at 0, narrower and monotonic towards 1
- L749 a tap pushes only on a first-level bar whose back button is not shown yet
- L754 the root page has no back button, a pushed page has one
- L758 has a distinct preset per tab
- L768 every tab root shows its own preset in the title bar and pushes on tap
- L780 the examples never animate the back button or set a width themselves
- L787 the core exports the title bar and the preset
- L795 shows by default, never for an editing bar or in multiple mode
- L801 has a divider only when an owner item precedes it
- L805 text style: localized default title, custom title wins, no fill
- L811 icon style: filled capsule 28 high with 16 insets, built-in magnifier unless an image is set
- L818 a tap submits non-empty text; empty text only tells the listener
- L824 item corner radius, height: automatic follows the background, own values win
- L838 the core has the iOS names
- L848 the localized "Search" exists in en, zh-Hans, zh-Hant and ja
- L856 no example adds its own Search item or hides the default button
- L864 the icon style is the core default; the remark name field is the only example with the text style (owner, 2026-11-26)
- L878 gap above == gap below == gap at the right (4 for a 36 field and a 28 pill)
- L889 the text style keeps the usual inset
