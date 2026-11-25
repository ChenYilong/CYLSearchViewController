package com.cyl.search.example.contacttags

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.Menu
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.view.ViewCompat
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuItemType
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagImagePlacement
import com.cyl.classifymenu.CYLTagListView
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.example.CYLExamplePage

private val CYLLabelSecondary = Color.argb(153, 60, 60, 67)
private val CYLLabelTertiary = Color.argb(76, 60, 60, 67)
private val CYLGray6 = Color.rgb(242, 242, 247)

/**
 * The look of the contact tags demo (iOS `CYLContactTagEditorViewController.tagStyle()`, the chat app's colors).
 */
object CYLContactTagsStyle {
    /** The chat app's green (#07C160) and link color (#576B95). */
    val green: Int = Color.rgb(7, 193, 96)
    val linkColor: Int = Color.rgb(87, 107, 149)

    /** Gray tags, green selected tags. */
    fun tagStyle(): CYLMenuStyle {
        val style = CYLMenuStyle()
        val font = CYLFont.systemFont(16f)
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            val appearance = style.appearanceForState(state)
            appearance.font = font
            appearance.cornerRadius = 6f
            appearance.borderWidth = 0f
            appearance.margin = 14f
        }
        style.normalAppearance.backgroundColor = CYLGray6
        style.normalAppearance.textColor = Color.BLACK
        style.selectedAppearance.backgroundColor = Color.argb(26, 7, 193, 96)
        style.selectedAppearance.textColor = green
        style.itemHeight = 36f
        style.interitemSpacing = 12f
        style.lineSpacing = 12f
        style.sectionInsets = CYLEdgeInsets(4f, 16f, 20f, 16f)
        style.headerHeight = 40f
        style.headerFont = CYLFont.systemFont(15f)
        style.headerTextColor = CYLLabelSecondary
        style.headerHorizontalInset = 16f
        style.backgroundColor = Color.WHITE
        style.imageSize = CYLSize(14f, 14f)
        style.imageTitleSpacing = 6f
        return style
    }
}

/**
 * The launch options of the contact tags demo (iOS launch arguments), read from the activity's intent extras.
 */
object CYLContactTagsOptions {
    /** `CYLContactTags`: the Examples menu opens the demo at launch (iOS `-CYLDemoRow 5`). */
    const val OPEN = "CYLContactTags"
    /** `CYLContactTagsEditor`: the remark screen opens the editor at once. */
    const val EDITOR = "CYLContactTagsEditor"
    /** `CYLContactTagsEmpty`: starts without tags (the placeholder empty states). */
    const val EMPTY = "CYLContactTagsEmpty"
    /** `CYLContactTagsResetCache`: forgets the saved edits (caches A and B). */
    const val RESET_CACHE = "CYLContactTagsResetCache"
    /** `CYLContactTagsServerLatency`: the server's delay in seconds (a string or a number). */
    const val SERVER_LATENCY = "CYLContactTagsServerLatency"
}

private fun Context.dp(value: Float) = (value * resources.displayMetrics.density).toInt()

/**
 * "Edit Remarks" (iOS `CYLContactRemarkViewController`): a remark name and the contact's tags (a display-only
 * `CYLTagListView`); "Tags" opens "Edit Tags". Without tags, CYLTableViewPlaceHolder's `CYLPlaceholderView` takes the
 * list's place; tapping it opens the editor too.
 */
class CYLContactRemarkPage : CYLExamplePage(), CYLMenuDataSource, CYLMenuDelegate {

    lateinit var store: CYLContactTagStore
        private set

    /** The ids of the contact's tags. */
    var tags: List<String> = emptyList()
        private set

    lateinit var tagsView: CYLTagListView
        private set

    /** The placeholder shown while the contact has no tags. */
    var emptyTagsView: CYLPlaceholderView? = null
        private set

    override fun pageTitle(context: Context) = ""

