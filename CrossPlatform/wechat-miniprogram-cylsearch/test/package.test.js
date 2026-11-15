// The package as a library: its entry, its files and its components.
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');

global.wx = global.wx || {
  env: { USER_DATA_PATH: '/tmp' },
  getStorageSync: () => undefined,
  setStorageSync: () => {},
  getAppBaseInfo: () => ({ language: 'en' }),
  getFileSystemManager: () => ({ accessSync() { throw new Error('missing'); }, readFileSync() { return '[]'; }, writeFileSync() {} }),
};

const root = path.join(__dirname, '..');
const pkg = require('../package.json');

test('the entry exports the iOS API and the helpers', () => {
  const api = require(path.join(root, pkg.main));
  for (const name of ['CYLSearchBarView', 'CYLSearchView', 'CYLMultiSearchView', 'CYLSearchController', 'CYLSearchPlaceholderView',
    'CYLSearchSuggestionStore', 'CYLSearchBarItem', 'CYLSearchViewModel', 'CYLSearchBarItems', 'cylFoldTags',
    'cylNavigationMetrics', 'cylClampAnimationSpeed', 'cylFormatString']) {
    assert.ok(api[name], name);
  }
});

test('every component of src is complete and its paths resolve inside the package', () => {
  const src = path.join(root, pkg.miniprogram);
  const components = fs.readdirSync(src).filter((name) => fs.existsSync(path.join(src, name, 'index.json')));
  assert.deepStrictEqual(components.sort(), ['cyl-multi-search', 'cyl-search', 'cyl-search-bar', 'cyl-search-bar-item',
    'cyl-search-controller', 'cyl-search-empty-view', 'cyl-search-placeholder']);
  for (const name of components) {
    for (const extension of ['js', 'json', 'wxml']) assert.ok(fs.existsSync(path.join(src, name, `index.${extension}`)), `${name}.${extension}`);
    const json = JSON.parse(fs.readFileSync(path.join(src, name, 'index.json'), 'utf8'));
    assert.strictEqual(json.component, true, name);
    const used = Object.values(json.usingComponents || {}).concat(Object.values(json.componentGenerics || {}).map((g) => g.default));
    for (const target of used) {
      // A library component refers to its siblings by relative path, never to the app (an absolute path).
      assert.ok(target.startsWith('../'), `${name} uses ${target}`);
      assert.ok(fs.existsSync(path.join(src, name, `${target}.json`)), `${name} -> ${target}`);
    }
  }
});

test('the published files are the sources, the readme and the licenses', () => {
  assert.strictEqual(pkg.miniprogram, 'src');
  // The built miniprogram_npm folder is src/; require('<package>') loads its index.js.
  assert.strictEqual(pkg.main, 'src/index.js');
  for (const file of pkg.files) assert.ok(fs.existsSync(path.join(root, file)), file);
  assert.ok(pkg.files.includes('LICENSE'));
  assert.ok(pkg.repository && pkg.repository.directory === 'CrossPlatform/wechat-miniprogram-cylsearch');
});

test('every relative require names a file, as a mini program needs', () => {
  // A mini program resolves no folder to its index.js (Node does), so require('./core') fails there.
  const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true })
    .flatMap((entry) => (entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]));
  for (const file of walk(path.join(root, 'src')).filter((name) => name.endsWith('.js'))) {
    for (const match of fs.readFileSync(file, 'utf8').matchAll(/require\((['"])(\.[^'"]+)\1\)/g)) {
      const target = path.join(path.dirname(file), match[2]);
      const isFile = fs.existsSync(`${target}.js`) || (fs.existsSync(target) && fs.statSync(target).isFile());
      assert.ok(isFile, `${path.relative(root, file)} requires the folder ${match[2]}`);
    }
  }
});

test('cyl-search-empty-view draws a CYLTableViewPlaceHolder scenario as a CYLSearchPlaceholderView kind', () => {
  const { cylEmptyViewKind } = require('../src/cyl-search-empty-view/cyl_empty_view_kind');
  assert.strictEqual(cylEmptyViewKind('NoSearchResults'), 'noResults');
  assert.strictEqual(cylEmptyViewKind('CYLPlaceholderScenarioNoSearchResults'), 'noResults');
  assert.strictEqual(cylEmptyViewKind('NoContent'), 'empty');
  assert.strictEqual(cylEmptyViewKind('LoadFailed'), 'error');
  assert.strictEqual(cylEmptyViewKind(''), 'empty');
});
