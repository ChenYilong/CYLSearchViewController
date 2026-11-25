# Example demos: grouped lists as tag lists (tag: `example-demos`)

Details of the `example-demos` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md).

## Grouped demo lists use CollectionViewClassifyMenu's tag list (added 2026-11-25)

- Prompt (verbatim): "deme example演示，如果遇到需要使用类似 tableview 包含section分组功能的样式，优先使用以下样式替换。为example引入并使用CollectionViewClassifyMenu 的taglist 展示提取主标题与icon，使用具有section样式。可以显示more less 折叠展开按钮，点击tag后维持与点击cell相同效果。长按cell显示副标题，小的悬浮框带有箭头。小的悬浮显示副标题。按照taglist中长按自定义API以实现该功能。设置 taglist允许换行，设置的是tag里面的title lable的文字允许换行，没有只能一行的限制， CollectionViewClassifyMen 允许换行的API。 本次执行max 在example。 。本example可以设置为3行。tag宽度采用自适应样式。预期是一行尽可能显示更多tag。section heder 必须有title内容。超出最多行数限制，展示展开按钮。展开按钮显示more或者less 并附带内置icon"
- Prompt (English): "In a demo or example, when a screen needs a table-view-like style with grouped sections, replace it with
  the following: bring CollectionViewClassifyMenu's tag list into the example and show each cell's main title and icon
  as a tag, in the sectioned style. It may show a more/less fold control; tapping a tag behaves exactly like tapping the
  cell. Long-pressing a cell shows its subtitle in a small floating bubble with an arrow, built with the tag list's
  long-press customization API. The tag list allows wrapping: the tag's title label may wrap (no single-line limit), using
  ClassifyMenu's wrapping API. Here the maximum in the example is 3 rows. Tag width is adaptive, so a row shows as many tags
  as possible. A section header must have title text. Beyond the maximum rows the fold control shows, labelled `more` or
  `less` with its built-in icon."
- Rules (every platform's example):
  1. Replace a grouped list (a table view with sections, a settings-style list of rows) in a demo or example with the tag
     list. Each cell becomes a tag with its main title and icon; each section is a tag-list section whose header always
     has a non-empty title.
  2. Use the tag list's default initialization first; the tag width is adaptive (content width), so a row holds as many tags
     as fit. Allow the tag title to wrap (ClassifyMenu's title wrapping API; no one-line limit).
  3. Fold at 3 rows in examples. Beyond that the fold control shows the label `more` or `less` with the built-in chevron
     (the icon-and-title fold content, not the icon alone).
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
- Status of the long-press bubble and title wrapping per platform lives in `docs/task-log.md`. Skill: `cyl-example-taglist`.
