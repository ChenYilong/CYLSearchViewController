#import "CylsearchTagListView.h"
#import "CYLRNSearchSupport.h"

#import <react/renderer/components/CylsearchViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/CylsearchViewSpec/EventEmitters.h>
#import <react/renderer/components/CylsearchViewSpec/Props.h>
#import <react/renderer/components/CylsearchViewSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CylsearchTagListView () <CYLMenuDataSource, CYLMenuDelegate>
@end

/*!
 * CollectionViewClassifyMenu's CYLTagListView filling the component, one section of tags from JavaScript: their titles
 * and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests),
 * as on Android. It reports the height its tags need at the component's width (`onHeightChange`), again after folding,
 * unfolding and editing.
 */
@implementation CylsearchTagListView {
  CYLTagListView *_tagListView;
  CGFloat _reportedHeight;
  NSArray<NSString *> *_titles;
  NSArray<NSString *> *_ids;
  NSSet<NSString *> *_selectedIds;
  NSString *_sectionTitle;
  BOOL _showsClearButton;
  BOOL _supportsRenaming;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<CylsearchTagListViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const CylsearchTagListViewProps>();
    _props = defaultProps;
    _reportedHeight = -1;
    _titles = @[];
    _ids = @[];
    _selectedIds = [NSSet set];
    _sectionTitle = @"";
    _tagListView = [[CYLTagListView alloc] initWithFoldControl:CYLRNFoldControl(@"inline", @"icon")];
    _tagListView.showsSectionHeaders = NO;
    _tagListView.selectionMode = CYLMenuSelectionModeNone;
    _tagListView.allowsEmptySelection = YES;
    // The host adds tags in its own editing bar (CylsearchBarView `editingBar`), as the iOS example does.
    _tagListView.showsAddItemViewWhileEditing = NO;
    // The React Native screen shows through, as around any other view.
    // CYLMenuStyle's backgroundColor is Swift-only since CollectionViewClassifyMenu's Swift core (27e17e7): set it
    // through the configuration keys, which Objective-C can reach.
    [_tagListView applyConfiguration:@{@"style": @{@"backgroundColor": UIColor.clearColor}}];
    __weak __typeof(self) weakSelf = self;
    // Renaming is the host's: the list asks, the host renames by id and sends the new titles.
    _tagListView.renameRequestHandler = ^(NSIndexPath *indexPath, NSString *title) {
      [weakSelf emitRenameRequestAtIndex:indexPath.item title:title ?: @""];
    };
    _tagListView.clearButtonHandler = ^(NSInteger section) {
      [weakSelf emitClearButtonTapInSection:section];
    };
    _tagListView.menuDataSource = self;
    _tagListView.menuDelegate = self;
    self.contentView = _tagListView;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &p = *std::static_pointer_cast<CylsearchTagListViewProps const>(props);
  _tagListView.overrideUserInterfaceStyle = CYLRNInterfaceStyle(CYLRNString(p.colorScheme));
  _tagListView.foldControl = CYLRNFoldControl(CYLRNString(p.foldControlPosition), CYLRNString(p.foldControlContent));
  _tagListView.defaultVisibleRows = MAX(0, p.foldedRowCount);
  CYLMenuSelectionMode mode = [CYLRNString(p.selectionMode) isEqualToString:@"multiple"] ? CYLMenuSelectionModeMultiple
                                                                                           : CYLMenuSelectionModeNone;
  if (mode != _tagListView.selectionMode) {
    _tagListView.selectionMode = mode;
  }
  NSArray<NSString *> *titles = CYLRNStrings(p.tags);
  NSArray<NSString *> *ids = CYLRNStrings(p.tagIds);
  NSString *sectionTitle = CYLRNString(p.sectionTitle);
  BOOL renaming = p.supportsRenaming;
  // Reloaded only when JavaScript sends other content, so a re-render keeps the native fold state and scroll.
  if (![titles isEqualToArray:_titles] || ![ids isEqualToArray:_ids] || ![sectionTitle isEqualToString:_sectionTitle]
      || p.showsClearButton != _showsClearButton || renaming != _supportsRenaming) {
    _titles = titles;
    _ids = ids;
    _sectionTitle = sectionTitle;
    _showsClearButton = p.showsClearButton;
    _supportsRenaming = renaming;
    _tagListView.showsSectionHeaders = sectionTitle.length > 0 || _showsClearButton;
    [_tagListView reloadMenuData];
  }
  _selectedIds = [NSSet setWithArray:CYLRNStrings(p.selectedIds)];
  [self applySelection];
  _tagListView.allowsSmearSelection = p.allowsSmearSelection;
  if ((BOOL)p.editing != _tagListView.isEditing) {
    [_tagListView setEditing:p.editing animated:YES];
  }
  [super updateProps:props oldProps:oldProps];
  [self setNeedsLayout];
}

