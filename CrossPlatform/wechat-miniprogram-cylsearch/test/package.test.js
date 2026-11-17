// The package as a library: its entry, its files, its two components and its two sub-dependencies.
const test = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const pkg = require('../package.json');
const src = path.join(root, pkg.miniprogram);
// The sub-dependencies, neither a search library: CYLTableViewPlaceHolder's mini program package (placeholders and
// pull-to-refresh) and CollectionViewClassifyMenu's (cyl-tag-button, which draws the search bar items).
const SUB_DEPENDENCIES = ['cyl-placeholder-miniprogram', 'cyl-tag-list-miniprogram'];
const subDependencyOf = (target) => SUB_DEPENDENCIES.find((name) => target.startsWith(`${name}/`));
const synced = path.join(root, 'example', 'miniprogram', 'miniprogram_npm');

const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true })
  .flatMap((entry) => (entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]));

test('the entry exports the three core modules with the iOS names', () => {
  const api = require(path.join(root, pkg.main));
  for (const name of ['CYLSearchBarView', 'CYLSearchBarItem', 'CYLSearchBarMode', 'CYLSearchBarViewDelegate', 'CYLSearchView',
    'CYLSearchViewDelegate', 'CYLSearchViewDataSource', 'CYLSearchSuggestionStyle', 'CYLSearchResources',
    'CYLSearchSuggestionCache', 'CYLSearchSuggestionCachePolicy', 'cylFoldTags', 'cylNavigationMetrics',
    'cylClampAnimationSpeed', 'cylFormatString']) {
    assert.ok(api[name], name);
  }
  for (const removed of ['CYLMultiSearchView', 'CYLSearchController', 'CYLSearchResultsViewController', 'CYLSearchPlaceholderView',
    'CYLSearchSuggestionStore', 'CYLSearchViewModel', 'CYLSearchBarItems']) {
    assert.strictEqual(api[removed], undefined, removed);
  }
});

test('src has two components and three core modules', () => {
  const components = fs.readdirSync(src).filter((name) => fs.existsSync(path.join(src, name, 'index.json')));
  assert.deepStrictEqual(components.sort(), ['cyl-search', 'cyl-search-bar']);
  assert.deepStrictEqual(fs.readdirSync(path.join(src, 'core')).sort(), ['CYLSearchBarView.js', 'CYLSearchResources.js', 'CYLSearchView.js']);
  for (const name of components) {
    for (const extension of ['js', 'json', 'wxml', 'wxss']) assert.ok(fs.existsSync(path.join(src, name, `index.${extension}`)), `${name}.${extension}`);
    const json = JSON.parse(fs.readFileSync(path.join(src, name, 'index.json'), 'utf8'));
    assert.strictEqual(json.component, true, name);
    const used = Object.values(json.usingComponents || {}).concat(Object.values(json.componentGenerics || {}).map((g) => g.default));
    for (const target of used) {
      const dependency = subDependencyOf(target);
      if (dependency) {
        // Resolved from miniprogram_npm; checked when the example has been synced (scripts/sync-example.js).
        if (fs.existsSync(path.join(synced, dependency))) assert.ok(fs.existsSync(path.join(synced, `${target}.json`)), `${name} -> ${target}`);
        continue;
      }
      // A library component refers to its siblings by relative path, never to the app (an absolute path).
      assert.ok(target.startsWith('../'), `${name} uses ${target}`);
      assert.ok(fs.existsSync(path.join(src, name, `${target}.json`)), `${name} -> ${target}`);
    }
  }
});

test('the search package depends on no other search library: CYLTableViewPlaceHolder and CollectionViewClassifyMenu, pinned by commit', () => {
  const dependencies = Object.assign({}, pkg.dependencies, pkg.peerDependencies);
  assert.deepStrictEqual(Object.keys(dependencies), SUB_DEPENDENCIES);
  assert.match(pkg.cylTableViewPlaceHolderCommit, /^[0-9a-f]{40}$/);
  assert.match(pkg.collectionViewClassifyMenuCommit, /^[0-9a-f]{40}$/);
  for (const file of walk(src).filter((name) => /\.(js|json)$/.test(name))) {
    const text = fs.readFileSync(file, 'utf8');
    const code = file.endsWith('.js') ? text.replace(/\/\/.*$|\/\*[\s\S]*?\*\//gm, '') : text;
    for (const match of code.matchAll(/require\((['"])([^'"]+)\1\)/g)) {
      assert.ok(match[2].startsWith('.'), `${path.relative(root, file)} requires ${match[2]}`);
    }
    if (file.endsWith('.json')) {
      const json = JSON.parse(text);
      const used = Object.values(json.usingComponents || {}).concat(Object.values(json.componentGenerics || {}).map((g) => g.default));
      for (const target of used) assert.ok(target.startsWith('../') || subDependencyOf(target), `${path.relative(root, file)} uses ${target}`);
    }
  }
});

test('the published files are the sources, the readme and the license', () => {
  assert.strictEqual(pkg.miniprogram, 'src');
  // The built miniprogram_npm folder is src/; require('<package>') loads its index.js.
  assert.strictEqual(pkg.main, 'src/index.js');
  for (const file of pkg.files) assert.ok(fs.existsSync(path.join(root, file)), file);
  assert.ok(pkg.files.includes('LICENSE'));
  assert.ok(pkg.repository && pkg.repository.directory === 'CrossPlatform/wechat-miniprogram-cylsearch');
});

test('every relative require names a file, as a mini program needs', () => {
  // A mini program resolves no folder to its index.js (Node does), so require('./core') fails there.
  for (const file of walk(src).filter((name) => name.endsWith('.js'))) {
    for (const match of fs.readFileSync(file, 'utf8').matchAll(/require\((['"])(\.[^'"]+)\1\)/g)) {
      const target = path.join(path.dirname(file), match[2]);
      const isFile = fs.existsSync(`${target}.js`) || (fs.existsSync(target) && fs.statSync(target).isFile());
      assert.ok(isFile, `${path.relative(root, file)} requires the folder ${match[2]}`);
    }
  }
});

test('no file of the package or the example names a removed component', () => {
  const removed = /cyl-search-placeholder|cyl-search-empty-view|cyl-multi-search|cyl-search-controller|cyl-search-bar-item/;
  const files = walk(src).concat(walk(path.join(root, 'example', 'miniprogram')).filter((file) => !file.includes(`${path.sep}miniprogram_npm${path.sep}`)
    && !file.includes(`${path.sep}components${path.sep}`)))
    .filter((file) => /\.(json|wxml|js)$/.test(file));
  for (const file of files) {
    const text = fs.readFileSync(file, 'utf8');
    // Comments may say what a component was merged from ("was cyl-multi-search"); markup and JSON may not use it.
    const code = file.endsWith('.js') ? text.replace(/\/\/.*$|\/\*[\s\S]*?\*\//gm, '') : text.replace(/<!--[\s\S]*?-->/g, '');
    assert.ok(!removed.test(code), path.relative(root, file));
  }
});
