// The SVGA tab icons of the example (docs/svga-tab-icons.md): every CYLTabBarSVGAFilePath of the tab configuration is
// a package copy (*.svga.bin) that exists and that cyl-svga's decoder reads as an SVGA 2.x movie with frames and
// sprites. Run after `node scripts/sync-example.js` (which installs cyl-svga-miniprogram).
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const miniprogram = path.join(__dirname, '..', 'example', 'miniprogram');
const decoder = path.join(miniprogram, 'miniprogram_npm', 'cyl-svga-miniprogram', 'svga', 'cyl_svga_movie.js');

// cyl_search_tabs.js requires cyl_demo_text, which reads wx; a stand-in is enough to read the configuration.
global.wx = global.wx || { getSystemInfoSync: () => ({ language: 'en' }), getAppBaseInfo: () => ({ language: 'en' }) };
const { configuration } = require(path.join(miniprogram, 'utils', 'cyl_search_tabs.js'));

const svgaItems = configuration.CYLTabBarControllerTabBarItemsAttributes.filter((item) => item.CYLTabBarSVGAFilePath);

test('three tabs have SVGA icons, each with a size', () => {
  assert.deepEqual(svgaItems.map((item) => item.CYLTabBarItemIdentifier), ['search', 'examples', 'discover']);
  for (const item of svgaItems) {
    assert.equal(item.CYLTabBarSVGASize, '{30, 30}');
    assert.match(item.CYLTabBarSVGAFilePath, /\.svga\.bin$/);
  }
});

test('every SVGA icon is in the package and decodes as an SVGA 2.x movie', { skip: !fs.existsSync(decoder) && 'run scripts/sync-example.js first' }, () => {
  const { cylDecodeSVGA } = require(decoder);
  for (const item of svgaItems) {
    const file = path.join(miniprogram, item.CYLTabBarSVGAFilePath);
    assert.ok(fs.existsSync(file), `${item.CYLTabBarSVGAFilePath} is missing`);
    const bytes = fs.readFileSync(file);
    const movie = cylDecodeSVGA(new Uint8Array(bytes.buffer, bytes.byteOffset, bytes.byteLength));
    assert.ok(movie, `${item.CYLTabBarSVGAFilePath} did not decode`);
    const frames = movie.frames ?? movie.params?.frames;
    const sprites = movie.sprites ?? [];
    assert.ok(frames > 0, `${item.CYLTabBarSVGAFilePath}: no frames`);
    assert.ok(sprites.length > 0, `${item.CYLTabBarSVGAFilePath}: no sprites`);
  }
});

test('the SVGA icons keep their license notice', () => {
  assert.ok(fs.existsSync(path.join(miniprogram, 'assets', 'tab', 'svga', 'NOTICE.md')));
});
