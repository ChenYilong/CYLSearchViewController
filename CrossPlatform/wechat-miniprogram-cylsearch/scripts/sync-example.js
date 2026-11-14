// Copies src/ into example/miniprogram/components/, because a mini program cannot load files outside its root.
const fs = require('fs');
const path = require('path');
const root = path.join(__dirname, '..');
const target = path.join(root, 'example', 'miniprogram', 'components');
fs.rmSync(target, { recursive: true, force: true });
fs.cpSync(path.join(root, 'src'), target, { recursive: true, filter: (p) => !path.basename(p).startsWith('._') });
console.log('synced', target);
