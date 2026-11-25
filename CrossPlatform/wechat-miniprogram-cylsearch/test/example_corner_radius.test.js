// Corner radius, the owner's final rule (item 8b of docs/animated-icon-component.md): 0 is square, the capsule is ONE
// named constant (1000) passed by name, no other value is special.
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const modelPath = ['example', 'miniprogram', 'miniprogram_npm', 'cyl-tag-list-miniprogram', 'cyl-animated-item', 'cyl_animated_item_model.js'];
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

test('the capsule constant comes from the library (cyl-animated-item, synced at the pin) and is 1000', () => {
  const { cylAnimatedItemCornerRadiusCapsule } = require(path.join(root, ...modelPath));
  assert.strictEqual(cylAnimatedItemCornerRadiusCapsule, 1000);
  assert.strictEqual(fs.existsSync(path.join(exampleRoot, 'utils', 'cyl_corner_radius.js')), false);
});

test('no example source gives a corner radius the literal 1000 or 0.001', () => {
  const radius = /(?:[Cc]orner-?[Rr]adius|border-radius)["']?\s*[:=]\s*["']?\{?\{?\s*(?:1000|999|9999|0\.001)\b/;
  const offenders = sources(exampleRoot).filter((file) => radius.test(fs.readFileSync(file, 'utf8')));
  assert.deepStrictEqual(offenders, []);
});

test('the Discover bar takes its look from navigationFieldStyle, no radius of its own', () => {
  const page = path.join(exampleRoot, 'pages', 'discoverSearch');
  const script = fs.readFileSync(path.join(page, 'index.js'), 'utf8');
  const markup = fs.readFileSync(path.join(page, 'index.wxml'), 'utf8');
  assert.doesNotMatch(script, /capsuleCornerRadius/);
  assert.match(markup, /\bnavigationFieldStyle\b/);
  assert.doesNotMatch(markup, /fieldCornerRadius=/);
});

test('no 0.001 radius is left in the sources: the search bar item square is 0', () => {
  const hits = [];
  for (const file of [...sources(path.join(root, 'src')), ...sources(exampleRoot)]) {
    fs.readFileSync(file, 'utf8').split(/\r?\n/).forEach((line, index) => {
      if (/\b0\.001\b/.test(line) && /[Rr]adius/.test(line)) hits.push(`${path.relative(root, file)}:${index + 1}`);
    });
  }
  assert.deepStrictEqual(hits, []);
  const bar = fs.readFileSync(path.join(root, 'src', 'core', 'CYLSearchBarView.js'), 'utf8');
  assert.match(bar, /cornerRadius: hasBackground \? 10 : 0,/);
});
