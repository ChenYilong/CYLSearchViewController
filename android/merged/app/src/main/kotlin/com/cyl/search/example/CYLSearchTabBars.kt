package com.cyl.search.example

import android.content.Context
import android.graphics.Color
import android.graphics.Rect
import com.cyl.search.CYLSearchBarItem
import com.cyl.search.CYLSearchBarStyle
import com.cyl.search.CYLSearchBarView

/**
 * The key of the fragment result a second-level search page sends to the first-level page below it (the query).
 */
const val CYL_SEARCH_RESULT = "cylSearchQuery"

/**
 * A second-level page the back gesture drives (predictive back): the first-level bar's back button and width follow the gesture,
 * `MainActivity` forwards it. `progress` runs 0 to 1.
 */
interface CYLInteractiveBack {
    fun backProgress(progress: Float)
    fun backCancelled()
    fun backCommitted()
}

/**
 * The search bar of the tab `key`, one style per tab (the tab bar controller owns the tabs, each tab root owns its bar): the same
 * bar is the whole bar of the first-level page and, after the push, of the second-level page, so the transition is continuous.
 * Keys: `discover` (the reference recording: Discover look, camera and the round default search button inside the capsule), `search` (Discover look,
 * Search button), `examples` (bordered, small radius), `list` (bordered pill with the magnifier), `tag` (plain gray, centered
 * placeholder). The page only calls this; it sets no width.
 */
fun cylTabSearchBar(context: Context, key: String, onCamera: () -> Unit, onSearch: () -> Unit): CYLSearchBarView {
    val bar = CYLSearchBarView(context)
    bar.contentInsets = Rect(16, 6, 16, 6)
    when (key) {
        "discover" -> {
            bar.applyNavigationFieldStyle()
            bar.fieldHeight = 46f
            val camera = CYLSearchBarItem.iconItem(context.getDrawable(R.drawable.cyl_ic_camera), context.getString(R.string.cyl_discover_imageSearch)) { onCamera() }
            camera.imageSize = android.util.SizeF(22f, 22f)
            // The camera button plays search_camera.json, the same Lottie file on every platform.
            camera.animationURL = android.net.Uri.parse("file:///android_asset/search_camera.json")
            bar.addItem(camera)
        }
        "search" -> {
            bar.applyNavigationFieldStyle()
            bar.fieldHeight = 40f
        }
        "examples" -> {
            bar.searchBarStyle = CYLSearchBarStyle.Bordered
            bar.fieldCornerRadius = 6f
            bar.fieldHeight = 40f
        }
        "list" -> {
            bar.searchBarStyle = CYLSearchBarStyle.Bordered
            bar.fieldHeight = 44f
        }
        else -> {
            bar.searchBarStyle = CYLSearchBarStyle.Plain
            bar.fieldCornerRadius = 12f
            bar.fieldBackgroundColor = Color.argb(40, 120, 120, 128)
            bar.centersPlaceholder = true
            bar.fieldHeight = 40f
        }
    }
    bar.placeholder = context.getString(R.string.cyl_discover_search)
    // The core's default search button (after the field and the camera, with its own divider); a tap goes to the page.
    bar.searchButtonHandler = { onSearch() }
    bar.searchButtonItem.itemAccessibilityIdentifier = "CYLSearchDiscoverSearchButton"
    return bar
}

/**
 * The Discover tab's first-level page: the whole Discover bar in the navigation bar (the reference recording); a tap pushes
 * `CYLSearchDiscoverFragment` (recent and popular tag lists) with the back button sliding in.
 */
class CYLSearchDiscoverHomeFragment : CYLExamplePage() {

    override val searchStyleKey: String? = "discover"

    override fun pageTitle(context: Context) = context.getString(R.string.cyl_discover_search)

    override fun createContent(context: Context): android.view.View = android.widget.TextView(context).apply {
        text = context.getString(R.string.cyl_discover_title)
        textSize = 17f
        gravity = android.view.Gravity.CENTER
    }
}
