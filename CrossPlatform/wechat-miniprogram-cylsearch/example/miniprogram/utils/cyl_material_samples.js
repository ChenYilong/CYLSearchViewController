// MiguelCatalan/MaterialSearchView's samples (iOS CYLMaterialSearchSample): DefaultActivity, ColoredActivity,
// VoiceActivity, StickyActivity, TabActivity, InputTypeActivity, and the parameters each passes to CYLSearchView.
const { cylDemoText } = require('./cyl_demo_text');

const SAMPLES = ['standard', 'themed', 'voice', 'sticky', 'tabs', 'inputType'];
const TITLE_KEYS = {
  standard: 'demo.port.default', themed: 'demo.port.themed', voice: 'demo.port.voice',
  sticky: 'demo.port.sticky', tabs: 'demo.port.tab', inputType: 'demo.port.inputType',
};

/** R.array.query_suggestions of the sample. */
const SUGGESTIONS = [
  'A very very long suggestion that would span multiple lines.', 'Android', 'iOS', 'SCALA', 'Ruby',
  'JavaScript', 'C#', 'Python', 'C', 'C++', 'PHP', 'Go', 'Perl', 'Bash', 'Lua', 'R', 'TCL', 'Haskell',
  'Objective C', 'Swift', 'Kotlin', 'jQuery', 'Development', 'Web', 'Ajax', 'Test', 'Testing', 'CookBook',
  'Beagle', 'VMware', 'Less.js', 'IDE', 'Arduino', 'Xamarin', 'UI', 'Microsoft', 'Application', 'Development',
  'JUnit', 'SQL', 'Beagle',
];

/** The colored theme of ColoredActivity and VoiceActivity: white text on the primary color (systemIndigo). */
const THEME = {
  backgroundColor: '#5856d6', textColor: '#ffffff', placeholderColor: 'rgba(255, 255, 255, 0.7)',
  navigationColor: '#ffffff', suggestionTextColor: '#ffffff', suggestionImageTintColor: 'rgba(255, 255, 255, 0.8)',
  dividerColor: 'rgba(255, 255, 255, 0.3)',
};
const NO_THEME = {
  backgroundColor: '', textColor: '', placeholderColor: '', navigationColor: '', suggestionTextColor: '',
  suggestionImageTintColor: '', dividerColor: '',
};

function cylMaterialSampleTitle(sample) {
  return cylDemoText(TITLE_KEYS[sample] || TITLE_KEYS.standard);
}

/** What the sample passes to the search view (setVoiceSearch, setCursorDrawable, setEllipsize, setSuggestions…). */
function cylMaterialSampleConfiguration(sample) {
  const themed = sample === 'themed' || sample === 'voice';
  return Object.assign({
    showsVoiceButton: sample === 'voice',
    cursorColor: themed ? '#ffffff' : '#ff2d55',
    suggestionLineBreak: sample === 'standard' || sample === 'inputType' ? 'truncate' : 'wrap',
    suggestions: sample === 'sticky' ? [] : SUGGESTIONS,
    secure: sample === 'inputType',
  }, themed ? THEME : NO_THEME);
}

module.exports = { SAMPLES, SUGGESTIONS, cylMaterialSampleTitle, cylMaterialSampleConfiguration };
