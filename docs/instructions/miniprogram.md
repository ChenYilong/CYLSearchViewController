# WeChat mini program (tag: `miniprogram`)

Details of the `miniprogram` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Mini program example: a 1:1 copy of the iOS example (added 2026-11-15)

- The WeChat Mini Program example (`CrossPlatform/wechat-miniprogram-cylsearch/example`) replicates the iOS example
  (`CYLSearchExample`) one to one: the same tabs (`CYLTabBarConfiguration.json`), pages, texts and languages, data,
  images and interactions. Texts, data and images come from the iOS bundles through
  `scripts/import-ios-resources.js`; never retype them. A page added to or changed in the iOS example is added to or
  changed in the mini program example in the same task.
- What the example needs and the core lacks goes into the core components; the example passes data, style parameters
  and taps only. Differences only where the platform forces them (WeChat's menu button, no built-in speech
  recognition), each listed in `docs/miniprogram-api-alignment.md`.

## Mini program example: a 1:1 copy of the iOS example (added 2026-11-15) (instructions.md wording)

- The mini program example replicates `CYLSearchExample` one to one (tabs, pages, texts in en/ja/zh-Hans/zh-Hant,
  data, images, interactions), with the iOS resources imported by `scripts/import-ios-resources.js`. A change to the
  iOS example changes the mini program example in the same task; missing behavior goes into the core components.
  Full rule: `AGENTS.md`, same section; mapping and platform differences: `docs/miniprogram-api-alignment.md`.
