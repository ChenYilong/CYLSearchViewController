// What every tab page does in onShow: selects its tab in the custom tab bar.
function cylSelectTab(page, identifier) {
  if (typeof page.getTabBar === 'function' && page.getTabBar()) {
    page.getTabBar().cylSelect(identifier);
  }
}
module.exports = { cylSelectTab };
