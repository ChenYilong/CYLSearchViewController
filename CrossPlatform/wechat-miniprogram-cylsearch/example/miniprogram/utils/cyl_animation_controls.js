// The playback controls of an example page that shows a placeholder animation (AGENTS.md, "Animation examples:
// playback controls"): "Play all" restarts the animation from progress 0, a speed slider and a loop switch apply one
// strategy live through cyl-search's animationSpeed / animationLoops. The slider counts quarter steps (1 to 12), so its
// values stay integers.
const { cylClampAnimationSpeed, cylAnimationPlaybackDescription } = require('../components/cyl-search/cyl_search_animation_playback');

const QUARTERS = 4;

function playbackData(speed, loops) {
  const clamped = cylClampAnimationSpeed(speed);
  return {
    animationSpeed: clamped,
    animationSpeedStep: clamped * QUARTERS,
    animationLoops: loops,
    animationPlaybackDescription: cylAnimationPlaybackDescription(clamped, loops),
  };
}

/** The data and handlers to spread into a Page: data.playback* and onPlayAll / onSpeedChange / onLoopChange. */
function cylAnimationControls(searchSelector) {
  return {
    initialData: playbackData(1, true),
    onPlayAll() {
      const search = this.selectComponent(searchSelector);
      if (search) search.playAnimationFromStart();
    },
    onSpeedChange(event) {
      this.setData(playbackData(event.detail.value / QUARTERS, this.data.animationLoops));
    },
    onLoopChange(event) {
      this.setData(playbackData(this.data.animationSpeed, event.detail.value));
      // A switched-on loop after the animation ended starts it again.
      if (event.detail.value) this.onPlayAll();
    },
  };
}

module.exports = { cylAnimationControls };