    override fun onCreateActions(menu: Menu) {
        menu.add(cylContactTagsText(requireContext(), "done")).apply {
            setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_ALWAYS)
            isEnabled = false
        }
    }

    override fun createContent(context: Context): View {
        val extras = activity?.intent
        if (extras?.getBooleanExtra(CYLContactTagsOptions.RESET_CACHE, false) == true) {
            CYLContactTagStore.resetCache(context)
            CYLContactTagServer.reset(context)
        }
        if (extras?.getBooleanExtra(CYLContactTagsOptions.EMPTY, false) == true) {
            store = CYLContactTagStore(emptyList())
            tags = emptyList()
        } else {
            store = CYLContactTagStore.bundled(context)
            tags = runCatching { CYLContactTagData.bundled(context).selectedTags }.getOrDefault(emptyList()).filter(store::contains)
        }
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        val title = TextView(context).apply {
            text = cylContactTagsText(context, "editRemarks")
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 28f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setTextColor(Color.BLACK)
            ViewCompat.setAccessibilityHeading(this, true)
        }
        // The remark name: the core field with the navigation preset (one input look), not a system EditText.
        val name = CYLSearchBarView(context).apply {
            applyNavigationFieldStyle()
            placeholder = cylContactTagsText(context, "remarkName")
            textField.contentDescription = placeholder
        }
        tagsView = CYLTagListView(context).apply {
            this.title = cylContactTagsText(context, "tags")
            val titleStyle = CYLTagListView.defaultTitleStyle()
            for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
                titleStyle.appearanceForState(state).font = CYLFont.systemFont(15f)
                titleStyle.appearanceForState(state).textColor = CYLLabelSecondary
                titleStyle.setIconColor(CYLLabelTertiary, state)
            }
            titleStyle.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTrailing
            titleStyle.imageSize = CYLSize(12f, 12f)
            titleStyle.imageTitleSpacing = 4f
            this.titleStyle = titleStyle
            // A header that opens the editor.
            titleView.isClickable = true
            titleView.contentDescription = "${cylContactTagsText(context, "tags")}, ${cylContactTagsText(context, "hintEdit")}"
            titleView.setOnClickListener { editTags() }
            style = CYLContactTagsStyle.tagStyle()
            selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
            showsSectionHeaders = false
            isScrollEnabled = false
            menuDataSource = this@CYLContactRemarkPage
            menuDelegate = this@CYLContactRemarkPage
        }
        column.addView(title, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dp(32f) })
        column.addView(name, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            topMargin = context.dp(36f); leftMargin = context.dp(16f); rightMargin = context.dp(16f)
        })
        column.addView(tagsView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dp(12f) })
        val placeholder = CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, cylContactTagsText(context, "remarkNoTags")).apply {
            // At its content size below "Tags", as iOS (`reportsContentSize`).
            reportsContentSize = true
            contentDescription = "${cylContactTagsText(context, "remarkNoTags")}, ${cylContactTagsText(context, "hintEdit")}"
            isClickable = true
            setOnClickListener { editTags() }
        }
        emptyTagsView = placeholder
        column.addView(placeholder, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
            topMargin = context.dp(16f); leftMargin = context.dp(16f); rightMargin = context.dp(16f)
        })
        tagsView.reloadMenuData()
        updateEmptyTagsView()
        if (extras?.getBooleanExtra(CYLContactTagsOptions.EDITOR, false) == true) {
            column.post { editTags() }
        }
        return ScrollView(context).apply { addView(column) }
    }

    /** Pushes "Edit Tags". */
    fun editTags(): CYLContactTagEditorPage {
        val editor = CYLContactTagEditorPage()
        editor.setUp(store, tags) { updateTags(it) }
        push(editor)
        return editor
    }

    /** Shows `tags` as the contact's tags (the editor's result). */
    fun updateTags(tags: List<String>) {
        this.tags = tags
        tagsView.reloadMenuData()
        updateEmptyTagsView()
        toolbar.menu.findItem(toolbar.menu.getItem(0).itemId)?.isEnabled = true
    }

    private fun updateEmptyTagsView() {
        emptyTagsView?.visibility = if (tags.isEmpty()) View.VISIBLE else View.GONE
        tagsView.visibility = View.VISIBLE
    }

    override fun numberOfSectionsInMenu() = 1
    override fun menuNumberOfItemsInSection(section: Int) = tags.size
    override fun menuTitleForSection(section: Int) = cylContactTagsText(requireContext(), "tags")
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = store.title(tags[indexPath.item]) ?: tags[indexPath.item]
    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) { editTags() }
}

