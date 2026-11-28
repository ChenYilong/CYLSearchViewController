> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# WeChat mini program core: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

11/11 chunks read (wechat-miniprogram-cylsearch src + package.json/project.config.json). Pure JS models in src/core (ported from HarmonyOS, keeps $r shim) drawn by components cyl-search-bar, cyl-search, cyl-search-navigation-bar, cyl-search-refresh-button; STRINGS table in CYLSearchResources.js generated. Pins tabbar 08343e9f, placeholder f4cf978, classifymenu c0b183de. Findings (code read, not run): searchButtonTapped submits/tells delegate then ALSO runs searchButtonHandler (like HarmonyOS; iOS/Android handler replaces default); bar submit() rejects only length 0 (blank accepted) while search page ignores blank; model-only: $r(app.color.cyl_search_navigation_field_fill) falls back to #8e8e93 in applyNavigationFieldStyle()/applyPreset (component uses CSS, not affected); next=05-flutter-plugin

## Files read (27)

- `CrossPlatform/wechat-miniprogram-cylsearch/package.json` (37)
- `CrossPlatform/wechat-miniprogram-cylsearch/project.config.json` (23)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBar.js` (213)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchBarView.js` (1507)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchController.js` (355)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchNavigationBar.js` (170)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchResources.js` (492)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTableViewController.js` (127)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchTagListStyle.js` (164)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/core/CYLSearchView.js` (932)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.js` (706)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.json` (20)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.wxml` (114)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-bar/index.wxss` (89)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.js` (103)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.json` (3)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.wxml` (12)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-navigation-bar/index.wxss` (8)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.js` (26)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.json` (3)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.wxml` (4)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search-refresh-button/index.wxss` (2)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.js` (752)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.json` (25)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.wxml` (133)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/cyl-search/index.wxss` (51)
- `CrossPlatform/wechat-miniprogram-cylsearch/src/index.js` (26)

Declarations with line numbers: [../reference/04-mp-src.md](../reference/04-mp-src.md)
