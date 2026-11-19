import { common } from '@kit.AbilityKit';
import {
  CYLControlState, CYLEdgeInsets, CYLFont, CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuFoldControl,
  CYLMenuFoldControlContent, CYLMenuFoldControlPosition, CYLMenuItemType, CYLMenuSelectionMode, CYLMenuStyle,
  CYLTagListState, CYLTagListView
} from '@cyl/classifymenu';
import { CYLPlaceholderStyle, CYLPlaceholderView, CYLPlaceholderViewModel } from 'cylplaceholder';
import { CYLSearchBarComponent, CYLSearchBarView } from 'cylsearch';
import { CYLDemoNavBar, CYLDemoRoute } from '../../common/DemoCommon';
import {
  CYL_CONTACT_TAGS_MINE,
  CYL_CONTACT_TAGS_RECENT,
  CYLContactTagContact,
  CYLContactTagData,
  CYLContactTagPreferences,
  CYL_CONTACT_TAGS_CACHE,
  CYLContactTagStore,
  cylContactTagsText
} from './CYLContactTagStore';
import { CYLContactTagServer } from './CYLContactTagServer';

/** The chat app's green (#07C160) and link color (#576B95). */
const CYL_GREEN: string = '#07C160';
const CYL_LINK: string = '#576B95';
const CYL_GRAY6: string = '#F2F2F7';

/** The launch parameters of the demo (iOS launch arguments), `--pi <name> 1` (EntryAbility stores them). */
export const CYL_CONTACT_TAGS_OPEN_KEY: string = 'CYLContactTags';
export const CYL_CONTACT_TAGS_EDITOR_KEY: string = 'CYLContactTagsEditor';
export const CYL_CONTACT_TAGS_EMPTY_KEY: string = 'CYLContactTagsEmpty';
export const CYL_CONTACT_TAGS_RESET_KEY: string = 'CYLContactTagsResetCache';

/** Gray tags, green selected tags (iOS `CYLContactTagEditorViewController.tagStyle()`). */
export function cylContactTagStyle(): CYLMenuStyle {
  const style = new CYLMenuStyle();
  [CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED].forEach((state: number) => {
    const appearance = style.appearance(state);
    appearance.font = CYLFont.systemFont(16);
    appearance.cornerRadius = 6;
    appearance.borderWidth = 0;
    appearance.contentInsets = new CYLEdgeInsets(5, 14, 5, 14);
  });
  style.normalAppearance.backgroundColor = CYL_GRAY6;
  style.normalAppearance.textColor = '#000000';
  style.selectedAppearance.backgroundColor = '#1A07C160';
  style.selectedAppearance.textColor = CYL_GREEN;
  style.itemHeight = 36;
  style.interitemSpacing = 12;
  style.lineSpacing = 12;
  style.sectionInsets = new CYLEdgeInsets(4, 16, 20, 16);
  style.headerHeight = 40;
  style.headerFont = CYLFont.systemFont(15);
  style.headerTextColor = '#993C3C43';
  style.headerHorizontalInset = 16;
  style.backgroundColor = '#FFFFFF';
  return style;
}

/** What "Edit Tags" opens with and reports to (pushed with the route). */
export class CYLContactTagEditorParam {
  store: CYLContactTagStore;
  selectedTags: string[];
  onDone: (tags: string[]) => void;

  constructor(store: CYLContactTagStore, selectedTags: string[], onDone: (tags: string[]) => void) {
    this.store = store;
    this.selectedTags = selectedTags;
    this.onDone = onDone;
  }
}

/** The contacts page of a tag. */
export class CYLContactListParam {
  title: string = '';
  contacts: CYLContactTagContact[] = [];
  titleOfTag: (id: string) => string | undefined = () => undefined;
}

/** "Manage" / "Done Managing" in the header of "My Tags" (the list's accessory view, a global builder). */
@ObservedV2
class CYLManageButtonModel {
  @Trace title: string = '';
  @Trace hint: string = '';
  action: () => void = () => {
  };
}