/**
 * "Edit Tags" (iOS `CYLContactTagEditorViewController`): chooses, creates and deletes a contact's tags, searched with
 * this library's `CYLSearchBarView`; the tags are CollectionViewClassifyMenu's `CYLTagListView`.
 * - "Recent" (with a trash button) and "My Tags" (with "Manage"; folded to three rows, the chevron as its last tag).
 * - "Manage" switches the list into its editing mode: delete buttons, dragging and the add control for "My Tags"; a tap on
 *   a tag opens its contacts. Leaving "Manage" uploads the lists to the simulated server.
 * - Typing shows "Search Results" and "+ New tag: <text>"; the keyboard's search key creates the typed tag.
 * - `CYLPlaceholderView` shows the empty states (no match, no tags), centred in the free space below the tags and above
 *   the keyboard.
 * - Network sync (`CYLContactTagServer`): opening shows cache A at once, then downloads B; the sync button pulls an edit
 *   simulated on another device.
 */
class CYLContactTagEditorPage : CYLExamplePage(), CYLMenuDataSource, CYLMenuDelegate, CYLSearchBarViewDelegate {

    /** One item of a section: a tag, or "+ New Tag" (null: asks for a name) / "+ New tag: <name>". */
    sealed class Item {
        data class Tag(val id: String) : Item()
        data class Create(val name: String?) : Item()
    }

    enum class SectionKind { RECENT, MINE, RESULTS }

    /** The empty state shown with `CYLPlaceholderView`. */
    enum class EmptyState { NONE, NO_MATCH, NO_TAGS }

    data class Section(val kind: SectionKind, val title: String, val items: List<Item>)

    lateinit var store: CYLContactTagStore
        private set
    var initialSelection: List<String> = emptyList()
        private set
    var selectedTags: MutableList<String> = mutableListOf()
        private set
    var query = ""
        private set
    var sections: List<Section> = emptyList()
        private set
    var emptyState = EmptyState.NONE
        private set
    private var onDone: ((List<String>) -> Unit)? = null

    lateinit var tagListView: CYLTagListView
        private set
    lateinit var searchBar: CYLSearchBarView
        private set
    lateinit var server: CYLContactTagServer
        private set
    var placeholderView: CYLPlaceholderView? = null
        private set
    private lateinit var placeholderArea: FrameLayout
    private lateinit var manageButton: Button

    /**
     * The edit field of "Manage" mode: CYLSearchViewController's editing bar (the search bar's look), pinned above the
     * keyboard. It adds a tag ("Add") or renames one ("Done", after a pencil or title tap).
     */
    lateinit var editingBar: CYLSearchBarView
        private set

    /** The tag the editing bar renames; null while it adds. */
    private var renamingIndexPath: CYLIndexPath? = null
    private var doneButton: Button? = null
    private var previousSoftInputMode: Int? = null

    /** "Manage" mode: the tag list's editing mode. */
    val isManaging: Boolean get() = this::tagListView.isInitialized && tagListView.isEditing

    /** The store, the selection the editor opens with, and what "Done" calls. */
    fun setUp(store: CYLContactTagStore, selectedTags: List<String>, onDone: (List<String>) -> Unit) {
        this.store = store
        initialSelection = selectedTags.filter(store::contains)
        this.selectedTags = initialSelection.toMutableList()
        this.onDone = onDone
    }

    override fun pageTitle(context: Context) = cylContactTagsText(context, "editTags")

