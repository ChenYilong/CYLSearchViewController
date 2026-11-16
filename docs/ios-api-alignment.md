# iOS API Alignment (Android core → iOS)

The reverse of [android-api-alignment.md](android-api-alignment.md): every public API and feature of the Android core
(the code published to Maven / Gradle: `android/merged/cylsearch`, and the Android libraries of the sub-repositories
this project ships with, such as CollectionViewClassifyMenu's tag views) next to its iOS counterpart.

## IN PROGRESS (TODO 2026-11-17): Android core → iOS table, score to 100, then iOS → Android

- Prompt (verbatim): "找到下面描述中相关的文档，如果没有就新建，如果有就插入：将iOS端与Android的core核心代码，制作一个表格，第一列为Android 端core核心代码的API以及功能列表，第二列为功能描述，第三列为iOS端对应的api或者功能。第三列默认为TODO。制作评分系统，第三列没有TODO 为满分，全部是TODO为0分。制作表格完成后，第一步 寻找iOS端对应的api和功能。第二：打分。第三步：开始实现iOS端没有的功能。和api。第三步：更新iOS端example 使用新增api 和功能，复刻Android的对应的example。我举例说明：android端有一个拖拽tag 的功能，以及诸多API。iOS端则完全没有。你需要标记todo，然后先实现core核心代码，然后复刻example。第二个例子，第一个的例子中其中的tag 结构比iOS端丰富。左侧为icon中间为title，右侧为总是固定保留的删除icon。iOS端缺少删除icon。你应该首选修改core核心代码，将iOS端的封装好的icon加title的组合再merge进android的逻辑，新增删除icon。并支持点击事件 允许拖拽事件。并保持iOS端与android的核心空间代码逻辑一致，API一致。并且taglist也应展示删除tag的演示。删除后更新list数据源后展示是否重新布局。100分后，再制作一个表格格式类似，第一列为iOS端api与功能，第二列描述，第三列为android端的对应，默认TODO，制作评分系统. 找到下面描述中相关的文档，如果没有就新建，如果有就插入：全英文写入：制作一个表格，第一列为，第二列为功能描述，第三列为 对应的api或者功能。第三列默认为TODO。制作评分系统，第三列没有TODO 为满分，全部是TODO为0分。制作表格以及评分系统完成后，第一步 尝试搜索现有代码，尝试匹配TODO项，寻找对应的api和功能。第二：打分。第三：。开始逐一处理TODO。并更新TODO为对应实现。第四步骤：打分。如此循环往复一直到满分为止。同样优先更新核心组件，使用example展示用法。"
- Prompt (English): "Find the related documents (create one if none) and insert: a table of the iOS and Android core
  code. Column 1: the Android core APIs and features; column 2: what each does; column 3: the iOS counterpart, `TODO`
  by default. Scoring: no `TODO` in column 3 is 100, all `TODO` is 0. Then (1) find the iOS counterparts, (2) score,
  (3) implement on iOS what it lacks, (4) update the iOS example to use the new APIs, copying the Android example.
  Example 1: Android has tag dragging and many APIs; iOS has none: mark TODO, implement the core first, then copy the
  example. Example 2: the Android tag is richer: icon on the left, title in the middle, an always-present delete icon on
  the right; iOS lacks the delete icon. Change the core first: merge iOS's icon + title tag into the Android logic, add
  the delete icon, support tap and drag, keep the iOS and Android core logic and API the same, and show tag deletion in
  the tag list demo (after deleting, update the data source and show the relayout). After 100, make the reverse table
  (column 1 iOS APIs, column 2 description, column 3 Android counterpart, `TODO` by default) with its score. Write the
  general process in English into the related documents: a table (column 1 an API or feature, column 2 its
  description, column 3 the counterpart, `TODO` by default), scored (no `TODO` = 100, all `TODO` = 0); then search the
  code to match the `TODO` rows, score, resolve the `TODO` rows one by one (each becomes its implementation), score,
  and repeat until 100. Core components first; examples show the usage."
- Rule written: `AGENTS.md`, "API parity tables"; skill `cyl-api-parity`.
