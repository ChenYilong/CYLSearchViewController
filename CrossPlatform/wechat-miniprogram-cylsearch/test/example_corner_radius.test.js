// Corner radius, the owner's final rule (item 8b of docs/animated-icon-component.md): 0 is square, the capsule is ONE
// named constant (1000) passed by name, no other value is special.
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const { CYL_CORNER_RADIUS_CAPSULE } = require('../example/miniprogram/utils/cyl_corner_radius');

const root = path.join(__dirname, '..');
const exampleRoot = path.join(root, 'example', 'miniprogram');
// The example's own sources: the vendored and synced folders (miniprogram_npm, components, vendor) are not edited here.
const skipped = new Set(['miniprogram_npm', 'components', 'node_modules']);

function sources(directory, found = []) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      if (!skipped.has(entry.name)) sources(path.join(directory, entry.name), found);
    } else if (/\.(js|wxml|wxss)$/.test(entry.name) && !/cyl_demo_resources\.js$/.test(entry.name)) {
      found.push(path.join(directory, entry.name));
    }
  }
  return found;
}

test('the capsule constant is 1000', () => {
  assert.strictEqual(CYL_CORNER_RADIUS_CAPSULE, 1000);
});

test('no example source gives a corner radius the literal 1000 or 0.001', () => {
  const radius = /(?:[Cc]orner-?[Rr]adius|border-radius)["']?\s*[:=]\s*["']?\{?\{?\s*(?:1000|999|9999|0\.001)\b/;
  const offenders = sources(exampleRoot).filter((file) => radius.test(fs.readFileSync(file, 'utf8')));
  assert.deepStrictEqual(offenders, []);
});

test('the Discover bar passes the capsule constant by name', () => {
  const page = path.join(exampleRoot, 'pages', 'discoverSearch');
  const script = fs.readFileSync(path.join(page, 'index.js'), 'utf8');
  const markup = fs.readFileSync(path.join(page, 'index.wxml'), 'utf8');
  assert.match(script, /capsuleCornerRadius: CYL_CORNER_RADIUS_CAPSULE/);
  assert.match(markup, /fieldCornerRadius="\{\{capsuleCornerRadius\}\}"/);
  assert.doesNotMatch(markup, /fieldCornerRadius="\{\{fieldHeight \/ 2\}\}"/);
});

test('the one 0.001 left in the sources is the search bar item square, pending the ClassifyMenu pin', () => {
  // The pinned cyl-tag-button draws 0 as a capsule and 0.001 as square: the item keeps 0.001 until the pins move.
  const hits = [];
  for (const file of sources(path.join(root, 'src'))) {
    fs.readFileSync(file, 'utf8').split(/\r?\n/).forEach((line, index) => {
      if (/\b0\.001\b/.test(line) && /[Rr]adius/.test(line)) hits.push(`${path.relative(root, file)}:${index + 1}`);
    });
  }
  assert.strictEqual(hits.length, 1);
  assert.match(hits[0].split(path.sep).join('/'), /^src\/core\/CYLSearchBarView\.js:/);
});
