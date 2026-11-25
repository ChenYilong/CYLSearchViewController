import {
  CYLIndexPath, CYLMenuDataSource, CYLMenuDelegate, CYLMenuFoldControl, CYLMenuFoldControlContent,
  CYLMenuFoldControlPosition, CYLMenuSelectionMode, CYLMenuStyle, CYLTagBackgroundStyle, CYLTagListState,
  CYLTagListView, CYLTagLongPressActions, CYLTagTitleMaxLines
} from '@cyl/classifymenu';
import { CYLSearchTagListStyle } from 'cylsearch';

/**
 * One row of a grouped demo list: the tag's main title and icon, and the subtitle a long press shows in a callout.
 */
export interface CYLDemoTagRow {
  title: string;
  subtitle: string;
  image: Resource | undefined;
}

/**
 * One section of a grouped demo list: a header that always has a title, and its rows.
 */
export class CYLDemoTagSection {
  header: string;
  rows: CYLDemoTagRow[];

  constructor(header: string, rows: CYLDemoTagRow[]) {
    this.header = header;
    this.rows = rows;
  }
}

/**
 * The data source of a grouped demo list (docs/instructions/example-demos.md rule 1): a section per group, a tag per row.
 */
class CYLDemoTagSource implements CYLMenuDataSource {
  sections: CYLDemoTagSection[] = [];

  numberOfSectionsInMenu(): number {
    return this.sections.length;
  }

  menuNumberOfItemsInSection(section: number): number {
    return this.sections[section].rows.length;
  }

  menuTitleForSection(section: number): string {
    return this.sections[section].header;
  }

  menuTitleForItem(indexPath: CYLIndexPath): string {
    return this.sections[indexPath.section].rows[indexPath.item].title;
  }

  menuSubtitleForItem = (indexPath: CYLIndexPath): string | undefined => {
    const subtitle: string = this.sections[indexPath.section].rows[indexPath.item].subtitle;
    return subtitle.length > 0 ? subtitle : undefined;
  };

  menuImageForItem = (indexPath: CYLIndexPath): Resource | undefined =>
  this.sections[indexPath.section].rows[indexPath.item].image;
}

/**
 * A grouped demo list as ClassifyMenu's tag list (docs/instructions/example-demos.md, rules 1 to 7): titled sections, the
 * Liquid Glass board and glass tags from the shared style (CYLSearchTagListStyle), adaptive tag width, titles that
 * wrap, a 3-row fold whose control is the tail tag with the chevron icon only, a tap = the cell's tap, a long press
 * shows the subtitle. The list background stays clear: the page draws a gradient behind it.
 */
@ComponentV2
export struct CYLDemoTagMenuView {
  @Require @Param sections: CYLDemoTagSection[];
  @Param tagId: string = '';
  @Event onSelect: (section: number, item: number) => void = () => {
  };
  @Local menuHeight: number = 200;
  private source: CYLDemoTagSource = new CYLDemoTagSource();
  private list: CYLTagListState = new CYLTagListState();

  aboutToAppear(): void {
    this.source.sections = this.sections;
    const style = new CYLMenuStyle();
    // The glass look (translucent tint, no border) is chosen by the shared style's one parameter.
    const previous: CYLTagBackgroundStyle = CYLSearchTagListStyle.tagBackgroundStyle;
    CYLSearchTagListStyle.tagBackgroundStyle = CYLTagBackgroundStyle.liquidGlass;
    CYLSearchTagListStyle.applyDefaults(style);
    CYLSearchTagListStyle.tagBackgroundStyle = previous;
    style.titleMaxLines = CYLTagTitleMaxLines.unlimited;
    this.list.style = style;
    CYLSearchTagListStyle.applyBackgroundStyle('liquidGlass', this.list);
    // The fold control is the last tag, the chevron icon only; set explicitly.
    this.list.foldControl = new CYLMenuFoldControl(CYLMenuFoldControlPosition.tail, CYLMenuFoldControlContent.icon);
    this.list.defaultVisibleRows = 3;
    this.list.selectionMode = CYLMenuSelectionMode.none;
    this.list.isScrollEnabled = false;
    this.list.longPressAction = CYLTagLongPressActions.callout;
    this.list.menuDataSource = this.source;
    const delegate: CYLMenuDelegate = {
      menuDidSelectItem: (menu: Object, indexPath: CYLIndexPath) => {
        this.onSelect(indexPath.section, indexPath.item);
      },
      menuDidChangeContentHeight: (menu: Object, height: number) => {
        this.menuHeight = height;
      }
    };
    this.list.menuDelegate = delegate;
    this.list.reloadMenuData();
  }

  build() {
    CYLTagListView({ tagList: this.list }).width('100%').height(this.menuHeight).id(this.tagId)
  }
}