const cylManageButtonModel: CYLManageButtonModel = new CYLManageButtonModel();

@ComponentV2
struct CYLManageButton {
  @Param model: CYLManageButtonModel = cylManageButtonModel;

  build() {
    Text(this.model.title)
      .fontSize(15)
      .fontColor(CYL_LINK)
      .accessibilityText(`${this.model.title}, ${this.model.hint}`)
      .id('CYLContactTagsManage')
      .onClick(() => this.model.action())
  }
}

@Builder
function cylManageAccessory(section: number) {
  CYLManageButton({ model: cylManageButtonModel })
}

const cylManageAccessoryBuilder: WrappedBuilder<[number]> = wrapBuilder(cylManageAccessory);

/** The contact's tags, display only (Edit Remarks). */
class CYLRemarkSource implements CYLMenuDataSource {
  store: CYLContactTagStore = new CYLContactTagStore([]);
  tags: string[] = [];
  title: string = '';

  numberOfSectionsInMenu(): number {
    return 1;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.tags.length;
  }

  menuTitleForSection(section: number): string {
    return this.title;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.store.title(this.tags[indexPath.item]) ?? this.tags[indexPath.item];
  }
}

/**
 * "Edit Remarks" (iOS `CYLContactRemarkViewController`): a remark name and the contact's tags (a display-only tag
 * list); "Tags" opens "Edit Tags". Without tags, CYLTableViewPlaceHolder's placeholder takes the list's place and opens
 * the editor too.
 */
@ComponentV2
export struct CYLContactRemarkPage {
  @Require @Param stack: NavPathStack;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private source: CYLRemarkSource = new CYLRemarkSource();
  private tagList: CYLTagListState = new CYLTagListState();
  private placeholder: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();
  @Local tags: string[] = [];
  @Local listHeight: number = 120;
  @Local doneEnabled: boolean = false;

  aboutToAppear(): void {
    if ((AppStorage.get<number>(CYL_CONTACT_TAGS_RESET_KEY) ?? 0) === 1) {
      new CYLContactTagPreferences(this.context, CYL_CONTACT_TAGS_CACHE).clear();
      CYLContactTagServer.reset(this.context);
    }
    if ((AppStorage.get<number>(CYL_CONTACT_TAGS_EMPTY_KEY) ?? 0) === 1) {
      this.source.store = new CYLContactTagStore([]);
      this.tags = [];
    } else {
      this.source.store = CYLContactTagStore.bundled(this.context);
      const store = this.source.store;
      this.tags = CYLContactTagData.bundled(this.context).selectedTags.filter((id: string) => store.contains(id));
    }
    this.source.tags = this.tags;
    this.source.title = cylContactTagsText(this.context, 'tags');
    this.placeholder = CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.Empty,
      cylContactTagsText(this.context, 'remarkNoTags'));
    this.tagList.style = cylContactTagStyle();
    this.tagList.selectionMode = CYLMenuSelectionMode.none;
    this.tagList.showsSectionHeaders = false;
    this.tagList.isScrollEnabled = false;
    this.tagList.menuDataSource = this.source;
    const delegate: CYLMenuDelegate = {
      menuDidSelectItem: () => this.editTags(),
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.listHeight = height;
      }
    };
    this.tagList.menuDelegate = delegate;
    this.tagList.reloadMenuData();
    if ((AppStorage.get<number>(CYL_CONTACT_TAGS_EDITOR_KEY) ?? 0) === 1) {
      setTimeout(() => this.editTags(), 300);
    }
  }

  /** Pushes "Edit Tags". */
  editTags(): void {
    const param = new CYLContactTagEditorParam(this.source.store, this.tags, (tags: string[]) => this.updateTags(tags));
    this.stack.pushPath({ name: CYLDemoRoute.contactTagEditor, param: param });
  }

  /** Shows `tags` as the contact's tags (the editor's result). */
  updateTags(tags: string[]): void {
    this.tags = tags;
    this.source.tags = tags;
    this.tagList.reloadMenuData();
    this.doneEnabled = true;
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: '', showsBack: true, onBack: () => this.stack.pop(),
          rightTitle: cylContactTagsText(this.context, 'done'), rightId: 'CYLContactRemarkDone'
        }).opacity(this.doneEnabled ? 1 : 0.4)
        Scroll() {
          Column() {
            Text(cylContactTagsText(this.context, 'editRemarks'))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 32 })
              .accessibilityLevel('yes')
            TextInput({ placeholder: cylContactTagsText(this.context, 'remarkName') })
              .height(48)
              .borderRadius(8)
              .backgroundColor(CYL_GRAY6)
              .margin({ top: 36, left: 16, right: 16 })
            Row() {
              Text(cylContactTagsText(this.context, 'tags')).fontSize(15).fontColor('#993C3C43')
              SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(12).fontColor(['#4D3C3C43']).margin({ left: 4 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })
            .accessibilityGroup(true)
            .accessibilityText(`${cylContactTagsText(this.context, 'tags')}, ${cylContactTagsText(this.context, 'hintEdit')}`)
            .id('CYLContactRemarkTagsTitle')
            .onClick(() => this.editTags())
            if (this.tags.length > 0) {
              CYLTagListView({ tagList: this.tagList }).height(this.listHeight).id('CYLContactRemarkTags')
            } else {
              Column() {
                CYLPlaceholderView({ model: this.placeholder })
              }
              .padding(16)
              .accessibilityGroup(true)
              .accessibilityText(`${cylContactTagsText(this.context, 'remarkNoTags')}, ${cylContactTagsText(this.context, 'hintEdit')}`)
              .id('CYLContactRemarkEmptyTags')
              .onClick(() => this.editTags())
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
      .backgroundColor('#FFFFFF')
    }
    .hideTitleBar(true)
  }
}

