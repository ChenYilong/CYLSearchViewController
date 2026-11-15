// The CYLSearchPlaceholderView kind ("empty", "noResults", "error") for a CYLTableViewPlaceHolder scenario name
// ("NoSearchResults" or "CYLPlaceholderScenarioNoSearchResults"); pure, tested with Node.
function cylEmptyViewKind(scenario) {
  const name = String(scenario || '').replace(/^CYLPlaceholderScenario/, '');
  if (name === 'NoSearchResults') return 'noResults';
  if (/^(LoadFailed|NetworkError|ServerError|Retry|Error)/.test(name)) return 'error';
  return 'empty';
}

module.exports = { cylEmptyViewKind };
