# Example demos: grouped lists as tag lists (tag: `example-demos`)

Details of the `example-demos` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md).

## Grouped demo lists use CollectionViewClassifyMenu's tag list (added 2026-11-25)

- Original prompt (verbatim, history only; its more / less fold wording is SUPERSEDED by the 2026-11-25 owner directive below): "deme example演示，如果遇到需要使用类似 tableview 包含section分组功能的样式，优先使用以下样式替换。为example引入并使用CollectionViewClassifyMenu 的taglist 展示提取主标题与icon，使用具有section样式。可以显示more less 折叠展开按钮，点击tag后维持与点击cell相同效果。长按cell显示副标题，小的悬浮框带有箭头。小的悬浮显示副标题。按照taglist中长按自定义API以实现该功能。设置 taglist允许换行，设置的是tag里面的title lable的文字允许换行，没有只能一行的限制， CollectionViewClassifyMen 允许换行的API。 本次执行max 在example。 。本example可以设置为3行。tag宽度采用自适应样式。预期是一行尽可能显示更多tag。section heder 必须有title内容。超出最多行数限制，展示展开按钮。展开按钮显示more或者less 并附带内置icon"
- Original prompt (English, history only; the more/less fold wording is SUPERSEDED, see the tail control rule): "In a demo or example, when a screen needs a table-view-like style with grouped sections, replace it with
  the following: bring CollectionViewClassifyMenu's tag list into the example and show each cell's main title and icon
  as a tag, in the sectioned style. It may show a fold control; tapping a tag behaves exactly like tapping the
  cell. Long-pressing a cell shows its subtitle in a small floating bubble with an arrow, built with the tag list's
  long-press customization API. The tag list allows wrapping: the tag's title label may wrap (no single-line limit), using
  ClassifyMenu's wrapping API. Here the maximum in the example is 3 rows. Tag width is adaptive, so a row shows as many tags
  as possible. A section header must have title text. Beyond the maximum rows the fold control shows (superseded wording: labelled `more` or
  `less` with its built-in icon)."
- Rules (every platform's example):
  1. Replace a grouped list (a table view with sections, a settings-style list of rows) in a demo or example with the tag
     list. Each cell becomes a tag with its main title and icon; each section is a tag-list section whose header always
     has a non-empty title.
  2. Use the tag list's default initialization first; the tag width is adaptive (content width), so a row holds as many tags
     as fit. Allow the tag title to wrap (ClassifyMenu's title wrapping API; no one-line limit).
  3. Fold at 3 rows in examples. The fold control is the TAIL CONTROL (owner directive 2026-11-25, latest, supersedes every earlier fold wording): the last tag of the list acts as the expand/collapse button and shows ONLY the chevron icon (content `icon`), never title text, no `more` / `less` labels, no header trailing button. Examples set position tail and content icon EXPLICITLY on every platform whose pinned core default is not already tail + icon (Android: `CYLMenuFoldControlPosition.TAIL` + `CYLMenuFoldControlContentIcon`; HarmonyOS: `CYLMenuFoldControlPosition.tail` + `.icon`; Flutter and React Native: `foldControlPosition` inline (the last tag) + `foldControlContent` icon; mini program: `foldControlContent="icon"`, its chevron is always the last tag). Never set `iconAndTitle`, `titleAndIcon` or `title`; `bash scripts/check-example-fold.sh` enforces it.
  4. A tag tap does exactly what tapping the cell did. A long press shows the cell's subtitle in a small floating bubble with an
     arrow, built with the tag list's long-press customization API (`longPressAction`, `menuSubtitleForItem`).
  5. Never work around a missing tag-list capability in the example: add the API to the core (the Flutter and React Native
     bridges, the ClassifyMenu libraries) first and call it from the example (see `core`, tag file `core.md`).
- Added 2026-11-25, prompt (verbatim): "将本example中的taglist改为液态玻璃样式。并找到example相关instructions文件，全英文写入样式要求。"
  Prompt (English): "Change the tag list in this example to the Liquid Glass style, and write the style requirement, in English, into the example
  instructions file."
  6. Every tag list in an example uses the Liquid Glass background (`backgroundStyle` `liquidGlass` on Flutter and React Native,
     `CYLTagBackgroundStyleLiquidGlass` / `tagBackgroundStyle` on iOS, Android and HarmonyOS, the glass tag style of the mini program).
     Set it through the core's one parameter, never with custom fills or borders in the example. Where a device draws no glass
     (below Android 12) the core falls back to flat tags; that is expected. The default content inset (14) comes from the core.
- Owner directive 2026-11-25 (latest, supersedes all earlier fold wording; the header-trailing icon-and-title idea is dropped): "Example tag lists must use the TAIL CONTROL as the expand/collapse button: the last tag acts as the expand button and shows ONLY the icon (chevron, no text)." See rule 3.
- Status of the long-press bubble and title wrapping per platform lives in `docs/task-log.md`. Skill: `cyl-example-taglist`.
- Owner directive 2026-11-25 (latest), prompt (English): "In the examples, the tag list's background board uses the Liquid Glass style, and the main page background of the whole demo is a GRADIENT colour, so that the glass's liquid see-through (refraction/blur of the backdrop) can be tested. If it cannot be implemented in the example, do NOT hack around it: list exactly what the core lacks."
  7. Every example page that shows a glass tag list puts a gradient behind it, on every platform: the page background is a gradient (light and dark variants), the list's own background is transparent / clear so the backdrop shows through, and the glass board and glass tags sample it (the core's glass style; `backdropSource` outside the list where the platform needs one; below Android 12 the flat fallback is expected). Never fake the refraction with custom views or per-tag patches in the example: if the core cannot sample the gradient, record the missing API in `docs/task-log.md` as a core gap (rule 5).
- Owner directive 2026-11-26, prompt (English): "Examples may not use a system search bar; replace it with CYLSearchBarView."
  8. An example's search or text field in a navigation bar or page header is `CYLSearchBarView` with the navigation field preset
     (see `core`, "One search field, no system search bar"); never a system search bar, a text field of its own or a copy of
     the preset's values. Skill: `cyl-search-field`.
- Owner directive 2026-11-26, prompt (English): "Every example must follow the default search button rule: at least one kept, default search button must appear."
  9. Every search or text field of an example (a navigation bar field, a sheet's search, a name field) shows the core's default search
     button (text "Search" by default; the example may choose icon or a custom title or icon, never hide it with
     `showsSearchButton = false` except an editing bar). An example never adds a button of its own that does the same job.