/** One item of a section: a tag (its id), or "+ New Tag" (no name: asks for one) / "+ New tag: <name>". */
class CYLContactTagItem {
  id: string | undefined = undefined;
  createName: string | undefined = undefined;
  isCreate: boolean = false;

  static tag(id: string): CYLContactTagItem {
    const item = new CYLContactTagItem();
    item.id = id;
    return item;
  }

  static create(name: string | undefined): CYLContactTagItem {
    const item = new CYLContactTagItem();
    item.isCreate = true;
    item.createName = name;
    return item;
  }
}

enum CYLContactTagSectionKind {
  recent,
  mine,
  results
}

class CYLContactTagSection {
  kind: CYLContactTagSectionKind = CYLContactTagSectionKind.mine;
  title: string = '';
  items: CYLContactTagItem[] = [];
}

/** The empty state shown with CYLPlaceholderView. */
enum CYLContactTagsEmptyState {
  none,
  noMatch,
  noTags
}

/**
 * The data source of "Edit Tags": its sections (made by the page), the menu's questions about them, and the edits
 * (remove, move, rename) handed back to the page.
 */
class CYLContactTagsEditorSource implements CYLMenuDataSource {
  sections: CYLContactTagSection[] = [];
  store: CYLContactTagStore = new CYLContactTagStore([]);
  onRemove: (id: string) => void = () => {
  };
  onMove: (from: number, to: number) => void = () => {
  };
  onRename: (id: string, title: string) => void = () => {
  };