/*!
 * The id of the tag at `index`: its entry in `tagIds`, or its title when no id is given.
 */
- (NSString *)idAtIndex:(NSInteger)index
{
  NSString *identifier = index >= 0 && index < (NSInteger)_ids.count ? _ids[index] : nil;
  if (identifier.length > 0) {
    return identifier;
  }
  return index >= 0 && index < (NSInteger)_titles.count ? _titles[index] : @"";
}

- (NSString *)titleAtIndex:(NSInteger)index
{
  return index >= 0 && index < (NSInteger)_titles.count ? _titles[index] : @"";
}

/*!
 * Shows `selectedIds` as selected ("multiple" mode only).
 */
- (void)applySelection
{
  if (_tagListView.selectionMode != CYLMenuSelectionModeMultiple) {
    return;
  }
  NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
  for (NSInteger index = 0; index < (NSInteger)_titles.count; index++) {
    if ([_selectedIds containsObject:[self idAtIndex:index]]) {
      [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    }
  }
  _tagListView.selectedIndexPaths = indexPaths;
}

- (BOOL)respondsToSelector:(SEL)selector
{
  // The edit icon shows only for a data source that renames (`supportsRenaming`).
  if (selector == @selector(menuRenameItemAtIndexPath:toTitle:)) {
    return _supportsRenaming;
  }
  return [super respondsToSelector:selector];
}

#pragma mark - CYLMenuDataSource

- (NSInteger)numberOfSectionsInMenu
{
  return 1;
}

- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section
{
  return (NSInteger)_titles.count;
}

- (NSString *)menuTitleForSection:(NSInteger)section
{
  return _sectionTitle ?: @"";
}

- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [self titleAtIndex:indexPath.item];
}

- (NSString *)menuIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [self idAtIndex:indexPath.item];
}

- (BOOL)menuShowsClearButtonForSection:(NSInteger)section
{
  return _showsClearButton;
}

- (void)menuRenameItemAtIndexPath:(NSIndexPath *)indexPath toTitle:(NSString *)title
{
  // Not used: `renameRequestHandler` hands renaming to JavaScript, which sends the new titles.
}

- (void)menuRemoveItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger index = indexPath.item;
  if (index < 0 || index >= (NSInteger)_titles.count) {
    return;
  }
  NSString *identifier = [self idAtIndex:index];
  NSMutableArray<NSString *> *titles = [_titles mutableCopy];
  [titles removeObjectAtIndex:index];
  _titles = titles;
  if ((NSInteger)_ids.count > index) {
    NSMutableArray<NSString *> *ids = [_ids mutableCopy];
    [ids removeObjectAtIndex:index];
    _ids = ids;
  }
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onTagDelete(CylsearchTagListViewEventEmitter::OnTagDelete{.index = (int)index, .id = std::string(identifier.UTF8String ?: "")});
  }
}

