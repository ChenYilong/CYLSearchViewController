// Prepares the example for WeChat DevTools, because a mini program cannot load files outside its miniprogramRoot:
// 1. copies the package's components (src/) into example/miniprogram/components/;
// 2. installs CYLTabBarController's mini program tab bar (cyl-tabbar-miniprogram) and Lottie player
//    (cyl-lottie-miniprogram) into example/miniprogram/miniprogram_npm/, each with its LICENSE, from CYLTabBarController
//    at the commit pinned in package.json (`cylTabBarControllerCommit`), cloned into example/vendor/ with a sparse
//    checkout; CYL_TABBAR_DIR=<checkout> uses a local checkout instead.
// Runs from `npm run sync-example` and from the DevTools beforeCompile / beforePreview / beforeUpload hooks of
// project.config.json. The outputs are git-ignored.
'use strict';
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.join(__dirname, '..');
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

function sync(from, to) {
  fs.rmSync(to, { recursive: true, force: true });
  // AppleDouble files (._name) of a macOS checkout stay out.
  copyDir(from, to, (file) => !path.basename(file).startsWith('._'));
  console.log('synced', path.relative(root, to));
}

function tabBarCheckout() {
  if (process.env.CYL_TABBAR_DIR) return process.env.CYL_TABBAR_DIR;
  const commit = require(path.join(root, 'package.json')).cylTabBarControllerCommit;
  const dir = path.join(root, 'example', 'vendor', 'CYLTabBarController');
  const git = (...args) => execFileSync('git', args, { cwd: dir, stdio: ['ignore', 'pipe', 'inherit'] }).toString().trim();
  if (!fs.existsSync(path.join(dir, '.git'))) {
    fs.mkdirSync(path.dirname(dir), { recursive: true });
    execFileSync('git', ['clone', '--filter=blob:none', '--no-checkout', 'https://github.com/ChenYilong/CYLTabBarController.git', dir], { stdio: 'inherit' });
  }
  // Only the two mini program folders are needed. A sparse checkout also keeps Windows below its path length limit,
  // which the full checkout (deep Xcode folders) exceeds with "Filename too long".
  git('config', 'core.longpaths', 'true');
  git('sparse-checkout', 'set', 'CrossPlatform/wechat-miniprogram-cyltabbar', 'CrossPlatform/lottie-miniprogram');
  let head = '';
  try { head = git('rev-parse', 'HEAD'); } catch (error) { head = ''; }
  if (head !== commit || !fs.existsSync(path.join(dir, 'CrossPlatform', 'lottie-miniprogram'))) {
    git('fetch', '--filter=blob:none', 'origin', commit);
    git('checkout', '--force', commit);
  }
  return dir;
}

sync(path.join(root, 'src'), path.join(miniprogram, 'components'));

const checkout = tabBarCheckout();
const libraries = [
  { name: 'cyl-tabbar-miniprogram', from: 'CrossPlatform/wechat-miniprogram-cyltabbar', dist: 'src' },
  { name: 'cyl-lottie-miniprogram', from: 'CrossPlatform/lottie-miniprogram', dist: 'miniprogram_dist' },
];
for (const library of libraries) {
  const libraryRoot = path.join(checkout, library.from);
  const to = path.join(miniprogram, 'miniprogram_npm', library.name);
  sync(path.join(libraryRoot, library.dist), to);
  const license = [path.join(libraryRoot, 'LICENSE'), path.join(checkout, 'LICENSE')].find((file) => fs.existsSync(file));
  if (license) fs.copyFileSync(license, path.join(to, 'LICENSE'));
}
