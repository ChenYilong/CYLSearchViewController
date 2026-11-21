package com.cyl.search.example

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.net.Uri
import androidx.core.content.ContextCompat
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagButton
import com.cyl.classifymenu.CYLTagContentAlignment
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView

/**
 * A list of rows with a title, an optional subtitle and icon, and a tap action (iOS `UITableView` menus).
 */
internal fun Context.cylMenuList(rows: List<Triple<String, String?, () -> Unit>>, icons: List<Drawable?> = emptyList(), headers: Map<Int, String> = emptyMap()): View {
    val density = resources.displayMetrics.density
    val column = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
    rows.forEachIndexed { index, (title, subtitle, action) ->
        headers[index]?.let { header ->
            column.addView(TextView(this).apply {
                text = header
                setTextColor(Color.GRAY)
                textSize = 13f
                setPadding((16 * density).toInt(), (20 * density).toInt(), (16 * density).toInt(), (6 * density).toInt())
            })
        }
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            minimumHeight = (56 * density).toInt()
            setPadding((16 * density).toInt(), (8 * density).toInt(), (16 * density).toInt(), (8 * density).toInt())
            isClickable = true
            isFocusable = true
            foreground = ContextCompat.getDrawable(context, android.util.TypedValue().also {
                theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true)
            }.resourceId)
            setOnClickListener { action() }
        }
        icons.getOrNull(index)?.let { icon ->
            row.addView(ImageView(this).apply { setImageDrawable(icon) }, LinearLayout.LayoutParams((32 * density).toInt(), (32 * density).toInt()).apply {
                marginEnd = (16 * density).toInt()
            })
        }
        val texts = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        texts.addView(TextView(this).apply { text = title; textSize = 17f })
        subtitle?.let { texts.addView(TextView(this).apply { text = it; textSize = 13f; setTextColor(Color.GRAY) }) }
        row.addView(texts, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        row.addView(TextView(this).apply { text = "›"; textSize = 22f; setTextColor(Color.LTGRAY) })
        column.addView(row)
    }
    return ScrollView(this).apply { addView(column) }
}

/**
 * The examples menu (iOS `CYLSearchDemoMenuViewController`): the search example, the placeholder styles, the search
 * bar, the ports of the other libraries' examples, and their original samples.
 */
class CYLSearchDemoMenuFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.title")

    override fun createContent(context: Context): View {
        val page = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        page.addView(context.cylSVGADemoHeader(), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        page.addView(context.cylMenuList(listOf(
            Triple(context.cylDemoText("demo.reproduction"), null) { push(CYLSearchExampleFragment()) },
            Triple(context.cylDemoText("demo.styles"), null) { push(CYLSearchPlaceholderGalleryFragment()) },
            Triple(context.cylDemoText("demo.searchBar"), null) { push(CYLSearchBarDemoFragment()) },
            Triple(context.cylDemoText("demo.ports"), null) { push(CYLSearchPortsFragment()) },
            Triple(context.getString(R.string.example_originals), context.getString(R.string.example_originals_subtitle)) { push(CYLOriginalSamplesFragment()) },
            // Row 6 (iOS `-CYLDemoRow 5`): CollectionViewClassifyMenu's contact tags example on CYLSearchViewController.
            Triple(com.cyl.search.example.contacttags.cylContactTagsText(context, "row"), null) { push(com.cyl.search.example.contacttags.CYLContactRemarkPage()) },
        )), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        return page
    }

    override fun onViewCreated(view: View, savedInstanceState: android.os.Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // `--ez CYLContactTags true` opens the contact tags demo at launch (iOS `-CYLDemoRow 5`), for screenshots.
        if (savedInstanceState == null && activity?.intent?.getBooleanExtra(com.cyl.search.example.contacttags.CYLContactTagsOptions.OPEN, false) == true) {
            view.post { push(com.cyl.search.example.contacttags.CYLContactRemarkPage()) }
        }
    }
}

/** The side of the SVGA demo's animated icon in dp (iOS `CYLSVGADemoTagButton.iconSide`). */
private const val SVGA_ICON_SIDE = 64f

/**
 * The SVGA demo above the Examples list (iOS `CYLSVGADemoHeaderView`, HarmonyOS `svgaHeader`): a `CYLTagButton`
 * (CollectionViewClassifyMenu, the one icon + title + animated icon component on CYLTabBarController's
 * `CYLAnimatedItemView`) whose `animationURL` is the `tab_activity.svga` asset, drawn by the SVGA engine the app adds
 * (SVGAPlayer), so the example has no SVGA player of its own. The icon comes before the title, at the leading edge,
 * without a border. It plays once when shown and again on each tap.
 */
private fun Context.cylSVGADemoHeader(): View {
    val density = resources.displayMetrics.density
    val title = getString(R.string.svga_demo)
    val button = CYLTagButton(this, title, null, Uri.parse("file:///android_asset/tab_activity.svga"))
    button.style = CYLMenuStyle().apply {
        imageSize = CYLSize(SVGA_ICON_SIDE, SVGA_ICON_SIDE)
        animationSize = CYLSize(SVGA_ICON_SIDE, SVGA_ICON_SIDE)
        imageTitleSpacing = 12f
        contentAlignment = CYLTagContentAlignment.CYLTagContentAlignmentLeading
        itemHeight = SVGA_ICON_SIDE
        listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED).forEach { state ->
            appearanceForState(state).apply {
                backgroundColor = Color.TRANSPARENT
                borderColor = null
                borderWidth = 0f
                contentInsets = CYLEdgeInsets(0f, 0f, 0f, 0f)
                cornerRadius = 0f
                textColor = Color.GRAY
                font = CYLFont(13f)
            }
        }
    }
    button.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
    // The row handles the tap (as HarmonyOS passes `interactive: false`): a tag that is not clickable leaves the touches
    // to its parent (CYLTagButton.onTouchEvent).
    button.isClickable = false
    button.isLongClickable = false
    val row = LinearLayout(this).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding((16 * density).toInt(), (12 * density).toInt(), (16 * density).toInt(), (12 * density).toInt())
        contentDescription = title
        accessibilityDelegate = object : View.AccessibilityDelegate() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: android.view.accessibility.AccessibilityNodeInfo) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.hintText = getString(R.string.svga_demo_hint)
            }
        }
        isClickable = true
        isFocusable = true
        setOnClickListener { button.playAnimation() }
        tag = "CYLSVGADemoHeader"
    }
    row.addView(button, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    // Plays once when shown, as the tab icons do when selected (iOS `didMoveToWindow`).
    // The SVGA player plays once the file is parsed when asked before (CYLSVGATabBarItemAnimator).
    button.post { button.playAnimation() }
    return row
}

/**
 * Every placeholder image with each built-in message, and the custom forms (iOS
 * `CYLSearchPlaceholderGalleryViewController`), drawn by CYLTableViewPlaceHolder's `CYLPlaceholderView`: the search
 * core has no placeholder view of its own.
 */
class CYLSearchPlaceholderGalleryFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.styles")

    override fun createContent(context: Context): View {
        val rows = mutableListOf<Triple<String, String?, () -> Unit>>()
        val icons = mutableListOf<Drawable?>()
        val headers = mutableMapOf<Int, String>()
        // The styles of the former search placeholder, Empty to WrongLocation, in the same order.
        val all = CYLPlaceholderStyle.entries
        val styles = all.subList(0, all.indexOf(CYLPlaceholderStyle.WrongLocation) + 1)
        val messageKeys = listOf("placeholder.empty", "placeholder.search", "placeholder.error", "placeholder.network")
        styles.forEach { style ->
            headers[rows.size] = CYLPlaceholderView.imageNameForStyle(style)
            messageKeys.forEach { key ->
                val title = context.cylDemoText(key)
                rows += Triple(title, null) { show(title, CYLPlaceholderView(requireContext(), style, title)) }
                icons += CYLPlaceholderView.imageForStyle(context, style)?.mutate()?.apply {
                    if (style != CYLPlaceholderStyle.Empty) setTint(Color.GRAY)
                }
            }
        }
        headers[rows.size] = context.cylDemoText("demo.custom")
        val heart = { ContextCompat.getDrawable(requireContext(), android.R.drawable.btn_star_big_on) }
        val textOnly = context.cylDemoText("demo.custom.textOnly")
        val imageOnly = context.cylDemoText("demo.custom.imageOnly")
        val both = context.cylDemoText("demo.custom.both")
        rows += Triple(textOnly, null) {
            show(textOnly, CYLPlaceholderView(requireContext(), CYLPlaceholderStyle.NoResults, requireContext().cylDemoText("demo.custom.text")))
        }
        icons += CYLPlaceholderView.imageForStyle(context, CYLPlaceholderStyle.NoResults)?.mutate()?.apply { setTint(Color.GRAY) }
        rows += Triple(imageOnly, null) {
            show(imageOnly, CYLPlaceholderView(requireContext(), heart(), requireContext().cylDemoText("placeholder.network")))
        }
        icons += heart()
        rows += Triple(both, null) { show(both, CYLPlaceholderView(requireContext(), heart(), requireContext().cylDemoText("demo.custom.text"))) }
        icons += heart()
        return context.cylMenuList(rows, icons, headers)
    }

    private fun show(title: String, placeholder: View) {
        push(CYLViewPage.newInstance(title).also { it.content = placeholder })
    }
}

/**
 * A page that shows one view under a title (the iOS detail view controllers of the menus).
 */
class CYLViewPage : CYLExamplePage() {

    /**
     * The view to show; set before the page is pushed.
     */
    var content: View? = null

    override fun pageTitle(context: Context) = requireArguments().getString("title").orEmpty()

    override fun createContent(context: Context): View = content ?: View(context)

    companion object {
        /**
         * A page titled `title`.
         */
        fun newInstance(title: String) = CYLViewPage().apply { arguments = android.os.Bundle().apply { putString("title", title) } }
    }
}

/**
 * The upstream samples, unchanged, from the projects translated in android/ (step 3).
 */
class CYLOriginalSamplesFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.getString(R.string.example_originals)

    override fun createContent(context: Context): View {
        val samples = listOf(
            Triple("MiguelCatalan/MaterialSearchView", "Default", "com.miguelcatalan.materialsearchview.sample.DefaultActivity"),
            Triple("MiguelCatalan/MaterialSearchView", "Colored", "com.miguelcatalan.materialsearchview.sample.ColoredActivity"),
            Triple("MiguelCatalan/MaterialSearchView", "Voice", "com.miguelcatalan.materialsearchview.sample.VoiceActivity"),
            Triple("MiguelCatalan/MaterialSearchView", "Sticky", "com.miguelcatalan.materialsearchview.sample.StickyActivity"),
            Triple("MiguelCatalan/MaterialSearchView", "Tabs", "com.miguelcatalan.materialsearchview.sample.TabActivity"),
            Triple("MiguelCatalan/MaterialSearchView", "Input type", "com.miguelcatalan.materialsearchview.sample.InputTypeActivity"),
            Triple("iammert/MultiSearchView", "MainActivity", "com.iammert.library.ui.multisearchview.MainActivity"),
            Triple("android-cjj/MaterialSearchView", "Reveal (reimplemented)", "com.cyl.search.reveal.CYLRevealSearchActivity"),
            Triple("yechaoa/MaterialDesign", "SearchViewActivity", "com.yechaoa.materialdesign.activity.SearchViewActivity"),
        )
        return context.cylMenuList(samples.map { (project, title, activity) ->
            Triple(title, project) { startActivity(android.content.Intent().setClassName(requireContext(), activity)) }
        } + Triple("lapism/search", "MaterialSearchBar + MaterialSearchView (library only, see the port)") { push(CYLLapismPortFragment()) })
    }
}
