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
import androidx.core.content.ContextCompat
import com.cyl.search.CYLSearchPlaceholderMessage
import com.cyl.search.CYLSearchPlaceholderStyle
import com.cyl.search.CYLSearchPlaceholderView
import com.cyl.search.CYLSearchResources

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

    override fun createContent(context: Context): View = context.cylMenuList(listOf(
        Triple(context.cylDemoText("demo.reproduction"), null) { push(CYLSearchExampleFragment()) },
        Triple(context.cylDemoText("demo.styles"), null) { push(CYLSearchPlaceholderGalleryFragment()) },
        Triple(context.cylDemoText("demo.searchBar"), null) { push(CYLSearchBarDemoFragment()) },
        Triple(context.cylDemoText("demo.ports"), null) { push(CYLSearchPortsFragment()) },
        Triple(context.getString(R.string.example_originals), context.getString(R.string.example_originals_subtitle)) { push(CYLOriginalSamplesFragment()) },
    ))
}

/**
 * Every placeholder image with each built-in message, and the custom forms (iOS
 * `CYLSearchPlaceholderGalleryViewController`).
 */
class CYLSearchPlaceholderGalleryFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.styles")

    override fun createContent(context: Context): View {
        val rows = mutableListOf<Triple<String, String?, () -> Unit>>()
        val icons = mutableListOf<Drawable?>()
        val headers = mutableMapOf<Int, String>()
        val styles = CYLSearchPlaceholderStyle.entries.filter { it != CYLSearchPlaceholderStyle.Count }
        val messageKeys = listOf("placeholder.empty", "placeholder.search", "placeholder.error", "placeholder.network")
        styles.forEach { style ->
            headers[rows.size] = CYLSearchPlaceholderView.imageNameForStyle(style)
            CYLSearchPlaceholderMessage.entries.forEachIndexed { index, message ->
                val title = context.cylDemoText(messageKeys[index])
                rows += Triple(title, null) { show(title, CYLSearchPlaceholderView(requireContext(), style, message)) }
                icons += CYLSearchResources.imageNamed(context, CYLSearchPlaceholderView.imageNameForStyle(style))?.mutate()?.apply {
                    if (style != CYLSearchPlaceholderStyle.Empty) setTint(Color.GRAY)
                }
            }
        }
        headers[rows.size] = context.cylDemoText("demo.custom")
        val heart = { ContextCompat.getDrawable(requireContext(), android.R.drawable.btn_star_big_on) }
        val textOnly = context.cylDemoText("demo.custom.textOnly")
        val imageOnly = context.cylDemoText("demo.custom.imageOnly")
        val both = context.cylDemoText("demo.custom.both")
        rows += Triple(textOnly, null) {
            show(textOnly, CYLSearchPlaceholderView(requireContext(), CYLSearchPlaceholderStyle.NoResults, requireContext().cylDemoText("demo.custom.text")))
        }
        icons += CYLSearchResources.imageNamed(context, "CYLSearchNoResults")?.mutate()?.apply { setTint(Color.GRAY) }
        rows += Triple(imageOnly, null) { show(imageOnly, CYLSearchPlaceholderView(requireContext(), heart(), CYLSearchPlaceholderMessage.Network)) }
        icons += heart()
        rows += Triple(both, null) { show(both, CYLSearchPlaceholderView(requireContext(), heart(), requireContext().cylDemoText("demo.custom.text"))) }
        icons += heart()
        return context.cylMenuList(rows, icons, headers)
    }

    private fun show(title: String, placeholder: CYLSearchPlaceholderView) {
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