  private item(indexPath: CYLIndexPath): CYLContactTagItem {
    return this.sections[indexPath.section].items[indexPath.item];
  }

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].items.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].title;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    const element = this.item(indexPath);
    return element.isCreate ? (element.createName ?? '') : (this.store.title(element.id ?? '') ?? (element.id ?? ''));
  }

  menuItemType = (indexPath: CYLIndexPath): CYLMenuItemType =>
    this.item(indexPath).isCreate ? CYLMenuItemType.create : CYLMenuItemType.tag;

  menuAccessoryViewForSection = (section: number): WrappedBuilder<[number]> | undefined =>
    this.sections[section].kind === CYLContactTagSectionKind.mine ? cylManageAccessoryBuilder : undefined;

  /** "Recent" shows CollectionViewClassifyMenu's built-in clear button. */
  menuShowsClearButtonForSection = (section: number): boolean =>
    section < this.sections.length && this.sections[section].kind === CYLContactTagSectionKind.recent;

  /** Only "My Tags" takes part in "Manage". */
  menuSectionAllowsEditing = (section: number): boolean =>
    section < this.sections.length && this.sections[section].kind === CYLContactTagSectionKind.mine;

  /** Stable cache keys: "Recent" comes and goes. */
  menuCacheKeyForSection = (section: number): string => {
    const kind = this.sections[section].kind;
    return kind === CYLContactTagSectionKind.recent ? CYL_CONTACT_TAGS_RECENT :
      (kind === CYLContactTagSectionKind.mine ? CYL_CONTACT_TAGS_MINE : 'results');
  };

  /** The tag's id: its primary key for the cache, the server and the contacts. */
  menuIdentifierForItem = (indexPath: CYLIndexPath): string => {
    const element = this.item(indexPath);
    return element.isCreate ? `create:${element.createName ?? ''}` : (element.id ?? '');
  };

  menuRemoveItem = (indexPath: CYLIndexPath): void => {
    const element = this.item(indexPath);
    if (!element.isCreate && element.id !== undefined) {
      this.onRemove(element.id);
    }
  };

  menuMoveItem = (from: CYLIndexPath, to: CYLIndexPath): void => {
    this.onMove(from.item, to.item);
  };

  /** The pencil's rename in "Manage": the title changes, the id (and its contacts) stay. */
  menuRenameItem = (indexPath: CYLIndexPath, title: string): void => {
    const element = this.item(indexPath);
    if (!element.isCreate && element.id !== undefined) {
      this.onRename(element.id, title);
    }
  };
}

/**
 * "Edit Tags" (iOS `CYLContactTagEditorViewController`): chooses, creates, renames and deletes a contact's tags,
 * searched with this library's `CYLSearchBarView`; the tags are CollectionViewClassifyMenu's tag list.
 * - "Recent" (the list's built-in clear button) and "My Tags" (with "Manage"; folded to three rows).
 * - "Manage" switches the list into its editing mode: the edit icon and the cross on each tag of "My Tags"; the pencil
 *   or a title tap renames in the editing bar ("Done"), the editing bar adds otherwise ("Add"); leaving "Manage" uploads.
 * - Typing shows "Search Results" and "+ New tag: <text>"; the enter key creates the typed tag.
 * - CYLPlaceholderView shows the empty states (no match, no tags) below the tags.
 * - Network sync (CYLContactTagServer): opening shows cache A at once, then downloads B; the sync button pulls an edit
 *   simulated on another device.
 */
