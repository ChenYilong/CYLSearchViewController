// Opens example/ in WeChat DevTools (logged in; Settings > Security > service port on), visits every page of the
// example (a 1:1 copy of the iOS example: four tabs and the plus button's tab, the Examples menu and what it opens),
// drives the interactions of each, and saves a screenshot of each step:
// node scripts/devtools-screenshots.js <output folder> [path to example]. Needs: npm i miniprogram-automator, and
// node scripts/sync-example.js first. CYL_DEVTOOLS_CLI is the DevTools CLI (the macOS path by default; on Windows
// "C:\\Program Files (x86)\\Tencent\\微信web开发者工具\\cli.bat").
const path = require('path');
const automator = require('miniprogram-automator');

const out = process.argv[2] || '.';
const projectPath = process.argv[3] || path.join(__dirname, '..', 'example');
const cliPath = process.env.CYL_DEVTOOLS_CLI || '/Applications/wechatwebdevtools.app/Contents/MacOS/cli';
const errors = [];

// Calls a method of a component of the current page: selectors from the page down, then the method and its arguments.
function callComponent(mp, selectors, method, args) {
  return mp.evaluate((chain, name, values) => {
    const pages = getCurrentPages();
    let target = pages[pages.length - 1];
    chain.forEach((selector) => { target = target.selectComponent(selector); });
    return target[name](...values);
  }, selectors, method, args || []);
}

(async () => {
  const mp = await automator.launch({ cliPath, projectPath });
  mp.on('console', (message) => {
    if (message.type === 'error') errors.push(JSON.stringify(message.args).slice(0, 300));
  });
  mp.on('exception', (error) => errors.push(`${error.message} ${error.stack || ''}`.slice(0, 500)));
  const shot = (name) => mp.screenshot({ path: path.join(out, `miniprogram-${name}.png`) });
  const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
  try {
    // Wait until the app has opened its first page; a reLaunch sent earlier fails ("Uncaught").
    for (let i = 0; i < 20 && !(await mp.currentPage().catch(() => null)); i += 1) await wait(500);
    await mp.evaluate(() => wx.clearStorageSync());
    // Right after a compile the first reLaunch can fail ("Uncaught"): try again.
    let page = null;
    for (let attempt = 1; !page; attempt += 1) {
      try {
        page = await mp.reLaunch('/pages/search/index');
      } catch (error) {
        if (attempt >= 6) throw error;
        await wait(1500);
      }
    }
    await page.waitFor(2000);
    await shot('01-search-tab');
    await callComponent(mp, ['#reproduction'], 'onShowOverlay');
    await wait(500);
    await callComponent(mp, ['#reproduction', '#overlay'], 'onTextChange', [{ detail: { text: '1' } }]);
    await shot('02-search-overlay');

    page = await mp.switchTab('/pages/examples/index');
    await page.waitFor(1000);
    await shot('03-examples-tab');
    page = await mp.navigateTo('/pages/styles/index');
    await page.waitFor(1000);
    await shot('04-placeholder-styles');
    page = await mp.navigateTo('/pages/ports/index');
    await page.waitFor(1000);
    await shot('05-ports');

    page = await mp.switchTab('/pages/plus/index');
    await page.waitFor(1000);
    await callComponent(mp, ['#demo', '#bar'], 'setText', ['Jay Chou', true]);
    await shot('06-search-bar-tab');

    page = await mp.switchTab('/pages/tagStyle/index');
    await page.waitFor(1000);
    page = await mp.navigateTo('/pages/materialSample/index?sample=standard&style=tags&focus=0');
    await page.waitFor(1000);
    await page.callMethod('openSearch');
    await page.waitFor(1200);
    await shot('07-tag-style-empty-cache');
    await callComponent(mp, ['#search'], 'setQuery', ['a', false]);
    await page.waitFor(800);
    await shot('08-tag-style-folded');

    page = await mp.navigateTo('/pages/materialSample/index?sample=themed&style=list&focus=1');
    await page.waitFor(1000);
    await page.callMethod('openSearch');
    await callComponent(mp, ['#search'], 'setQuery', ['S', false]);
    await page.waitFor(800);
    await shot('09-themed');

    for (const [name, url] of [['10-lapism', '/pages/lapism/index'], ['11-yechaoa', '/pages/yechaoa/index'],
      ['12-reveal', '/pages/reveal/index'], ['13-multi-search', '/pages/multiSearch/index']]) {
      await mp.reLaunch('/pages/examples/index');
      page = await mp.navigateTo(url);
      await page.waitFor(1000);
      if (name === '10-lapism') {
        await page.callMethod('openSearch');
        await callComponent(mp, ['#search'], 'setQuery', ['1', false]);
      } else if (name === '11-yechaoa') {
        await callComponent(mp, ['#toolbarSearch'], 'setIconified', [false]);
        await page.waitFor(600);
        await callComponent(mp, ['#toolbarSearch'], 'setText', ['hello', true]);
      } else if (name === '12-reveal') {
        await callComponent(mp, ['#bar'], 'setIconified', [false]);
        await page.waitFor(1200);
      } else {
        await callComponent(mp, ['#multi'], 'addSearchText', ['Swift']);
        await callComponent(mp, ['#multi'], 'addSearchText', ['Kotlin']);
      }
      await page.waitFor(600);
      await shot(name);
    }

    page = await mp.switchTab('/pages/discover/index');
    await page.waitFor(1500);
    await shot('14-discover-tab');
    await page.callMethod('search', ['Pomodoro technique']);
    await page.callMethod('onToggleFold');
    await page.waitFor(800);
    await shot('15-discover-searched');

    console.log('errors:', errors.length ? errors.join('\n') : 'none');
  } finally {
    await mp.close();
  }
})().catch((error) => {
  console.error('FAIL', error instanceof Error ? error.message : JSON.stringify(error, null, 2));
  console.error('errors:', errors.join('\n'));
  process.exit(1);
});
