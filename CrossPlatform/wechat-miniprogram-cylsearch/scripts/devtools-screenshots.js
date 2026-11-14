// Opens example/ in WeChat DevTools (logged in; Settings > Security > service port on), visits every tab of the
// CYLTabBarController tab bar and the plus button's page, and saves a screenshot of each:
// node scripts/devtools-screenshots.js <output folder> [path to example]. Needs: npm i miniprogram-automator,
// and node scripts/sync-example.js first.
const path = require('path');
const automator = require('miniprogram-automator');

const out = process.argv[2] || '.';
const projectPath = process.argv[3] || path.join(__dirname, '..', 'example');
const errors = [];

(async () => {
  const mp = await automator.launch({
    cliPath: '/Applications/wechatwebdevtools.app/Contents/MacOS/cli',
    projectPath,
  });
  mp.on('console', (message) => {
    if (message.type === 'error') errors.push(JSON.stringify(message.args).slice(0, 300));
  });
  mp.on('exception', (error) => errors.push(`${error.message} ${error.stack || ''}`.slice(0, 500)));
  const shot = (name) => mp.screenshot({ path: path.join(out, `miniprogram-${name}.png`) });
  try {
    // Wait until the app has opened its first page; a reLaunch sent earlier fails ("Uncaught").
    for (let i = 0; i < 20 && !(await mp.currentPage().catch(() => null)); i += 1) {
      await new Promise((resolve) => setTimeout(resolve, 500));
    }
    await mp.evaluate(() => wx.clearStorageSync());
    console.log('storage cleared');
    // Right after a compile the first reLaunch can fail ("Uncaught"): try again.
    let page = null;
    for (let attempt = 1; !page; attempt += 1) {
      try {
        page = await mp.reLaunch('/pages/search/index');
      } catch (error) {
        if (attempt >= 6) throw error;
        await new Promise((resolve) => setTimeout(resolve, 1500));
      }
    }
    await page.waitFor(2500);
    await shot('1-search-tab');

    page = await mp.switchTab('/pages/tagStyle/index');
    await page.waitFor(1200);
    await page.callMethod('openSearch');
    await page.waitFor(1000);
    await shot('2-tag-style-empty-cache');
    const search = await page.$('#search');
    const input = await (await search.$('cyl-search-bar')).$('input');
    await input.input('sw');
    await input.trigger('confirm', { value: 'Swift' });
    await page.waitFor(600);
    await page.callMethod('openSearch');
    await page.waitFor(1000);
    await shot('3-tag-style-filtered');
    const data = await search.data();
    console.log('tag style:', JSON.stringify({ shown: data.shownSuggestions, cached: data.showsCachedQueries }));

    page = await mp.switchTab('/pages/listStyle/index');
    await page.waitFor(1200);
    await page.callMethod('openSearch');
    await page.waitFor(800);
    const listInput = await (await (await page.$('#search')).$('cyl-search-bar')).$('input');
    await listInput.input('zz');
    await listInput.trigger('input', { value: 'zz' });
    await page.waitFor(800);
    await shot('4-list-style-empty-results');

    page = await mp.switchTab('/pages/discover/index');
    await page.waitFor(1500);
    await shot('5-discover-items');

    page = await mp.switchTab('/pages/examples/index');
    await page.waitFor(1200);
    await shot('6-examples');

    page = await mp.navigateTo('/pages/plus/index');
    await page.waitFor(1500);
    await shot('7-plus-search-bars');

    console.log('errors:', errors.length ? errors.join('\n') : 'none');
  } finally {
    await mp.close();
  }
})().catch((error) => {
  console.error('FAIL', error instanceof Error ? error.message : JSON.stringify(error, null, 2));
  console.error('errors:', errors.join('\n'));
  process.exit(1);
});
