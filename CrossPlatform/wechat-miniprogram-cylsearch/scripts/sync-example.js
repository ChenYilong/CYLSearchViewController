// Prepares the example for WeChat DevTools, because a mini program cannot load files outside its miniprogramRoot:
// 1. copies the package's components (src/) into example/miniprogram/components/;
// 2. installs the sub-repositories the example uses, as the iOS example does through CocoaPods, into
//    example/miniprogram/miniprogram_npm/, each with its licenses, from a sparse checkout at the commit pinned in
//    package.json, cloned into example/vendor/:
//    - CYLTabBarController (`cylTabBarControllerCommit`): its tab bar (cyl-tabbar-miniprogram), Lottie player
//      (cyl-lottie-miniprogram) and SVGA player (cyl-svga-miniprogram, the SVGA tab icons); CYL_TABBAR_DIR=<checkout> uses a local checkout instead;
//    - CYLTableViewPlaceHolder (`cylTableViewPlaceHolderCommit`): cyl-placeholder (the scenario placeholders of the
//      search page) and cyl-refresh (CYLRefreshNormalHeader), as cyl-placeholder-miniprogram;
//      CYL_PLACEHOLDER_DIR=<checkout> uses a local checkout instead.
// Runs from `npm run sync-example` and from the DevTools beforeCompile / beforePreview / beforeUpload hooks of
// project.config.json. The outputs are git-ignored.
'use strict';
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.join(__dirname, '..');
const pkg = require(path.join(root, 'package.json'));
const miniprogram = path.join(root, 'example', 'miniprogram');

// fs.cpSync crashes Node 22 on Windows (0xC0000409) for some source folders; a plain recursive copy does not.
function copyDir(from, to, filter = () => true) {
  fs.mkdirSync(to, { recursive: true });
  for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
    const source = path.join(from, entry.name);
    const target = path.join(to, entry.name);
    if (!filter(source)) continue;
    if (entry.isDirectory()) copyDir(source, target, filter);
    else fs.copyFileSync(source, target);
  }
}

function sync(from, to, filter = () => true) {
  fs.rmSync(to, { recursive: true, force: true });
  // AppleDouble files (._name) of a macOS checkout stay out.
  copyDir(from, to, (file) => !path.basename(file).startsWith('._') && filter(file));
  console.log('synced', path.relative(root, to));
}

// A sparse checkout of `folders` of a GitHub repository at `commit`, in example/vendor/<name>. A sparse checkout also
// keeps Windows below its path length limit, which full checkouts (deep Xcode folders) exceed with "Filename too long".
function checkout(name, commit, folders) {
  const dir = path.join(root, 'example', 'vendor', name);
  const git = (...args) => execFileSync('git', args, { cwd: dir, stdio: ['ignore', 'pipe', 'inherit'] }).toString().trim();
  if (!fs.existsSync(path.join(dir, '.git'))) {
    fs.mkdirSync(path.dirname(dir), { recursive: true });
    execFileSync('git', ['clone', '--filter=blob:none', '--no-checkout', `https://github.com/ChenYilong/${name}.git`, dir], { stdio: 'inherit' });
  }
  git('config', 'core.longpaths', 'true');
  git('sparse-checkout', 'set', ...folders);
  let head = '';
  try { head = git('rev-parse', 'HEAD'); } catch (error) { head = ''; }
  if (head !== commit || !folders.every((folder) => fs.existsSync(path.join(dir, folder)))) {
    git('fetch', '--filter=blob:none', 'origin', commit);
    git('checkout', '--force', commit);
  }
  return dir;
}

function copyLicenses(fromDirs, to) {
  for (const from of fromDirs) {
    if (!fs.existsSync(from)) continue;
    for (const name of fs.readdirSync(from)) {
      if (/^(LICENSE|NOTICE)/.test(name) && fs.statSync(path.join(from, name)).isFile()) fs.copyFileSync(path.join(from, name), path.join(to, name));
    }
  }
}

sync(path.join(root, 'src'), path.join(miniprogram, 'components'));

// CYLTabBarController: the tab bar, the Lottie player and the SVGA player (SVGA tab icons, docs/svga-tab-icons.md).
const tabBarRoot = process.env.CYL_TABBAR_DIR || checkout('CYLTabBarController', pkg.cylTabBarControllerCommit,
  ['CrossPlatform/wechat-miniprogram-cyltabbar', 'CrossPlatform/lottie-miniprogram', 'CrossPlatform/svga-miniprogram']);
for (const library of [
  { name: 'cyl-tabbar-miniprogram', from: 'CrossPlatform/wechat-miniprogram-cyltabbar', dist: 'src' },
  { name: 'cyl-lottie-miniprogram', from: 'CrossPlatform/lottie-miniprogram', dist: 'miniprogram_dist' },
  { name: 'cyl-svga-miniprogram', from: 'CrossPlatform/svga-miniprogram', dist: 'miniprogram_dist' },
]) {
  const libraryRoot = path.join(tabBarRoot, library.from);
  const to = path.join(miniprogram, 'miniprogram_npm', library.name);
  sync(path.join(libraryRoot, library.dist), to);
  copyLicenses([tabBarRoot, libraryRoot], to);
}

// CYLTableViewPlaceHolder: the scenario placeholders and the pull-to-refresh header, kept side by side (cyl-refresh
// uses ../cyl-placeholder/no-animation). The locale .json tables stay out: the code loads their generated .js twins.
const placeholderRoot = process.env.CYL_PLACEHOLDER_DIR || checkout('CYLTableViewPlaceHolder', pkg.cylTableViewPlaceHolderCommit,
  ['CrossPlatform/wechat-miniprogram-cylplaceholder']);
const placeholderPackage = path.join(placeholderRoot, 'CrossPlatform', 'wechat-miniprogram-cylplaceholder');
const placeholderTo = path.join(miniprogram, 'miniprogram_npm', 'cyl-placeholder-miniprogram');
fs.rmSync(placeholderTo, { recursive: true, force: true });
for (const component of ['cyl-placeholder', 'cyl-refresh']) {
  sync(path.join(placeholderPackage, 'src', component), path.join(placeholderTo, component),
    (file) => !(file.endsWith('.json') && file.includes(`${path.sep}locales${path.sep}`)));
}
copyLicenses([placeholderPackage], placeholderTo);
