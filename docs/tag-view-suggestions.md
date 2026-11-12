# Tag View Suggestions (CollectionViewClassifyMenu)

Suggestions under the search bar shown as a list (table view) or as tags (collection view, from
CollectionViewClassifyMenu).

## TODO (2026-11-12): CollectionViewClassifyMenu as a dependency and a tag-view suggestion style

- Context: CollectionViewClassifyMenu is a sibling project in the same vault folder
  (`../CollectionViewClassifyMenu`) with a podspec at its root. `CYLSearchView` lists suggestions in
  `suggestionsTableView` today.
- Requirements:
  1. iOS: make CollectionViewClassifyMenu a sub-dependency of this pod through its root podspec; depend on its
     newest commit (which may not be on its main branch), or on the local path while developing, but commit only the
     commit-based dependency.
  2. Add support in the core with an enum or a parameter that chooses how suggestions appear under the search bar:
     a table view or a collection view (tags). Change the core first; add an interface to CollectionViewClassifyMenu
     only when needed, commit it there, then update this repository's commit dependency.
  3. Show the styles in the example: an empty tab item named "tagview style" shows the existing examples' suggestions
     with different parameters in the new style.
- Prompt (verbatim): "在iOS端 将CollectionViewClassifyMenu 也就是本项目在本地 本机环境的同一个文件夹目录下的项目，文件夹就叫CollectionViewClassifyMenu 通过根目录的.spec 文件制作成本仓库的子依赖库。你可以通过查找CollectionViewClassifyMen的最新commit地址进行依赖，最新commit可能不在main分支。也可以通过本地路径依赖，选择一个方便你开发的方式集成，但commit前要移除本地依赖形式，采用commit依赖。为iOS端加入CollectionViewClassifyMen 支持，采用枚举形式，或者参数形式，指定 效果，效果类似搜索框下端具体是tableview还是collectionview。优先采用修改core核心代码的方式实现，如有必要也可以前往CollectionViewClassifyMen新增接口，帮CollectionViewClassifyMen提交后更新本仓库commit依赖继续开发。在本项目example中展示以上提到的不同样式。将现在已有的example展示，寻找一个空的tabbaritem项，命名为tagview样式，展示现有样式的不同参数设置后的新搜索备选项展示形式。"
- Prompt (English): "On iOS, make CollectionViewClassifyMenu (the project in the same local folder, named
  CollectionViewClassifyMenu) a sub-dependency of this repository through its root .spec file. Depend on its newest
  commit (maybe not on main) or on the local path, whichever is convenient while developing, but remove the local
  form before committing and use the commit form. Add CollectionViewClassifyMenu support on iOS with an enum or a
  parameter that chooses the effect, i.e. whether the area under the search bar is a table view or a collection
  view. Prefer changing the core; if needed, add interfaces to CollectionViewClassifyMenu, commit there, then update
  this repository's commit dependency and continue. Show the styles in the example: find an empty tab item, name it
  tagview style, and show the existing examples' new suggestion presentation with different parameters."
- Status: logged; order: after the Android task and the plus button rule.
