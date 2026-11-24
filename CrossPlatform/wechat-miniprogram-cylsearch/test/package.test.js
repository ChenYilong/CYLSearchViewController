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
    'cylClampAnimationSpeed', 'cylFormatString', 'CYLSearchBar', 'CYLSearchBarAppearance', 'CYLSearchController',
    'CYLSearchControllerDelegate', 'CYLSearchNavigationBar', 'CYLSearchTableViewController', 'CYLSearchTagListStyle',
    'CYLSearchTagListHeader']) {
    assert.ok(api[name], name);
  }
  for (const removed of ['CYLMultiSearchView', 'CYLSearchResultsViewController', 'CYLSearchPlaceholderView',
    'CYLSearchSuggestionStore', 'CYLSearchViewModel', 'CYLSearchBarItems']) {
    assert.strictEqual(api[removed], undefined, removed);
  }
});

test('src has four components (search bar, search, refresh button, navigation bar) and the core modules', () => {
  const components = fs.readdirSync(src).filter((name) => fs.existsSync(path.join(src, name, 'index.json')));
  assert.deepStrictEqual(components.sort(), ['cyl-search', 'cyl-search-bar', 'cyl-search-navigation-bar', 'cyl-search-refresh-button']);
  assert.deepStrictEqual(fs.readdirSync(path.join(src, 'core')).sort(), ['CYLSearchBar.js', 'CYLSearchBarView.js', 'CYLSearchController.js', 'CYLSearchNavigationBar.js',
    'CYLSearchResources.js', 'CYLSearchTableViewController.js', 'CYLSearchTagListStyle.js', 'CYLSearchView.js']);
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

// The bar items' animated icons are CYLTabBarController's cyl-animated-item, inside CollectionViewClassifyMenu's
// cyl-tag-button: the package links no animation engine; it declares the four engine slots and forwards them.
const ENGINE_SLOTS = ['cyl-lottie-view', 'cyl-pag-view', 'cyl-rive-view', 'cyl-svga-view'];

test('cyl-search-bar and cyl-search declare the four engine slots and forward them, with no engine of their own', () => {
  const forwards = { 'cyl-search-bar': 'cyl-tag-button', 'cyl-search': 'cyl-search-bar' };
  for (const [name, child] of Object.entries(forwards)) {
    const json = JSON.parse(fs.readFileSync(path.join(src, name, 'index.json'), 'utf8'));
    for (const slot of ENGINE_SLOTS) {
      assert.strictEqual(json.componentGenerics[slot].default, 'cyl-tag-list-miniprogram/cyl-animation-placeholder/index', `${name} ${slot}`);
    }
    const wxml = fs.readFileSync(path.join(src, name, 'index.wxml'), 'utf8').replace(/<!--[\s\S]*?-->/g, '');
    const tags = wxml.match(new RegExp(`<${child}\\s[^>]*>`, 'g')) || [];
    assert.ok(tags.length > 0, `${name} draws ${child}`);
    for (const tag of tags) {
      for (const slot of ENGINE_SLOTS) assert.ok(tag.includes(`generic:${slot}="${slot}"`), `${name} forwards ${slot} to ${child}`);
    }
    const used = Object.values(json.usingComponents || {}).join(' ');
    assert.ok(!/lottie|pag|rive|svga/i.test(used), `${name} uses no engine: ${used}`);
  }
});

test('the synced CollectionViewClassifyMenu package has cyl-animated-item at the pinned CYLTabBarController commit', { skip: !fs.existsSync(path.join(synced, 'cyl-tag-list-miniprogram')) && 'run scripts/sync-example.js first' }, () => {
  const tagList = path.join(synced, 'cyl-tag-list-miniprogram');
  assert.ok(fs.existsSync(path.join(tagList, 'cyl-animated-item', 'index.json')));
  assert.ok(fs.existsSync(path.join(tagList, 'cyl-animated-item', 'LICENSE')));
  assert.strictEqual(fs.readFileSync(path.join(tagList, 'cyl-animated-item', 'COMMIT'), 'utf8').trim(), pkg.cylTabBarControllerCommit);
  const button = JSON.parse(fs.readFileSync(path.join(tagList, 'cyl-tag-button', 'cyl-tag-button.json'), 'utf8'));
  assert.deepStrictEqual(Object.keys(button.componentGenerics).sort(), ENGINE_SLOTS);
});

test('every search bar of the example passes its engines: cyl-lottie and cyl-svga, placeholders for PAG and Rive', () => {
  const example = path.join(root, 'example', 'miniprogram');
  const files = walk(example).filter((file) => file.endsWith('.wxml') && !file.includes(`${path.sep}miniprogram_npm${path.sep}`)
    && !file.includes(`${path.sep}components${path.sep}`));
  let count = 0;
  for (const file of files) {
    for (const tag of fs.readFileSync(file, 'utf8').match(/<cyl-search(-bar)?\s[^>]*>/g) || []) {
      count += 1;
      assert.ok(tag.includes('generic:cyl-lottie-view="cyl-lottie"') && tag.includes('generic:cyl-svga-view="cyl-svga"'),
        `${path.relative(root, file)}: ${tag.slice(0, 60)}`);
    }
  }
  assert.ok(count >= 10, `${count} search bars`);
});
