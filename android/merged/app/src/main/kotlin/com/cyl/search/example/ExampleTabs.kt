package com.cyl.search.example

import android.content.Context
import androidx.fragment.app.Fragment
import com.cyl.search.reveal.CYLRevealSearchActivity
import com.miguelcatalan.materialsearchview.sample.ColoredActivity
import com.miguelcatalan.materialsearchview.sample.DefaultActivity
import com.miguelcatalan.materialsearchview.sample.InputTypeActivity
import com.miguelcatalan.materialsearchview.sample.StickyActivity
import com.miguelcatalan.materialsearchview.sample.TabActivity
import com.miguelcatalan.materialsearchview.sample.VoiceActivity
import com.yechaoa.materialdesign.activity.SearchViewActivity
import com.iammert.library.ui.multisearchview.MainActivity as MultiSearchActivity

/**
 * One tab per example: the five upstream projects translated in android/ (their samples, unchanged).
 */
class ExampleTab(val title: String, val fragment: () -> Fragment)

object ExampleTabs {

    fun all(@Suppress("UNUSED_PARAMETER") context: Context): List<ExampleTab> = listOf(
        ExampleTab("lapism") { LapismSearchFragment() },
        ExampleTab("Material") {
            LauncherFragment.newInstance(
                "MiguelCatalan/MaterialSearchView",
                listOf(
                    "Default" to DefaultActivity::class.java,
                    "Colored" to ColoredActivity::class.java,
                    "Voice" to VoiceActivity::class.java,
                    "Sticky suggestions" to StickyActivity::class.java,
                    "Tabs" to TabActivity::class.java,
                    "Input type" to InputTypeActivity::class.java,
                ),
            )
        },
        ExampleTab("Multi") {
            LauncherFragment.newInstance("iammert/MultiSearchView", listOf("MultiSearchView" to MultiSearchActivity::class.java))
        },
        ExampleTab("Reveal") {
            LauncherFragment.newInstance("android-cjj/MaterialSearchView (reimplemented)", listOf("Reveal search" to CYLRevealSearchActivity::class.java))
        },
        ExampleTab("yechaoa") {
            LauncherFragment.newInstance("yechaoa/MaterialDesign", listOf("SearchView" to SearchViewActivity::class.java))
        },
    )
}
