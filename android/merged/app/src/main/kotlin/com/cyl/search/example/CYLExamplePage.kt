package com.cyl.search.example

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.Menu
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.cyl.search.CYLSearchResources
import com.cyl.tabbar.cyl_pushViewController
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.snackbar.Snackbar

/**
 * A text of the example (the `demo.*` keys of the library's strings, imported from the iOS bundle).
 */
fun Context.cylDemoText(key: String): String = CYLSearchResources.localizedString(this, key)

/**
 * A page of the example: a toolbar (the iOS navigation bar: title, back button when pushed, actions) above the
 * page's content. The content starts below the toolbar, so no bar covers it.
 */
abstract class CYLExamplePage : Fragment() {

    /**
     * The toolbar above the content.
     */
    lateinit var toolbar: MaterialToolbar
        private set

    /**
     * The page title in the toolbar.
     */
    abstract fun pageTitle(context: Context): String

    /**
     * The content under the toolbar.
     */
    abstract fun createContent(context: Context): View

    /**
     * Adds the toolbar actions. Optional.
     */
    open fun onCreateActions(menu: Menu) {}

    /**
     * The key of this tab's search bar style (`cylTabSearchBar`). Non-null makes this a first-level page: the toolbar holds the
     * WHOLE search bar, full width, and a tap on it pushes the second-level search page while the core brings the back button in.
     * Null (default): a plain title toolbar.
     */
    open val searchStyleKey: String? = null

    /**
     * The first-level search bar in the toolbar (null without `searchStyleKey`).
     */
    var firstLevelBar: com.cyl.search.CYLSearchBarView? = null
        private set

    /**
     * A second-level search page searched `query`: the bar shows it by default.
     */
    open fun onSearchSubmitted(query: String) {
        firstLevelBar?.text = query
    }

    /**
     * Pushes the second-level search page of this tab's style.
     */
    open fun pushSearchPage() = push(CYLSearchDiscoverFragment.newInstance(searchStyleKey ?: "discover"))

    override fun onResume() {
        super.onResume()
        // Back from the second-level page: the whole bar again.
        firstLevelBar?.hideBackButton(false)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        toolbar = MaterialToolbar(context).apply {
            title = pageTitle(context)
            if (parentFragment != null) {
                navigationIcon = ContextCompat.getDrawable(context, androidx.appcompat.R.drawable.abc_ic_ab_back_material)
                setNavigationOnClickListener { parentFragmentManager.popBackStack() }
            }
            onCreateActions(menu)
        }
        searchStyleKey?.let { key ->
            toolbar.title = null
            val bar = cylTabSearchBar(context, key, {}, { firstLevelBar?.performFirstLevelTap() })
            bar.embedInToolbar(toolbar)
            bar.onFirstLevelTap = { pushSearchPage() }
            firstLevelBar = bar
            // The second-level page popped: the first-level bar is whole again (it showed the back button when it pushed).
            childFragmentManager.addOnBackStackChangedListener { if (childFragmentManager.backStackEntryCount == 0) bar.hideBackButton(false) }
            childFragmentManager.setFragmentResultListener(CYL_SEARCH_RESULT, this) { _, result ->
                result.getString(CYL_SEARCH_RESULT)?.let { onSearchSubmitted(it) }
            }
        }
        val column = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(toolbar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(createContent(context), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        }
        // A gradient page (docs/instructions/example-demos.md rule 7) on a SIBLING plate behind the content, never the background
        // of an ancestor of the lists: every tag list's `backdropSource` is the plate, so the glass blurs and refracts it.
        val plate = cylBackdropPlate(context)
        // An opaque page with an ID: pushed pages cover the one below and are added to the tab's root view.
        return FrameLayout(context).apply {
            id = View.generateViewId()
            isClickable = true
            addView(plate, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            addView(column, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            cylSetBackdropSource(column, plate)
        }
    }

    /**
     * Pushes `page` on this tab (iOS `pushViewController`), with CYLTabBarController's `cyl_pushViewController`.
     */
    fun push(page: Fragment) {
        var root: Fragment = this
        while (root.parentFragment != null) {
            root = root.parentFragment!!
        }
        root.cyl_pushViewController(page)
    }

    /**
     * A short message at the bottom of the page (iOS `CYLSnackbar`).
     */
    fun snackbar(text: String) {
        view?.let { Snackbar.make(it, text, Snackbar.LENGTH_LONG).show() }
    }
}

/**
 * The gradient behind every example page (example-demos.md rule 7): the list on top draws no background, so the gradient shows
 * through and the Liquid Glass tags have something to blur and refract. Light: blue to pink to orange; dark: indigo to purple to teal.
 */
internal fun cylGradientPageBackground(context: Context): android.graphics.drawable.Drawable {
    val night = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
        android.content.res.Configuration.UI_MODE_NIGHT_YES
    val colors = if (night) {
        intArrayOf(0xFF1B1F5E.toInt(), 0xFF5B2A86.toInt(), 0xFF0F6E7A.toInt())
    } else {
        intArrayOf(0xFF7FB7FF.toInt(), 0xFFFF9EC7.toInt(), 0xFFFFC27A.toInt())
    }
    return android.graphics.drawable.GradientDrawable(android.graphics.drawable.GradientDrawable.Orientation.TL_BR, colors)
}
