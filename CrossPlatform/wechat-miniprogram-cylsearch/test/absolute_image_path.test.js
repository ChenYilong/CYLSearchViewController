// WeChat DevTools check 2026-11-26: the default search button drew no magnifier, because the package's relative image path
// (`../images/search.svg`) was handed to the item's cyl-tag-button, which lives in another folder. The bar hands it an
// absolute path built from its own component path.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const { cylAbsoluteImagePath } = require('../src/core/CYLSearchResources');

test('a relative package image becomes an absolute path from the component path', () => {
  assert.equal(cylAbsoluteImagePath('components/cyl-search-bar/index', '../images/search.svg'), '/components/images/search.svg');
  assert.equal(cylAbsoluteImagePath('miniprogram_npm/cyl-search-miniprogram/cyl-search-bar/index', '../images/search.svg'),
    '/miniprogram_npm/cyl-search-miniprogram/images/search.svg');
  assert.equal(cylAbsoluteImagePath('components/cyl-search-bar/index', './a.svg'), '/components/cyl-search-bar/a.svg');
});

test('absolute paths, URLs, empty values and an unknown component path stay as they are', () => {
  assert.equal(cylAbsoluteImagePath('components/cyl-search-bar/index', '/assets/camera.svg'), '/assets/camera.svg');
  assert.equal(cylAbsoluteImagePath('components/cyl-search-bar/index', 'https://x/y.svg'), 'https://x/y.svg');
  assert.equal(cylAbsoluteImagePath('components/cyl-search-bar/index', ''), '');
  assert.equal(cylAbsoluteImagePath(undefined, '../images/search.svg'), '../images/search.svg');
});

test('the bar gives its items and its search button absolute images', () => {
  const source = fs.readFileSync(path.join(__dirname, '..', 'src', 'cyl-search-bar', 'index.js'), 'utf8');
  assert.equal((source.match(/this\.absoluteImages\(/g) || []).length, 2);
});
