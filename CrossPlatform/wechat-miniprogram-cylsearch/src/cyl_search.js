// The JavaScript API of cyl-search-miniprogram: require('cyl-search-miniprogram') (src/index.js, package.json "main"),
// or this file's path in a copy of src/. It has the core, a counterpart of every public iOS API (CYLSearchBarView,
// CYLSearchView, CYLMultiSearchView, CYLSearchController, CYLSearchPlaceholderView, CYLSearchSuggestionStore…), and the
// helpers the components use: the search page's state (CYLSearchViewModel), the item list of a bar (CYLSearchBarItems),
// the playback strategy of the animated placeholders, the inline tag fold, the navigation bar metrics and the format of
// the core's strings. The components themselves are used from WXML (usingComponents), not from here.
//
// Each require is a plain statement naming a file: WeChat DevTools keeps only the files its static analysis reaches
// ("filter unused files"), and it does not see a require inside an object spread; a mini program also resolves no
// folder to its index.js.
'use strict';
Object.assign(module.exports, require('./core/index'));
module.exports.CYLSearchViewModel = require('./cyl-search/cyl_search_view_model').CYLSearchViewModel;
module.exports.CYLSearchBarItems = require('./cyl-search/cyl_search_bar_item').CYLSearchBarItems;
Object.assign(module.exports, require('./cyl-search/cyl_search_animation_playback'));
Object.assign(module.exports, require('./cyl-search/cyl_tag_fold'));
Object.assign(module.exports, require('./cyl-search/cyl_navigation_metrics'));
Object.assign(module.exports, require('./cyl-search/cyl_format'));
