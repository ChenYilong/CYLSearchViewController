package com.cyl.search.example

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.cyl.tabbar.CYLConstants
import com.cyl.tabbar.CYLTabBarController

/**
 * The example app: CYLTabBarController's tab bar with one tab per example (docs/android-and-cross-platform.md).
 */
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val tabs = ExampleTabs.all(this)
        val controller = CYLTabBarController(this, tabs.map { it.fragment() }, tabs.map {
            mapOf(CYLConstants.CYLTabBarItemTitle to it.title, CYLConstants.CYLTabBarItemImage to "tab_search")
        })
        setContentView(controller.view)
    }
}
