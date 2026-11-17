// The package entry of cyl-search-miniprogram: require('cyl-search-miniprogram') resolves to the index.js of the built
// miniprogram_npm folder (the "miniprogram" folder, src/), and Node loads it through package.json "main". It exports
// the three core modules, which keep the iOS names (CYLSearchBarView.swift, CYLSearchView.swift,
// CYLSearchResources.swift). The two components, <cyl-search-bar> and <cyl-search>, are used from WXML
// (usingComponents), not from here.
//
// Each require is a plain statement naming a file: WeChat DevTools keeps only the files its static analysis reaches
// ("filter unused files"), and a mini program resolves no folder to its index.js.
'use strict';

const resources = require('./core/CYLSearchResources');

// The platform names of the HarmonyOS port ($r, animateTo, InputType…) and the default cache store stay internal.
module.exports.CYLSearchResources = resources.CYLSearchResources;
module.exports.CYLSearchSuggestionCachePolicy = resources.CYLSearchSuggestionCachePolicy;
module.exports.CYLSearchSuggestionCache = resources.CYLSearchSuggestionCache;
module.exports.cylFormatString = resources.cylFormatString;
module.exports.cylNavigationMetrics = resources.cylNavigationMetrics;
module.exports.cylNavigationMetricsFrom = resources.cylNavigationMetricsFrom;
Object.assign(module.exports, require('./core/CYLSearchBarView'));
Object.assign(module.exports, require('./core/CYLSearchView'));
