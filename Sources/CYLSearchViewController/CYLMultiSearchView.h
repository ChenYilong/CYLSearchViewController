#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLMultiSearchView;

/*!
 * Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`).
 */
@protocol CYLMultiSearchViewDelegate <NSObject>
@optional
/*!
 * The text of the search being typed changed (`onTextChanged`).
 */
- (void)multiSearchView:(CYLMultiSearchView *)multiSearchView textDidChange:(NSString *)text atIndex:(NSUInteger)index;
/*!
 * A search was completed and became an item (`onSearchComplete`).
 */
- (void)multiSearchView:(CYLMultiSearchView *)multiSearchView didCompleteSearch:(NSString *)text atIndex:(NSUInteger)index;
/*!
 * An item was removed (`onSearchItemRemoved`).
 */
- (void)multiSearchView:(CYLMultiSearchView *)multiSearchView didRemoveItemAtIndex:(NSUInteger)index;
/*!
 * An item was selected by a tap (`onItemSelected`).
 */
- (void)multiSearchView:(CYLMultiSearchView *)multiSearchView didSelectItem:(NSString *)text atIndex:(NSUInteger)index;
@end

/*!
 * Several searches side by side (iammert `MultiSearchView`): the search button starts a new search; a completed
 * search becomes an item in a horizontally scrolling row, with an indicator under the selected item and a remove
 * button on it. Use it to search by several categories at once.
 *
 *     CYLMultiSearchView *multiSearch = [[CYLMultiSearchView alloc] initWithFrame:CGRectZero];
 *     multiSearch.placeholder = @"Search";
 *     multiSearch.delegate = self;
 */
@interface CYLMultiSearchView : UIView

/*!
 * Receives the events.
 */
@property (nonatomic, weak, nullable) id<CYLMultiSearchViewDelegate> delegate;
/*!
 * The texts of the items, completed searches first, then the one being typed.
 */
@property (nonatomic, copy, readonly) NSArray<NSString *> *searchTexts;
/*!
 * The selected item, or `NSNotFound` when there is none.
 */
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
/*!
 * YES while a new search is being typed (`isInSearchMode`).
 */
@property (nonatomic, assign, readonly, getter=isInSearchMode) BOOL inSearchMode;
/*!
 * The button at the trailing end: it starts a search, or completes the one being typed.
 */
@property (nonatomic, strong, readonly) UIButton *searchButton;

#pragma mark Text style (iammert searchTextStyle)

/*!
 * The placeholder of a new search (`android:hint`). "Search" by default.
 */
@property (nonatomic, copy, null_resettable) NSString *placeholder;
/*!
 * The font of the items (`android:textSize`). The body text style by default, following Dynamic Type.
 */
@property (nonatomic, strong, null_resettable) UIFont *font;
/*!
 * The text color (`android:textColor`). `labelColor` by default.
 */
@property (nonatomic, strong, null_resettable) UIColor *textColor;
/*!
 * The placeholder color (`android:textColorHint`). `placeholderTextColor` by default.
 */
@property (nonatomic, strong, null_resettable) UIColor *placeholderColor;
/*!
 * The longest search a person can type (`android:maxLength`); 0 means no limit. 0 by default.
 */
@property (nonatomic, assign) NSUInteger maximumTextLength;
/*!
 * A search shorter than this is dropped when it is completed. 3 by default, as in MultiSearchView.
 */
@property (nonatomic, assign) NSUInteger minimumTextLength;
/*!
 * The return key (`android:imeOptions`). `UIReturnKeySearch` by default.
 */
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
/*!
 * The keyboard (`android:inputType`). `UIKeyboardTypeDefault` by default.
 */
@property (nonatomic, assign) UIKeyboardType keyboardType;
/*!
 * Capitalization (`textCapSentences`). `UITextAutocapitalizationTypeSentences` by default.
 */
@property (nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;

#pragma mark Other style

/*!
 * The color of the indicator under the selected item and of the buttons. `tintColor` by default.
 */
@property (nonatomic, strong, nullable) UIColor *indicatorColor;
/*!
 * The opacity of items that are not selected. 0.5 by default.
 */
@property (nonatomic, assign) CGFloat unselectedItemAlpha;
/*!
 * The width of the field for a new search, in points. 160 by default.
 */
@property (nonatomic, assign) CGFloat searchFieldWidth;
/*!
 * The length of the animations, in seconds. 0.25 by default.
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;
/*!
 * The search button's icon. `magnifyingglass` by default.
 */
@property (nonatomic, strong, null_resettable) UIImage *searchImage;
/*!
 * The remove button's icon. `xmark.circle.fill` by default.
 */
@property (nonatomic, strong, null_resettable) UIImage *removeImage;

#pragma mark Actions

/*!
 * Starts a new search and shows the keyboard (`search`). Does nothing while a search is being typed.
 */
- (void)search;
/*!
 * Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter
 * than `minimumTextLength`.
 */
- (void)completeSearch;
/*!
 * Adds a completed search without typing it and selects it.
 */
- (void)addSearchText:(NSString *)text;
/*!
 * Selects an item, like a tap on it.
 */
- (void)selectItemAtIndex:(NSUInteger)index;
/*!
 * Removes an item, like a tap on its remove button.
 */
- (void)removeItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
