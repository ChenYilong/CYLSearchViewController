package com.cyl.search.example

import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import com.cyl.search.CYLSearchSuggestionStyle
import com.cyl.tabbar.CYLTabBarController
import com.cyl.tabbar.CYLTabBarPageRegistry

/**
 * The example app (iOS `CYLSearchExampleAppDelegate`): a `CYLTabBarController` created from
 * `assets/CYLTabBarConfiguration.json`, with a raised plus button, and pages found by page ID in
 * `CYLTabBarPageRegistry`.
 */
class MainActivity : AppCompatActivity() {

    private var controller: CYLTabBarController? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerPages(CYLTabBarPageRegistry.sharedRegistry)
        val controller = CYLTabBarController.tabBarControllerWithConfigurationFile(this, "CYLTabBarConfiguration.json")
        // `adb shell am start -n com.cyl.search.example/.MainActivity --ei CYLDemoTab 2` selects that tab, for screenshots.
        val tab = intent.getIntExtra(EXTRA_TAB, -1)
        if (tab in controller.viewControllers.indices) {
            controller.selectedIndex = tab
        }
        this.controller = controller
        setContentView(controller.view)
        // Back pops the pages pushed on the selected tab first (`cyl_pushViewController`).
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                val page = this@MainActivity.controller?.selectedViewController
                if (page != null && page.isAdded && page.childFragmentManager.backStackEntryCount > 0) {
                    page.childFragmentManager.popBackStack()
                } else {
                    finish()
                }
            }
        })
    }

    private fun registerPages(pages: CYLTabBarPageRegistry) {
        pages.registerPageProvider({ _, _ -> CYLSearchExampleFragment() }, "search")
        pages.registerPageProvider({ _, _ -> CYLSearchDemoMenuFragment() }, "examples")
        pages.registerPageProvider({ _, _ -> CYLSearchBarDemoFragment() }, "plus")
        pages.registerPageProvider({ _, _ -> CYLSuggestionStyleFragment.newInstance(CYLSearchSuggestionStyle.List) }, "listStyle")
        pages.registerPageProvider({ _, _ -> CYLSuggestionStyleFragment.newInstance(CYLSearchSuggestionStyle.Tags) }, "tagStyle")
        // The discover page copied from CollectionViewClassifyMenu (docs/tag-view-suggestions.md), as on iOS.
        pages.registerPageProvider({ _, _ -> CYLSearchDiscoverFragment() }, "discover")
    }

    companion object {
        /**
         * The intent extra that selects a tab at launch.
         */
        const val EXTRA_TAB = "CYLDemoTab"
    }
}
