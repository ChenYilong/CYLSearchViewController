# cyl-search-refresh-button

The refresh button of a tag list header, the mini program counterpart of iOS `CYLSearchTagListHeader.applyRefreshIcon(to:)`.
It draws the built-in refresh icon (`images/refresh.svg` of this package, never three dots and never text) and reads the
localized label `tagList.refresh` to screen readers: Refresh, 更新, 刷新, 重新整理 (en, ja, zh-Hans, zh-Hant, from the
core's string table, key `cyl_tagList_refresh`).

## Use

```json
{ "usingComponents": { "cyl-search-refresh-button": "/components/cyl-search-refresh-button/index" } }
```

```xml
<view class="header">
  <text role="heading">{{title}}</text>
  <cyl-search-refresh-button bind:tap="refreshDiscover" />
</view>
```

## API

| Name | Kind | Default | Meaning |
| --- | --- | --- | --- |
| `label` | property | the localized `tagList.refresh` | Overrides the accessibility label. |
| `tap` | event | | The button was tapped (`detail` is empty). The page shows the next page of data. |

## Accessibility

The button is `role="button"` with `aria-label` set to the label; the icon is `aria-hidden`. The label comes from the
core's string table, so it follows the language of WeChat. The label rule is pinned by
`test/cyl_search_refresh_button_label.test.js`.
