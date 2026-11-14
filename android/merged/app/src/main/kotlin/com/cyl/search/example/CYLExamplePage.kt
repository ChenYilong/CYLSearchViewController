package com.cyl.search.example

import android.content.Context
import android.os.Bundle
import android.util.TypedValue
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
        val column = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(toolbar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(createContent(context), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        }
        // An opaque page with an ID: pushed pages cover the one below and are added to the tab's root view.
        return FrameLayout(context).apply {
            id = View.generateViewId()
            isClickable = true
            setBackgroundColor(TypedValue().let {
                context.theme.resolveAttribute(android.R.attr.colorBackground, it, true)
                it.data
            })
            addView(column, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
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
