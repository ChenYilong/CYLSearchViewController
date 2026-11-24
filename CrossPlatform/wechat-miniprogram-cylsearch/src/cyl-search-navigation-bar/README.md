# cyl-search-navigation-bar

The navigation bar of a page with `"navigationStyle": "custom"` that always holds the search bar (iOS: the search bar is
in the `UINavigationBar`). It sits below the status bar, is as high as WeChat's navigation bar and keeps clear of the
capsule menu button. The page never sets a width, margin or padding to fit the back button: the component measures the
width that is left (`wx.getWindowInfo`, `wx.getMenuButtonBoundingClientRect`, through `cylNavigationBarWidthsFrom`).

## Use

```json
{
  "navigationStyle": "custom",
  "usingComponents": {
    "cyl-search-navigation-bar": "/components/cyl-search-navigation-bar/index",
    "cyl-search-bar": "/components/cyl-search-bar/index"
  }
}
```

```xml
<cyl-search-navigation-bar showsBack="{{true}}" bind:back="onBack">
  <cyl-search-bar value="{{query}}" fieldHeight="36" />
</cyl-search-navigation-bar>
```

Put the search bar in the default slot; the content of the page follows the bar.

## API

| Name | Kind | Default | Meaning |
| --- | --- | --- | --- |
| `showsBack` | property | `false` | A back button before the slot. |
| `backLabel` | property | the localized "Back" (`search.back`) | The back button's accessibility label. |
| `autoBack` | property | `true` | The back button also calls `wx.navigateBack()`; `false` leaves the navigation to the page. |
| `back` | event | | The back button was tapped (sent before `wx.navigateBack()`). |

The measured values are in the component's `data.metrics` and in `cylNavigationMetrics()` (`fieldHeight` is 36).

## Accessibility

The back button is `role="button"` with the localized label; its arrow is `aria-hidden`.
