// Shared by the list screens of the QMUI search port (Search controller, Search bar styles, Short list): the height under
// the example's navigation bar that the core's content page fills, and the stroked accessory squares of QDSearchBarViewController.
const { cylNavigationMetrics } = require('../components/core/CYLSearchResources');

/** The height of the window under the custom navigation bar: the content page is a fixed-height column. */
function cylHostHeight() {
  const metrics = cylNavigationMetrics();
  let height = 667;
  try {
    height = (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).windowHeight || height;
  } catch (error) {
    height = 667;
  }
  return height - metrics.statusBarHeight - metrics.navigationBarHeight;
}

/** The colors QDSearchBarViewController picks an accessory's stroke from (UIKit's system colors). */
const ACCESSORY_COLORS = ['#FF3B30', '#007AFF', '#34C759', '#FF9500', '#AF52DE', '#30B0C7'];

module.exports = { cylHostHeight, ACCESSORY_COLORS };
