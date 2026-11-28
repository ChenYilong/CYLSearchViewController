const test = require('node:test');
const assert = require('node:assert');
const {
  CYLSearchAnimationSpeed,
  cylClampAnimationSpeed,
  cylAnimationPlaybackDescription,
} = require('../src/core/CYLSearchView');

test('a speed is clamped to the slider range and rounded to its step', () => {
  assert.strictEqual(cylClampAnimationSpeed(1), 1);
  assert.strictEqual(cylClampAnimationSpeed(1.6), 1.5);
  assert.strictEqual(cylClampAnimationSpeed(0), CYLSearchAnimationSpeed.minimum);
  assert.strictEqual(cylClampAnimationSpeed(10), CYLSearchAnimationSpeed.maximum);
  assert.strictEqual(cylClampAnimationSpeed('2'), 2);
});

test('a value that is not a number plays at the standard speed', () => {
  assert.strictEqual(cylClampAnimationSpeed(undefined), 1);
  assert.strictEqual(cylClampAnimationSpeed('fast'), 1);
});

test('the accessibility value names the speed and the loop', () => {
  assert.strictEqual(cylAnimationPlaybackDescription(1.5, true), '1.5x, looping');
  assert.strictEqual(cylAnimationPlaybackDescription(0.25, false), '0.25x, plays once');
});