- (void)menuMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSInteger from = sourceIndexPath.item;
  NSInteger to = destinationIndexPath.item;
  if (from < 0 || from >= (NSInteger)_titles.count || to < 0 || to >= (NSInteger)_titles.count) {
    return;
  }
  NSMutableArray<NSString *> *titles = [_titles mutableCopy];
  NSString *title = titles[from];
  [titles removeObjectAtIndex:from];
  [titles insertObject:title atIndex:to];
  _titles = titles;
  if (_ids.count == titles.count) {
    NSMutableArray<NSString *> *ids = [_ids mutableCopy];
    NSString *identifier = ids[from];
    [ids removeObjectAtIndex:from];
    [ids insertObject:identifier atIndex:to];
    _ids = ids;
  }
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onTagMove(CylsearchTagListViewEventEmitter::OnTagMove{.from = (int)from, .to = (int)to});
  }
}

#pragma mark - CYLMenuDelegate

/*!
 * A tag drag started or ended (CollectionViewClassifyMenu `-menu:didChangeReordering:`), as Android sends it.
 */
- (void)menu:(id)menu didChangeReordering:(BOOL)reordering
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onReorderingChange(CylsearchTagListViewEventEmitter::OnReorderingChange{.reordering = (bool)reordering});
  }
}

/*!
 * A smear selection started or ended (CollectionViewClassifyMenu `-menu:didChangeSmearing:`), as Android sends it.
 */
- (void)menu:(id)menu didChangeSmearing:(BOOL)smearing
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onSmearingChange(CylsearchTagListViewEventEmitter::OnSmearingChange{.smearing = (bool)smearing});
  }
}

- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger index = indexPath.item;
  NSString *identifier = [self idAtIndex:index];
  BOOL selected = _tagListView.selectionMode == CYLMenuSelectionModeMultiple;
  if (selected) {
    _selectedIds = [_selectedIds setByAddingObject:identifier];
  }
  [self emitTagSelectAtIndex:index identifier:identifier selected:selected];
}

- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger index = indexPath.item;
  NSString *identifier = [self idAtIndex:index];
  NSMutableSet<NSString *> *selected = [_selectedIds mutableCopy];
  [selected removeObject:identifier];
  _selectedIds = selected;
  [self emitTagSelectAtIndex:index identifier:identifier selected:NO];
}

- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height
{
  [self reportHeight];
}

- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section
{
  [self reportHeight];
}

- (void)menu:(id)menu didChangeEditing:(BOOL)editing
{
  [self reportHeight];
}

#pragma mark - Layout and events

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self reportHeight];
}

- (void)reportHeight
{
  CGFloat width = CGRectGetWidth(self.bounds);
  if (width <= 0 || !_eventEmitter) {
    return;
  }
  CGFloat height = ceil([_tagListView heightThatFitsWidth:width]);
  if (height != _reportedHeight) {
    _reportedHeight = height;
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onHeightChange(CylsearchTagListViewEventEmitter::OnHeightChange{.height = height});
  }
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  _reportedHeight = -1;
  [self reportHeight];
}

- (void)emitTagSelectAtIndex:(NSInteger)index identifier:(NSString *)identifier selected:(BOOL)selected
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onTagSelect(CylsearchTagListViewEventEmitter::OnTagSelect{
            .index = (int)index,
            .title = std::string([self titleAtIndex:index].UTF8String ?: ""),
            .id = std::string(identifier.UTF8String ?: ""),
            .selected = (bool)selected});
  }
}

- (void)emitRenameRequestAtIndex:(NSInteger)index title:(NSString *)title
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onRenameRequest(CylsearchTagListViewEventEmitter::OnRenameRequest{
            .index = (int)index,
            .id = std::string([self idAtIndex:index].UTF8String ?: ""),
            .title = std::string(title.UTF8String ?: "")});
  }
}

- (void)emitClearButtonTapInSection:(NSInteger)section
{
  if (_eventEmitter) {
    std::static_pointer_cast<CylsearchTagListViewEventEmitter const>(_eventEmitter)
        ->onClearButtonTap(CylsearchTagListViewEventEmitter::OnClearButtonTap{.section = (int)section});
  }
}

@end