@ComponentV2
export struct CYLContactTagEditorPage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLContactTagEditorParam;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private store: CYLContactTagStore = new CYLContactTagStore([]);
  private initialSelection: string[] = [];
  private selectedTags: string[] = [];
  private source: CYLContactTagsEditorSource = new CYLContactTagsEditorSource();
  private query: string = '';
  private tagList: CYLTagListState =
    new CYLTagListState(new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon));
  private searchBar: CYLSearchBarView = new CYLSearchBarView();
  private editingBar: CYLSearchBarView = CYLSearchBarView.editingBar('', '');
  private server: CYLContactTagServer | undefined = undefined;
  private renamingIndexPath: CYLIndexPath | undefined = undefined;
  @Local isManaging: boolean = false;
  @Local doneEnabled: boolean = false;
  @Local emptyState: CYLContactTagsEmptyState = CYLContactTagsEmptyState.none;
  @Local contentHeight: number = 0;
  @Local placeholder: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();

  aboutToAppear(): void {
    this.store = this.param.store;
    this.initialSelection = this.param.selectedTags.filter((id: string) => this.store.contains(id));
    this.selectedTags = this.initialSelection.slice();
    this.server = new CYLContactTagServer(this.context, this.getUIContext());
    // The search field is CYLSearchBarView: its delegate reports each change and the enter key.
    this.searchBar.placeholder = cylContactTagsText(this.context, 'search');
    this.searchBar.delegate = {
      searchBarViewTextDidChange: (view: CYLSearchBarView, text: string) => this.queryChanged(text),
      searchBarViewSearchButtonClicked: (view: CYLSearchBarView) => {
        if (this.store.canCreate(this.query)) {
          this.createTag(this.query);
        } else {
          view.hideKeyboard();
        }
      }
    };
    // The edit field of "Manage": the core's editing bar, at the page's bottom, riding on the keyboard.
    this.editingBar = CYLSearchBarView.editingBar(cylContactTagsText(this.context, 'tagName'),
      cylContactTagsText(this.context, 'add'));
    this.editingBar.editingSubmitHandler = (view: CYLSearchBarView, text: string) => this.submitEditingBar(text);
    this.editingBar.pinToKeyboard(this.getUIContext());
    cylManageButtonModel.action = () => this.toggleManaging();

    this.tagList.style = cylContactTagStyle();
    this.tagList.selectionMode = CYLMenuSelectionMode.multiple;
    this.tagList.allowsEmptySelection = true;
    this.tagList.defaultVisibleRows = 3;
    // "Manage" edits in the editing bar, not in the list's own field; leaving it uploads to the server.
    this.tagList.showsAddItemViewWhileEditing = false;
    this.tagList.renameRequestHandler = (indexPath: CYLIndexPath, title: string) => this.beginRenaming(indexPath, title);
    this.tagList.editingFinishHandler = () => this.server?.upload(this.store.cacheSections);
    this.tagList.menuDataSource = this.makeSource();
    this.tagList.menuDelegate = this.makeDelegate();
    this.reload();
    // Cache A is what the store already shows; the server's sections, when they arrive, replace them.
    this.server.fetch([CYL_CONTACT_TAGS_MINE, CYL_CONTACT_TAGS_RECENT], (sections) => {
      if (this.store.apply(sections)) {
        this.reload();
      }
    });
  }

  aboutToDisappear(): void {
    this.server?.cancel();
  }

  private item(indexPath: CYLIndexPath): CYLContactTagItem {
    return this.source.sections[indexPath.section].items[indexPath.item];
  }

  private makeSource(): CYLMenuDataSource {
    this.source.store = this.store;
    this.source.onRemove = (id: string) => {
      this.store.deleteTag(id);
      this.selectedTags = this.selectedTags.filter((selected: string) => selected !== id);
      this.source.sections = this.makeSections();
    };
    this.source.onMove = (from: number, to: number) => {
      this.store.moveTag(from, to);
      this.source.sections = this.makeSections();
    };
    this.source.onRename = (id: string, title: string) => {
      this.store.renameTag(id, title);
      this.source.sections = this.makeSections();
    };
    return this.source;
  }

  private makeDelegate(): CYLMenuDelegate {
    const delegate: CYLMenuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        const element = this.item(indexPath);
        if (element.isCreate || element.id === undefined) {
          return;
        }
        if (this.isManaging) {
          // In "Manage" the pencil and the title rename (the list calls `renameRequestHandler`); another tap shows the
          // tag's contacts.
          this.showContacts(element.id);
        } else {
          this.select(element.id);
        }
      },
      menuDidDeselectItem: (menu: Object, indexPath: CYLIndexPath) => {
        const element = this.item(indexPath);
        if (!element.isCreate && element.id !== undefined) {
          this.deselect(element.id);
        }
      },
      menuDidRequestNewItemWithName: (menu: Object, name: string) => {
        if (this.isManaging) {
          this.store.createTag(name);
          this.reload();
        } else if (name.length === 0) {
          this.promptForNewTag();
        } else {
          this.createTag(name);
        }
      },
      menuDidTapClearButtonInSection: () => {
        this.store.clearRecent();
        this.reload();
      },
      menuDidChangeEditing: (menu: Object, editing: boolean) => {
        this.isManaging = editing;
        this.updateEditingBar();
        this.reload();
      },
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.contentHeight = height;
      }
    };
    return delegate;
  }

  // Editing bar

  private beginRenaming(indexPath: CYLIndexPath, title: string): void {
    this.renamingIndexPath = indexPath;
    this.editingBar.cancelButtonTitle = cylContactTagsText(this.context, 'done');
    this.editingBar.setText(title, false);
    this.editingBar.showKeyboard();
  }

  private submitEditingBar(text: string): void {
    if (this.renamingIndexPath !== undefined) {
      this.renamingIndexPath = undefined;
      this.tagList.finishRenaming(text);
      this.editingBar.hideKeyboard();
    } else {
      this.tagList.submitNewItem(text);
    }
    this.editingBar.setText('', false);
    this.editingBar.cancelButtonTitle = cylContactTagsText(this.context, 'add');
  }

  private updateEditingBar(): void {
    if (!this.isManaging) {
      if (this.renamingIndexPath !== undefined) {
        this.renamingIndexPath = undefined;
        this.tagList.cancelRenaming();
      }
      this.editingBar.setText('', false);
      this.editingBar.cancelButtonTitle = cylContactTagsText(this.context, 'add');
      this.editingBar.hideKeyboard();
    }
  }

  // Content

  private makeSections(): CYLContactTagSection[] {
    if (this.query.length > 0) {
      const results = new CYLContactTagSection();
      results.kind = CYLContactTagSectionKind.results;
      results.title = cylContactTagsText(this.context, 'results');
      results.items = this.store.tagsMatching(this.query).map((id: string) => CYLContactTagItem.tag(id));
      if (this.store.canCreate(this.query)) {
        results.items.push(CYLContactTagItem.create(this.query));
      }
      return [results];
    }
    const sections: CYLContactTagSection[] = [];
    if (this.store.recentIDs.length > 0) {
      const recent = new CYLContactTagSection();
      recent.kind = CYLContactTagSectionKind.recent;
      recent.title = cylContactTagsText(this.context, 'recent');
      recent.items = this.store.recentIDs.map((id: string) => CYLContactTagItem.tag(id));
      sections.push(recent);
    }
    const mine = new CYLContactTagSection();
    mine.kind = CYLContactTagSectionKind.mine;
    mine.title = cylContactTagsText(this.context, 'mine');
    mine.items = this.store.tagIDs.map((id: string) => CYLContactTagItem.tag(id));
    // While managing, the editing bar replaces "+ New Tag".
    if (!this.tagList.isEditing) {
      mine.items.push(CYLContactTagItem.create(undefined));
    }
    sections.push(mine);
    return sections;
  }

  private reload(): void {
    this.source.sections = this.makeSections();
    cylManageButtonModel.title = cylContactTagsText(this.context, this.tagList.isEditing ? 'doneManaging' : 'manage');
    cylManageButtonModel.hint = cylContactTagsText(this.context, this.tagList.isEditing ? 'hintDoneManaging' : 'hintManage');
    this.tagList.reloadMenuData();
    this.syncSelection();
    this.updateDone();
    this.updatePlaceholder();
  }

  private makeEmptyState(): CYLContactTagsEmptyState {
    if (this.query.length > 0) {
      return this.store.tagsMatching(this.query).length === 0 ? CYLContactTagsEmptyState.noMatch : CYLContactTagsEmptyState.none;
    }
    return this.store.tags.length === 0 ? CYLContactTagsEmptyState.noTags : CYLContactTagsEmptyState.none;
  }

  private updatePlaceholder(): void {
    const state = this.makeEmptyState();
    if (state === this.emptyState) {
      return;
    }
    this.emptyState = state;
    if (state === CYLContactTagsEmptyState.noMatch) {
      this.placeholder = CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.NoResults,
        cylContactTagsText(this.context, 'noMatch'));
    } else if (state === CYLContactTagsEmptyState.noTags) {
      this.placeholder = CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.Empty,
        cylContactTagsText(this.context, 'noTags'));
    }
  }

  private syncSelection(): void {
    const paths: CYLIndexPath[] = [];
    this.source.sections.forEach((section: CYLContactTagSection, s: number) => {
      section.items.forEach((element: CYLContactTagItem, i: number) => {
        if (!element.isCreate && element.id !== undefined && this.selectedTags.includes(element.id)) {
          const path: CYLIndexPath = { section: s, item: i };
          paths.push(path);
        }
      });
    });
    this.tagList.selectedIndexPaths = paths;
  }

  /** "Done" is green with a selection or a change, and off while searching. */
  private updateDone(): void {
    const changed = this.selectedTags.length !== this.initialSelection.length ||
      this.selectedTags.some((id: string) => !this.initialSelection.includes(id));
    this.doneEnabled = this.query.length === 0 && (this.selectedTags.length > 0 || changed);
  }

  // Actions

  private queryChanged(text: string): void {
    if (this.tagList.isEditing && text.length > 0) {
      this.tagList.setEditing(false);
    }
    this.query = CYLContactTagStore.normalizedName(text);
    this.reload();
  }

  private select(id: string): void {
    if (!this.selectedTags.includes(id)) {
      this.selectedTags.push(id);
    }
    this.syncSelection();
    this.updateDone();
  }

  private deselect(id: string): void {
    this.selectedTags = this.selectedTags.filter((selected: string) => selected !== id);
    this.syncSelection();
    this.updateDone();
  }

  /** Creates the tag (or finds it), selects it and leaves the search. */
  private createTag(name: string): void {
    const id = this.store.createTag(name);
    if (id === undefined) {
      return;
    }
    if (!this.selectedTags.includes(id)) {
      this.selectedTags.push(id);
    }
    this.searchBar.setText('', false);
    this.query = '';
    this.searchBar.hideKeyboard();
    this.reload();
  }

  private promptForNewTag(): void {
    // A short dialog with a text field (iOS UIAlertController): the editing bar is for "Manage" only.
    let name = '';
    this.getUIContext().showAlertDialog({
      title: cylContactTagsText(this.context, 'newTag'),
      message: cylContactTagsText(this.context, 'tagName'),
      primaryButton: { value: cylContactTagsText(this.context, 'cancel'), action: () => {
      } },
      secondaryButton: { value: cylContactTagsText(this.context, 'ok'), action: () => this.createTag(name) }
    });
    name = this.query;
  }

  private toggleManaging(): void {
    if (this.tagList.isEditing) {
      this.tagList.setEditing(false, true);
    } else {
      this.searchBar.setText('', false);
      this.query = '';
      this.searchBar.hideKeyboard();
      this.tagList.setEditing(true, true);
    }
    this.isManaging = this.tagList.isEditing;
    this.reload();
  }

  private syncFromOtherDevices(): void {
    this.server?.simulateOtherDeviceEdit(this.store.cacheSections.get(CYL_CONTACT_TAGS_MINE) ?? []);
    this.server?.fetch([CYL_CONTACT_TAGS_MINE], (sections) => {
      if (this.store.apply(sections)) {
        this.reload();
      }
    });
  }

  private showContacts(id: string): void {
    const param = new CYLContactListParam();
    param.title = this.store.title(id) ?? id;
    param.contacts = this.store.contactsWithTag(id);
    const store = this.store;
    param.titleOfTag = (tag: string) => store.title(tag);
    this.stack.pushPath({ name: CYLDemoRoute.contactList, param: param });
  }

  private done(): void {
    if (!this.doneEnabled) {
      return;
    }
    this.store.markUsed(this.selectedTags);
    this.param.onDone(this.selectedTags.slice());
    this.searchBar.hideKeyboard();
    this.stack.pop();
  }

  @Builder
  actions() {
    Row() {
      SymbolGlyph($r('sys.symbol.arrow_clockwise'))
        .fontSize(22)
        .fontColor([CYL_LINK])
        .width(44)
        .height(44)
        .accessibilityText(cylContactTagsText(this.context, 'sync'))
        .id('CYLContactTagsSync')
        .onClick(() => this.syncFromOtherDevices())
      Text(cylContactTagsText(this.context, 'done'))
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.doneEnabled ? '#FFFFFF' : '#4D3C3C43')
        .backgroundColor(this.doneEnabled ? CYL_GREEN : '#29787880')
        .borderRadius(4)
        .padding({ left: 12, right: 12 })
        .height(32)
        .id('CYLContactTagsDone')
        .onClick(() => this.done())
    }
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylContactTagsText(this.context, 'editTags'), showsBack: true, onBack: () => this.stack.pop(),
          hasRightView: true, rightView: () => {
            this.actions()
          }
        })
        CYLSearchBarComponent({ searchBarView: this.searchBar })
          .margin({ left: 8, right: 8, top: 8 })
          .id('CYLContactTagsSearchBar')
        Stack({ alignContent: Alignment.Top }) {
          CYLTagListView({ tagList: this.tagList }).width('100%').height('100%').id('CYLContactTagsList')
          if (this.emptyState !== CYLContactTagsEmptyState.none) {
            // The free space below the tags shown ("+ New tag" stays tappable above it); the page ends at the keyboard.
            Column() {
              CYLPlaceholderView({ model: this.placeholder })
            }
            .width('100%')
            .layoutWeight(1)
            .margin({ top: this.contentHeight })
            .height(`calc(100% - ${this.contentHeight}vp)`)
            .justifyContent(FlexAlign.Center)
            .hitTestBehavior(HitTestMode.Transparent)
            .id('CYLContactTagsPlaceholder')
          }
        }
        .layoutWeight(1)
        .margin({ top: 8 })
        // The tag list draws only within its frame, above the editing bar.
        .clip(true)
        if (this.isManaging) {
          Column() {
            CYLSearchBarComponent({ searchBarView: this.editingBar }).id('CYLSearchEditingBar')
          }
          .backgroundColor('#FFFFFF')
          .padding({ top: 4, bottom: 4 })
        }
      }
      .backgroundColor('#FFFFFF')
    }
    .hideTitleBar(true)
  }
}

