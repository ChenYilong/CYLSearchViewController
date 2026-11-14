// Prepares example/ for WeChat DevTools, because a mini program cannot load files outside its root:
// 1. copies src/ into example/miniprogram/components/;
// 2. installs CYLTabBarController's mini program package (cyl-tabbar-miniprogram, the tab bar) into
//    example/miniprogram/miniprogram_npm/, from CYLTabBarController at the commit pinned in package.json
//    (`cylTabBarControllerCommit`), with its Lottie player (cyl-lottie-miniprogram), cloned into example/vendor/; CYL_TABBAR_DIR=<checkout> uses a local checkout.
// Both outputs are git-ignored. Run: node scripts/sync-example.js
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.join(__dirname, '..');
const miniprogram = path.join(root, 'example', 'miniprogram');
const notAppleDouble = (p) => !path.basename(p).startsWith('._');

function copy(from, to) {
  fs.rmSync(to, { recursive: true, force: true });
  fs.cpSync(from, to, { recursive: true, filter: notAppleDouble });
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

copy(path.join(root, 'src'), path.join(miniprogram, 'components'));
const tabBar = path.join(tabBarCheckout(), 'CrossPlatform', 'wechat-miniprogram-cyltabbar', 'src');
copy(tabBar, path.join(miniprogram, 'miniprogram_npm', 'cyl-tabbar-miniprogram'));
// The Lottie player of the same commit, for the animated empty placeholders (cyl-search's cyl-animation-view node).
const lottie = path.join(path.dirname(path.dirname(tabBar)), 'lottie-miniprogram', 'miniprogram_dist');
copy(lottie, path.join(miniprogram, 'miniprogram_npm', 'cyl-lottie-miniprogram'));