    override fun onCreateActions(menu: Menu) {
        val context = requireContext()
        menu.add(cylContactTagsText(context, "sync")).apply {
            setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_ALWAYS)
            setIcon(android.R.drawable.ic_popup_sync)
            icon?.setTint(CYLContactTagsStyle.linkColor)
            setOnMenuItemClickListener { syncFromOtherDevices(); true }
        }
        val done = Button(context).apply {
            text = cylContactTagsText(context, "done")
            isAllCaps = false
            stateListAnimator = null
            minWidth = context.dp(56f); minimumWidth = context.dp(56f); minHeight = 0; minimumHeight = 0
            setPadding(context.dp(12f), 0, context.dp(12f), 0)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
            typeface = Typeface.DEFAULT_BOLD
            tag = "CYLContactTagsDone"
            setOnClickListener { done() }
        }
        doneButton = done
        menu.add(cylContactTagsText(context, "done")).apply {
            setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_ALWAYS)
            actionView = FrameLayout(context).apply {
                setPadding(0, 0, context.dp(12f), 0)
                addView(done, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, context.dp(32f), Gravity.CENTER_VERTICAL))
            }
        }
    }

    override fun createContent(context: Context): View {
        if (!this::store.isInitialized) setUp(CYLContactTagStore.bundled(context), emptyList()) {}
        activity?.intent?.let { intent ->
            (intent.getStringExtra(CYLContactTagsOptions.SERVER_LATENCY)?.toDoubleOrNull()
                ?: intent.extras?.get(CYLContactTagsOptions.SERVER_LATENCY)?.toString()?.toDoubleOrNull())?.let { CYLContactTagServer.latencySeconds = it }
        }
        server = CYLContactTagServer(context) { view as? ViewGroup }
        manageButton = Button(context).apply {
            isAllCaps = false
            background = null
            stateListAnimator = null
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setTextColor(CYLContactTagsStyle.linkColor)
            setPadding(0, 0, 0, 0)
            minWidth = 0; minimumWidth = 0; minHeight = 0; minimumHeight = 0
            setOnClickListener { toggleManaging() }
        }
        editingBar = CYLSearchBarView.editingBar(context, cylContactTagsText(context, "tagName"), cylContactTagsText(context, "add")).apply {
            editingSubmitHandler = { _, text -> submitEditingBar(text) }
            applyNavigationFieldStyle()
            visibility = View.GONE
        }
        searchBar = CYLSearchBarView(context).apply {
            placeholder = cylContactTagsText(context, "search")
            textField.contentDescription = cylContactTagsText(context, "searchTags")
            tag = "CYLContactTagsSearchBar"
            applyNavigationFieldStyle()
            delegate = this@CYLContactTagEditorPage
        }
        tagListView = CYLTagListView(context, CYLMenuFoldControl().apply {
            position = CYLMenuFoldControlPosition.TAIL
            content = CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
        }).apply {
            style = CYLContactTagsStyle.tagStyle()
            selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeMultiple
            allowsEmptySelection = true
            defaultVisibleRows = 3
            menuDataSource = this@CYLContactTagEditorPage
            menuDelegate = this@CYLContactTagEditorPage
            tag = "CYLContactTagsList"
            // Leaving "Manage" uploads the edited lists (cache A, already saved) to the server.
            editingFinishHandler = { uploadToServer() }
            // "Manage" edits in the editing bar, not in the list's own field.
            showsAddItemViewWhileEditing = false
            renameRequestHandler = { indexPath, title -> beginRenaming(indexPath, title) }
        }
        placeholderArea = FrameLayout(context).apply { visibility = View.GONE }
        val body = FrameLayout(context).apply {
            addView(tagListView, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            addView(placeholderArea, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
        val column = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            addView(searchBar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                leftMargin = context.dp(8f); rightMargin = context.dp(8f); topMargin = context.dp(8f)
            })
            addView(body, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f).apply { topMargin = context.dp(8f) })
        }
        editingBar.pinToKeyboard(column)
        // The free space ends at the keyboard (iOS keyboardLayoutGuide): the window is not resized for the IME, so the part of
        // the page the keyboard covers (reported by the editing bar, pinned to the page) pads the placeholder area.
        editingBar.keyboardOverlapHandler = { overlap -> placeholderArea.setPadding(0, 0, 0, overlap) }
        reload()
        loadFromServer()
        return column
    }

    override fun onResume() {
        super.onResume()
        // The page shrinks above the keyboard, so the placeholder centres in the visible part (iOS keyboardLayoutGuide).
        activity?.window?.let { window ->
            if (previousSoftInputMode == null) previousSoftInputMode = window.attributes.softInputMode
            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
        }
    }

    override fun onDestroyView() {
        server.cancel()
        previousSoftInputMode?.let { activity?.window?.setSoftInputMode(it) }
        super.onDestroyView()
    }

    // Editing bar

    /** A pencil or title tap in "Manage": the editing bar shows the tag's name, the button reads "Done", the keyboard rises. */
    private fun beginRenaming(indexPath: CYLIndexPath, title: String) {
        renamingIndexPath = indexPath
        editingBar.cancelButtonTitle = cylContactTagsText(requireContext(), "done")
        editingBar.text = title
        editingBar.showKeyboard()
        editingBar.textField.selectAll()
    }

    /** The editing bar's action: rename the tag being renamed, or add a tag. */
    private fun submitEditingBar(text: String) {
        if (renamingIndexPath != null) {
            renamingIndexPath = null
            tagListView.finishRenamingToTitle(text)
            editingBar.hideKeyboard()
        } else {
            tagListView.submitNewItemNamed(text)
        }
        editingBar.text = ""
        editingBar.cancelButtonTitle = cylContactTagsText(requireContext(), "add")
    }

    /** Shows the editing bar in "Manage" mode and hides it otherwise. */
    private fun updateEditingBar() {
        editingBar.visibility = if (isManaging) View.VISIBLE else View.GONE
        if (!isManaging) {
            if (renamingIndexPath != null) {
                renamingIndexPath = null
                tagListView.cancelRenaming()
            }
            editingBar.text = ""
            editingBar.cancelButtonTitle = cylContactTagsText(requireContext(), "add")
            editingBar.hideKeyboard()
        }
    }

    /** Renames the tag with `id` as the pencil and the editing bar do, in "Manage" mode (for tests and automation). */
    fun renameTag(id: String, title: String) {
        val indexPath = indexPathOf(id) ?: return
        if (sections[indexPath.section].kind != SectionKind.MINE) return
        tagListView.beginRenamingItemAtIndexPath(indexPath)
        submitEditingBar(title)
    }

    // Network sync

    /** Cache A is what the store already shows; the server's sections, when they arrive, replace them. */
    private fun loadFromServer() {
        server.fetch(listOf(CYLContactTagStore.MINE_CACHE_KEY, CYLContactTagStore.RECENT_CACHE_KEY)) { sections ->
            if (view != null && store.apply(sections)) reload()
        }
    }

    /** Uploads "My Tags" and "Recent" (cache A, with ids) to the server. */
    fun uploadToServer() {
        server.upload(store.cacheSections)
    }

    /** Another device edits the server's data, then this device pulls it. */
    fun syncFromOtherDevices() {
        server.simulateOtherDeviceEdit(store.cacheSections[CYLContactTagStore.MINE_CACHE_KEY].orEmpty())
        server.fetch(listOf(CYLContactTagStore.MINE_CACHE_KEY)) { sections ->
            if (view != null && store.apply(sections)) reload()
        }
    }

    // Content

    fun makeSections(): List<Section> {
        val context = requireContext()
        if (query.isNotEmpty()) {
            val items = store.tagsMatching(query).map<String, Item> { Item.Tag(it) }.toMutableList()
            if (store.canCreate(query)) items.add(Item.Create(query))
            return listOf(Section(SectionKind.RESULTS, cylContactTagsText(context, "results"), items))
        }
        val result = ArrayList<Section>()
        if (store.recentIDs.isNotEmpty()) result.add(Section(SectionKind.RECENT, cylContactTagsText(context, "recent"), store.recentIDs.map { Item.Tag(it) }))
        // While managing, the list's add control replaces "+ New Tag".
        val create: List<Item> = if (isManaging) emptyList() else listOf(Item.Create(null))
        result.add(Section(SectionKind.MINE, cylContactTagsText(context, "mine"), store.tagIDs.map<String, Item> { Item.Tag(it) } + create))
        return result
    }

    fun reload() {
        val context = requireContext()
        sections = makeSections()
        manageButton.text = cylContactTagsText(context, if (isManaging) "doneManaging" else "manage")
        manageButton.contentDescription = "${manageButton.text}, ${cylContactTagsText(context, if (isManaging) "hintDoneManaging" else "hintManage")}"
        tagListView.reloadMenuData()
        syncSelection()
        updateDoneButton()
        updatePlaceholder()
    }

    fun makeEmptyState(): EmptyState = when {
        query.isNotEmpty() -> if (store.tagsMatching(query).isEmpty()) EmptyState.NO_MATCH else EmptyState.NONE
        store.tags.isEmpty() -> EmptyState.NO_TAGS
        else -> EmptyState.NONE
    }

    private fun updatePlaceholder() {
        val state = makeEmptyState()
        placeholderArea.visibility = if (state == EmptyState.NONE) View.GONE else View.VISIBLE
        if (state != emptyState) {
            emptyState = state
            placeholderArea.removeAllViews()
            placeholderView = null
            val context = requireContext()
            val placeholder = when (state) {
                EmptyState.NONE -> null
                EmptyState.NO_MATCH -> CYLPlaceholderView(context, CYLPlaceholderStyle.NoResults, cylContactTagsText(context, "noMatch"))
                EmptyState.NO_TAGS -> CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, cylContactTagsText(context, "noTags"))
            }
            placeholder?.let {
                it.tag = "CYLContactTagsPlaceholder"
                // Centred at its content size in the free space, as iOS (`reportsContentSize`).
                it.reportsContentSize = true
                placeholderArea.addView(it, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER))
                placeholderView = it
            }
        }
        layoutPlaceholderArea()
    }

    /** The free space below the tags shown ("+ New tag" stays tappable above it); the page already ends at the keyboard. */
    private fun layoutPlaceholderArea() {
        val top = (tagListView.contentHeight * resources.displayMetrics.density).toInt()
        (placeholderArea.layoutParams as? FrameLayout.LayoutParams)?.let {
            if (it.topMargin != top) {
                it.topMargin = top
                placeholderArea.layoutParams = it
            }
        }
    }

    fun syncSelection() {
        tagListView.selectedIndexPaths = sections.flatMapIndexed { section, content ->
            content.items.mapIndexedNotNull { item, element -> if (element is Item.Tag && element.id in selectedTags) CYLIndexPath(item, section) else null }
        }
    }

    /** "Done" is green with a selection or a change, and off while searching. */
    val isDoneEnabled: Boolean get() = query.isEmpty() && (selectedTags.isNotEmpty() || selectedTags.toSet() != initialSelection.toSet())

    private fun updateDoneButton() {
        val button = doneButton ?: return
        val context = button.context
        button.isEnabled = isDoneEnabled
        button.background = GradientDrawable().apply {
            setColor(if (isDoneEnabled) CYLContactTagsStyle.green else Color.argb(41, 120, 120, 128)); cornerRadius = context.dp(4f).toFloat()
        }
        button.setTextColor(if (isDoneEnabled) Color.WHITE else CYLLabelTertiary)
    }

    fun indexPathOf(id: String): CYLIndexPath? {
        sections.forEachIndexed { section, content ->
            val item = content.items.indexOf(Item.Tag(id))
            if (item >= 0) return CYLIndexPath(item, section)
        }
        return null
    }

    // Actions

    /** As typing `text` in the search bar. */
    fun setQuery(text: String) {
        searchBar.text = text
        queryChanged(text)
    }

    private fun queryChanged(text: String) {
        // Searching leaves "Manage".
        if (isManaging && text.isNotEmpty()) tagListView.setEditing(false, false)
        query = CYLContactTagStore.normalizedName(text)
        reload()
    }

    fun select(id: String) {
        if (id !in selectedTags) selectedTags.add(id)
        syncSelection()
        updateDoneButton()
    }

    fun deselect(id: String) {
        selectedTags.remove(id)
        syncSelection()
        updateDoneButton()
    }

    /** Creates the tag (or finds it), selects it, leaves the search and scrolls to it. */
    fun createTag(name: String): String? {
        val id = store.createTag(name) ?: return null
        if (id !in selectedTags) selectedTags.add(id)
        searchBar.text = ""
        query = ""
        searchBar.hideKeyboard()
        reload()
        indexPathOf(id)?.let { if (sections[it.section].kind == SectionKind.MINE) tagListView.scrollToItemAtIndexPath(it, false) }
        view?.announceForAccessibility(cylContactTagsText(requireContext(), "created", store.title(id) ?: name))
        return id
    }

    private fun promptForNewTag() {
        val context = requireContext()
        val field = CYLSearchBarView(context).apply {
            applyNavigationFieldStyle()
            placeholder = cylContactTagsText(context, "tagName")
            textField.contentDescription = placeholder
        }
        AlertDialog.Builder(context)
            .setTitle(cylContactTagsText(context, "newTag"))
            .setView(FrameLayout(context).apply { setPadding(context.dp(20f), 0, context.dp(20f), 0); addView(field, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)) })
            .setNegativeButton(cylContactTagsText(context, "cancel"), null)
            .setPositiveButton(cylContactTagsText(context, "ok")) { _, _ -> createTag(field.text.orEmpty()) }
            .show()
    }

    fun toggleManaging() {
        if (isManaging) {
            tagListView.setEditing(false, true)
        } else {
            setQuery("")
            searchBar.hideKeyboard()
            tagListView.setEditing(true, true)
        }
        reload()
    }

    fun clearRecent() {
        store.clearRecent()
        reload()
        view?.announceForAccessibility(cylContactTagsText(requireContext(), "recentCleared"))
    }

    /** Pushes the contacts that have the tag with `id`. */
    fun showContacts(id: String): CYLContactListPage {
        val page = CYLContactListPage()
        page.setUp(store.title(id) ?: id, store.contacts(id)) { store.title(it) }
        push(page)
        return page
    }

    fun deleteTag(id: String) {
        store.deleteTag(id)
        selectedTags.remove(id)
        reload()
    }

    private fun done() {
        if (!isDoneEnabled) return
        store.markUsed(selectedTags)
        onDone?.invoke(selectedTags.toList())
        searchBar.hideKeyboard()
        parentFragmentManager.popBackStack()
    }

    // CYLSearchBarViewDelegate

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {
        if (CYLContactTagStore.normalizedName(text) != query) queryChanged(text)
    }

    /** The keyboard's search key creates the tag typed when it does not exist yet. */
    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        if (store.canCreate(query)) createTag(query) else searchBarView.hideKeyboard()
    }

    // CYLMenuDataSource

    private fun item(indexPath: CYLIndexPath) = sections[indexPath.section].items[indexPath.item]

    override fun numberOfSectionsInMenu() = sections.size
    override fun menuNumberOfItemsInSection(section: Int) = sections[section].items.size
    override fun menuTitleForSection(section: Int) = sections[section].title
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = when (val element = item(indexPath)) {
        is Item.Tag -> store.title(element.id) ?: element.id
        is Item.Create -> element.name.orEmpty()
    }
    override fun menuItemTypeAtIndexPath(indexPath: CYLIndexPath) =
        if (item(indexPath) is Item.Create) CYLMenuItemType.CYLMenuItemTypeCreate else CYLMenuItemType.CYLMenuItemTypeTag
    override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath): String? =
        if (isManaging && sections[indexPath.section].kind == SectionKind.MINE && item(indexPath) is Item.Tag) cylContactTagsText(requireContext(), "hintContacts") else null
    // "Recent" uses the list's built-in clear button (menuShowsClearButtonForSection), not an accessory.
    override fun menuAccessoryViewForSection(section: Int): View? = if (sections[section].kind == SectionKind.MINE) manageButton else null
    /** "Recent" shows CollectionViewClassifyMenu's built-in clear button. */
    override fun menuShowsClearButtonForSection(section: Int) = section in sections.indices && sections[section].kind == SectionKind.RECENT
    /** The tag's id: its primary key for the cache, the server and the contacts. */
    override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String = when (val element = item(indexPath)) {
        is Item.Tag -> element.id
        is Item.Create -> "create:" + element.name.orEmpty()
    }
    /** The pencil's rename in "Manage" mode: the title changes, the id (and its contacts) stay. */
    override fun supportsRenamingItems() = true
    override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) {
        val element = item(indexPath) as? Item.Tag ?: return
        store.renameTag(element.id, title)
        sections = makeSections()
    }
    /** Only "My Tags" takes part in "Manage" (delete buttons, dragging, the add control). */
    override fun menuSectionAllowsEditing(section: Int) = section in sections.indices && sections[section].kind == SectionKind.MINE
    /** Stable cache keys: "Recent" comes and goes, so section indexes would change. */
    override fun menuCacheKeyForSection(section: Int): String = when (sections[section].kind) {
        SectionKind.RECENT -> CYLContactTagStore.RECENT_CACHE_KEY
        SectionKind.MINE -> CYLContactTagStore.MINE_CACHE_KEY
        SectionKind.RESULTS -> "results"
    }
    override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath) {
        val element = item(indexPath) as? Item.Tag ?: return
        store.deleteTag(element.id)
        selectedTags.remove(element.id)
        sections = makeSections()
    }
    override fun supportsMovingItems() = true
    override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath) {
        store.moveTag(sourceIndexPath.item, toIndexPath.item)
        sections = makeSections()
    }

    // CYLMenuDelegate

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        val element = item(indexPath) as? Item.Tag ?: return
        if (isManaging) showContacts(element.id) else select(element.id)
    }

    /** "+ New Tag": with the searched name, creates it; otherwise asks for one. In "Manage", the add control adds. */
    override fun menuDidRequestNewItemWithName(menu: Any, name: String, atIndexPath: CYLIndexPath) {
        if (isManaging) {
            val id = store.createTag(name)
            reload()
            id?.let { indexPathOf(it) }?.let { tagListView.scrollToItemAtIndexPath(it, true) }
            return
        }
        if (name.isEmpty()) promptForNewTag() else createTag(name)
    }

    override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        (item(indexPath) as? Item.Tag)?.let { deselect(it.id) }
    }

    override fun menuDidChangeEditing(menu: Any, editing: Boolean) {
        updateEditingBar()
        reload()
    }

    /** The clear button of "Recent". */
    override fun menuDidTapClearButtonInSection(menu: Any, section: Int) {
        clearRecent()
    }

    override fun menuDidChangeContentHeight(menu: Any, height: Float) {
        if (this::placeholderArea.isInitialized) layoutPlaceholderArea()
    }
}

