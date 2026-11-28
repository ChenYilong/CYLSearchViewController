// focusesOnAppear (iOS CYLSearchBarView.focusesOnAppear): the pure decision, the component property and its moments, the examples.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const { cylSearchShouldFocusOnAppear, cylSearchIsOnSecondLevelOrDeeperPage } = require('../src/core/CYLSearchBarView');

const root = path.join(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');

test('focuses only when on, on a second-level or deeper page, drawn (not iconified) and editable', () => {
  assert.equal(cylSearchShouldFocusOnAppear(true, true, false, true), true);
  assert.equal(cylSearchShouldFocusOnAppear(true, true, false, undefined), true);
  assert.equal(cylSearchShouldFocusOnAppear(false, true, false, true), false);
  assert.equal(cylSearchShouldFocusOnAppear(undefined, true, false, true), false);
  assert.equal(cylSearchShouldFocusOnAppear(true, false, false, true), false, 'first-level page: never');
  assert.equal(cylSearchShouldFocusOnAppear(true, true, true, true), false);
  assert.equal(cylSearchShouldFocusOnAppear(true, true, false, false), false);
});

test('second level or deeper means more than one page in the stack; the arrow icon no longer counts', () => {
  assert.equal(cylSearchIsOnSecondLevelOrDeeperPage(1), false);
  assert.equal(cylSearchIsOnSecondLevelOrDeeperPage(2), true);
  assert.equal(cylSearchIsOnSecondLevelOrDeeperPage(3), true);
  assert.ok(!read('src', 'cyl-search-bar', 'index.js').includes('cylSearchHasBackButton'));
});

test('cyl-search-bar has focusesOnAppear (false by default), used on attached and on page show, toggling focus', () => {
  const source = read('src', 'cyl-search-bar', 'index.js');
  assert.ok(source.includes('focusesOnAppear: { type: Boolean, value: false }'));
  assert.match(source, /pageLifetimes: \{\s*show\(\) \{\s*this\.focusIfAppearing\(\);/);
  assert.match(source, /this\.syncSearches\(\);\s*this\.focusIfAppearing\(\);/);
  assert.ok(source.includes('getCurrentPages()'));
  assert.match(source, /setData\(\{ inputFocus: false \}\);\s*setTimeout\(\(\) => this\.setData\(\{ inputFocus: true \}\), 30\)/);
});

test('cyl-search passes focusesOnAppear to its inline bar only', () => {
  assert.ok(read('src', 'cyl-search', 'index.js').includes('focusesOnAppear: { type: Boolean, value: false }'));
  const wxml = read('src', 'cyl-search', 'index.wxml');
  assert.equal(wxml.split('focusesOnAppear="{{focusesOnAppear}}"').length - 1, 1);
});

test('the Discover and Search tab examples turn it on', () => {
  assert.match(read('example', 'miniprogram', 'pages', 'discoverSearch', 'index.wxml'), /navigationFieldStyle focusesOnAppear/);
  assert.match(read('example', 'miniprogram', 'demo-components', 'cyl-demo-reproduction', 'index.wxml'), /inline focusesOnAppear/);
  assert.match(read('example', 'miniprogram', 'demo-components', 'cyl-demo-search-bar', 'index.wxml'), /focusesOnAppear/);
});
