// Where a bar that takes the navigation bar's place goes on a page with "navigationStyle": "custom": below the status
// bar, as high as the navigation bar, and clear of WeChat's menu button (the capsule at the top right), which every
// mini program page keeps. iOS puts such a bar where the navigation bar was (CYLSearchView over the toolbar).

/** The metrics from the window and menu button rectangles (pure, tested with Node). */
function cylNavigationMetricsFrom(window, menuButton) {
  const statusBarHeight = (window && window.statusBarHeight) || 20;
  const windowWidth = (window && window.windowWidth) || 375;
  if (!menuButton || !menuButton.height) {
    return { statusBarHeight, navigationBarHeight: 44, trailingInset: 0, windowWidth, top: statusBarHeight };
  }
  // The navigation bar is centered on the menu button, with the same gap above and below it.
  const gap = Math.max(0, menuButton.top - statusBarHeight);
  const navigationBarHeight = menuButton.height + gap * 2;
  // The bar ends where the menu button starts, with the same margin the menu button keeps from the screen edge.
  const trailingInset = Math.max(0, windowWidth - menuButton.left) + Math.max(0, windowWidth - menuButton.right);
  return { statusBarHeight, navigationBarHeight, trailingInset, windowWidth, top: statusBarHeight };
}

/** The metrics of this device. */
function cylNavigationMetrics() {
  let window = {};
  let menuButton = null;
  try {
    window = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
    menuButton = wx.getMenuButtonBoundingClientRect ? wx.getMenuButtonBoundingClientRect() : null;
  } catch (error) {
    menuButton = null;
  }
  return cylNavigationMetricsFrom(window, menuButton);
}

module.exports = { cylNavigationMetrics, cylNavigationMetricsFrom };