/**
 * The contacts that have a tag (iOS `CYLContactListViewController`): the page a tap on a tag opens in "Manage" mode;
 * CYLTableViewPlaceHolder's placeholder when none has it.
 */
@ComponentV2
export struct CYLContactListPage {
  @Require @Param stack: NavPathStack;
  @Require @Param param: CYLContactListParam;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;
  private placeholder: CYLPlaceholderViewModel = new CYLPlaceholderViewModel();

  aboutToAppear(): void {
    this.placeholder = CYLPlaceholderViewModel.initWithStyleText(CYLPlaceholderStyle.PersonOff,
      cylContactTagsText(this.context, 'noContacts', this.param.title));
  }

  build() {
    NavDestination() {
      Column() {
        CYLDemoNavBar({
          title: cylContactTagsText(this.context, 'contactsTitle', this.param.title, this.param.contacts.length),
          showsBack: true, onBack: () => this.stack.pop()
        })
        if (this.param.contacts.length === 0) {
          Column() {
            CYLPlaceholderView({ model: this.placeholder })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .id('CYLContactListEmpty')
        } else {
          List() {
            ForEach(this.param.contacts, (contact: CYLContactTagContact) => {
              ListItem() {
                Column() {
                  Text(contact.name).fontSize(17)
                  Text(contact.tags.map((id: string) => this.param.titleOfTag(id) ?? '').filter((t: string) => t.length > 0).join(' · '))
                    .fontSize(13)
                    .fontColor('#993C3C43')
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .width('100%')
              }
            }, (contact: CYLContactTagContact) => contact.name)
          }
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin(16)
          .layoutWeight(1)
          .id('CYLContactList')
        }
      }
      .backgroundColor(CYL_GRAY6)
    }
    .hideTitleBar(true)
  }
}
