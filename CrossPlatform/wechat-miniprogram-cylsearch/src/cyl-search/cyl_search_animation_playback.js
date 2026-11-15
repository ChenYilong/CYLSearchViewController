// The playback strategy of cyl-search's animated placeholders, without views (tested with Node): one speed and one
// loop switch applied live to the animation that shows, and the accessibility value that describes them.

/** The speeds a slider offers, as multiples of the animation's own speed. */
const CYLSearchAnimationSpeed = Object.freeze({ minimum: 0.25, maximum: 3, step: 0.25, standard: 1 });

/** Clamps a speed to the slider's range and rounds it to its step; anything that is not a number is 1. */
function cylClampAnimationSpeed(speed) {
  const value = Number(speed);
  if (!Number.isFinite(value)) return CYLSearchAnimationSpeed.standard;
  const { minimum, maximum, step } = CYLSearchAnimationSpeed;
  const stepped = Math.round(value / step) * step;
  return Math.min(maximum, Math.max(minimum, stepped));
}

/** What a screen reader says for the strategy, e.g. "1.5x, looping" or "0.25x, plays once". */
function cylAnimationPlaybackDescription(speed, loops) {
  return `${cylClampAnimationSpeed(speed)}x, ${loops ? 'looping' : 'plays once'}`;
}

module.exports = { CYLSearchAnimationSpeed, cylClampAnimationSpeed, cylAnimationPlaybackDescription };
