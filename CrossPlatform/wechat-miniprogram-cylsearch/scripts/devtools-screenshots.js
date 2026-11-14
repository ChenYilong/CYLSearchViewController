// Opens example/ in WeChat DevTools (logged in; Settings > Security > service port on) and saves three screenshots:
// node scripts/devtools-screenshots.js <output folder> [path to example]. Needs: npm i miniprogram-automator.
const path = require('path');
const automator = require('miniprogram-automator');

const out = process.argv[2] || '.';
const projectPath = process.argv[3] || path.join(__dirname, '..', 'example');

(async () => {
  const mp = await automator.launch({
    cliPath: '/Applications/wechatwebdevtools.app/Contents/MacOS/cli',
    projectPath,
  });
  try {
    await mp.callWxMethod('clearStorageSync');
    const page = await mp.reLaunch('/pages/index/index');
    await page.waitFor(1500);
    await mp.screenshot({ path: path.join(out, 'miniprogram-1-home.png') });
    await page.callMethod('openSearch');
    await page.waitFor(1000);
    await mp.screenshot({ path: path.join(out, 'miniprogram-2-empty-cache.png') });
    const search = await page.$('#search');
    const bar = await search.$('cyl-search-bar');
    const input = await bar.$('input');
    await input.input('sw');
    await input.trigger('confirm', { value: 'Swift' });
    await page.waitFor(800);
    await mp.screenshot({ path: path.join(out, 'miniprogram-3-after-submit.png') });
    const data = await search.data();
    console.log(JSON.stringify({
      open: data.open, query: data.query, suggestions: data.suggestions,
      cached: data.showsCachedQueries, emptySuggestions: data.showsEmptySuggestions,
    }));
    console.log('event:', (await page.data()).lastEvent);
  } finally {
    await mp.close();
  }
})().catch((error) => {
  console.error('FAIL', (error && error.message) || error);
  process.exit(1);
});
