> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Produced by script comparison or setting extraction; run-time effects are unverified.

# Localization coverage

Generated 2026-11-29 by comparing each non-English file with its English base (en, ja, zh-Hans, zh-Hant): keys missing, extra keys, and "still English" = a value with at least two Latin words that is identical to English (comment keys ignored). The check misses one-word untranslated values and says nothing about translation quality. The table below covers these four languages; the other HarmonyOS folders have their own section.

| String set | English keys | ja missing / still English | zh-Hans | zh-Hant |
|:---|---:|:---|:---|:---|
| `CYLSearchExample/CYLContactTags.bundle/*/CYLContactTags.strings` | 38 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CYLSearchExample/CYLContactTags.bundle/*/contact-tags.json` | 204 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CYLSearchExample/CYLOriginalDemo.bundle/*/CYLOriginalDemo.strings` | 8 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CYLSearchExample/CYLSearchDiscover.bundle/*/CYLSearchDiscover.strings` | 21 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CYLSearchExample/CYLSearchDiscover.bundle/*/search-discover.json` | 41 | 0 / 34 | 0 / 0 | 0 / 0 |
| `CYLSearchExample/CYLSearchTabs.bundle/*/CYLSearchTabs.strings` | 15 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CrossPlatform/flutter_cylsearch/example/assets/discover/*/CYLSearchDiscover.strings` | 24 | 0 / 0 | 0 / 0 | 0 / 0 |
| `CrossPlatform/flutter_cylsearch/example/assets/discover/*/search-discover.json` | 41 | 0 / 34 | 0 / 0 | 0 / 0 |
| `Resources/CYLSearchViewController.bundle/*/CYLSearchViewController.strings` | 86 | 0 / 0 | 0 / 0 | 0 / 0 |
| `android/merged/app/src/main/assets/CYLContactTags.bundle/*/CYLContactTags.strings` | 38 | 0 / 0 | 0 / 0 | 0 / 0 |
| `android/merged/app/src/main/assets/CYLContactTags.bundle/*/contact-tags.json` | 204 | 0 / 0 | 0 / 0 | 0 / 0 |
| `android/merged/app/src/main/assets/CYLSearchDiscover.bundle/*/search-discover.json` | 41 | 0 / 34 | 0 / 0 | 0 / 0 |
| `android/merged/app/src/main/assets/CYLSearchTabs.bundle/*/CYLSearchTabs.strings` | 6 | 0 / 0 | 0 / 0 | 0 / 0 |
| `android/merged/app/src/main/res/values*/strings.xml` | 31 | 0 / 0 | 0 / 0 | 0 / 0 |
| `android/merged/cylsearch/src/main/res/values*/cyl_search_strings.xml` | 81 | 0 / 0 | 0 / 0 | 0 / 0 |
| `harmonyos/cylsearch/src/main/resources/*/element/string.json` | 90 | 0 / 0 | 0 / 0 | 0 / 0 |
| `harmonyos/entry/src/main/resources/*/element/string.json` | 79 | 0 / 2 | 0 / 0 | 0 / 2 |
| `harmonyos/entry/src/main/resources/rawfile/contacttags/*.json` | 204 | 0 / 0 | 0 / 0 | 0 / 0 |
| `harmonyos/entry/src/main/resources/rawfile/discover/*.json` | 41 | 0 / 34 | 0 / 0 | 0 / 0 |

## The other HarmonyOS languages (key counts)
| Module | English keys | Full sets | Partial sets | Keys present in the partial sets |
|:---|---:|:---|:---|:---|
| `harmonyos/cylsearch` | 90 | ja_JP 90, zh_CN 90, zh_TW 90 | 29 folders with 7: ar, ca, cs, da, de, el, es, fi, fr, he, hi, hr, hu, id, it, ko, ms, nb, nl, pl, pt_BR, ro, ru, sk, sv, th, tr, uk, vi | `cyl_action_ok, cyl_demo_port_default, cyl_placeholder_empty, cyl_search_cancel, cyl_search_foldMore, cyl_styles_cancel, cyl_tagList_refresh` |
| `harmonyos/entry` | 79 | ja_JP 79, zh_CN 79, zh_TW 79 | 29 folders with 4: ar, ca, cs, da, de, el, es, fi, fr, he, hi, hr, hu, id, it, ko, ms, nb, nl, pl, pt_BR, ro, ru, sk, sv, th, tr, uk, vi | `contactTags_cancel, contactTags_ok, discover_ok, svga_swiftui_close` |

By design, per `docs/instructions/accessibility-i18n.md`: these languages are copied from CYLTabBarController's string table, filtered to texts this project uses (`harmonyos/scripts/import-cyltabbar-localizations.mjs`). The result is that 83 of 90 core strings have no translation there. **Expected, not run:** HarmonyOS falls back to the `base` (English) string.

## Results
- No compared set is missing a key or has an extra one.
- The Japanese `search-discover` data is still English (34 values) in the iOS, Flutter example, Android and HarmonyOS copies. The React Native copy is a single combined file and was not part of this comparison.
- `harmonyos/entry/src/main/resources/{ja_JP,zh_TW}/element/string.json`: `module_desc` and `EntryAbility_desc` are still "CYLSearch example"; zh_CN is translated.

## Not compared (English only or no English base)
- `CrossPlatform/react-native-cylsearch/example/android/app/src/main/res/values*/strings.xml`
- `android/MiguelCatalan-MaterialSearchView/library/src/main/res/values*/strings.xml`
- `android/MiguelCatalan-MaterialSearchView/sample/src/main/res/values*/strings.xml`
- `android/iammert-MultiSearchView/app/src/main/res/values*/strings.xml`
- `android/iammert-MultiSearchView/multisearchviewlib/src/main/res/values*/strings.xml`
- `android/lapism-search/src/main/res/values*/strings.xml`
- `android/yechaoa-MaterialDesign/app/src/main/res/values*/strings.xml`
- `harmonyos/AppScope/resources/*/element/string.json`
- `harmonyos/entry/src/ohosTest/resources/*/element/string.json`