/**
 * The contacts that have a tag (iOS `CYLContactListViewController`): the page a tap on a tag opens in "Manage" mode;
 * CYLTableViewPlaceHolder's placeholder when none has it.
 */
class CYLContactListPage : CYLExamplePage() {
    var tagTitle: String = ""
        private set
    var contacts: List<CYLContactTagContact> = emptyList()
        private set
    private var titleOfTag: (String) -> String? = { null }

    fun setUp(tag: String, contacts: List<CYLContactTagContact>, titleOfTag: (String) -> String?) {
        tagTitle = tag
        this.contacts = contacts
        this.titleOfTag = titleOfTag
    }

    override fun pageTitle(context: Context) = cylContactTagsText(context, "contactsTitle", tagTitle, contacts.size)

    override fun createContent(context: Context): View {
        if (contacts.isEmpty()) {
            return FrameLayout(context).apply {
                setBackgroundColor(CYLGray6)
                addView(CYLPlaceholderView(context, CYLPlaceholderStyle.PersonOff, cylContactTagsText(context, "noContacts", tagTitle)).apply { tag = "CYLContactListEmpty" },
                    FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER))
            }
        }
        val list = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(context.dp(16f), context.dp(16f), context.dp(16f), context.dp(16f))
            background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = context.dp(10f).toFloat() }
        }
        for (contact in contacts) {
            val row = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(context.dp(16f), context.dp(10f), context.dp(16f), context.dp(10f))
                addView(TextView(context).apply { text = contact.name; setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f); setTextColor(Color.BLACK) })
                addView(TextView(context).apply {
                    text = contact.tags.mapNotNull(titleOfTag).joinToString(" · ")
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                    setTextColor(CYLLabelSecondary)
                })
            }
            list.addView(row)
        }
        return ScrollView(context).apply {
            setBackgroundColor(CYLGray6)
            tag = "CYLContactList"
            addView(FrameLayout(context).apply {
                setPadding(context.dp(16f), context.dp(16f), context.dp(16f), context.dp(16f))
                addView(list)
            })
        }
    }
}
