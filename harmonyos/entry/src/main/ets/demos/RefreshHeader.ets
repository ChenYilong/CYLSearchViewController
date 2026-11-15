import { common } from '@kit.AbilityKit';
import { cylAppText } from '../common/DemoCommon';

/**
 * The states of a refresh header (CYLTableViewPlaceHolder `CYLRefreshState`).
 */
export enum CYLRefreshState {
  idle = 0,
  pulling = 1,
  refreshing = 2
}

/**
 * CYLTableViewPlaceHolder's `CYLRefreshNormalHeader`, as the iOS example shows it: an arrow (a spinner while
 * refreshing) beside two lines, the state text and "Last update: Today HH:mm". CYLTableViewPlaceHolder has no
 * HarmonyOS library yet, so the example draws the header in ArkUI's `Refresh`, with the same texts.
 */
@ComponentV2
export struct CYLRefreshNormalHeader {
  @Param state: CYLRefreshState = CYLRefreshState.idle;
  @Param lastUpdated: Date | undefined = undefined;
  private context: common.Context = this.getUIContext().getHostContext() as common.Context;

  private stateText(): string {
    if (this.state === CYLRefreshState.refreshing) {
      return cylAppText(this.context, 'refresh_refreshing');
    }
    return cylAppText(this.context, this.state === CYLRefreshState.pulling ? 'refresh_pulling' : 'refresh_idle');
  }

  private timeText(): string {
    const last = cylAppText(this.context, 'refresh_last_time');
    if (this.lastUpdated === undefined) {
      return last + cylAppText(this.context, 'refresh_none_last_date');
    }
    const pad = (n: number) => (n < 10 ? '0' : '') + n;
    return `${last}${cylAppText(this.context, 'refresh_today')} ${pad(this.lastUpdated.getHours())}:${pad(this.lastUpdated.getMinutes())}`;
  }

  build() {
    Row({ space: 16 }) {
      if (this.state === CYLRefreshState.refreshing) {
        LoadingProgress().width(24).height(24).color($r('sys.color.font_secondary'))
      } else {
        SymbolGlyph($r('sys.symbol.arrow_down'))
          .fontSize(22)
          .fontColor([$r('sys.color.font_secondary')])
          .rotate({ angle: this.state === CYLRefreshState.pulling ? 180 : 0 })
          .animation({ duration: 250 })
      }
      Column({ space: 4 }) {
        Text(this.stateText()).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_secondary'))
        Text(this.timeText()).fontSize(14).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_secondary'))
      }
    }
    .width('100%')
    .height(54)
    .justifyContent(FlexAlign.Center)
    .accessibilityGroup(true)
  }
}
