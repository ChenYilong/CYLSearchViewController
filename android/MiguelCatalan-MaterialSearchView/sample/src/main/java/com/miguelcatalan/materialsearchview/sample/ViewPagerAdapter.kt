// Kotlin transcription of MiguelCatalan/MaterialSearchView's sample (commit 53e163c), Apache License 2.0.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX.
package com.miguelcatalan.materialsearchview.sample

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter

/**
 * The two pages of TabActivity.
 *
 * @author Miguel Catalan Bañuls
 */
@Suppress("DEPRECATION")
internal class ViewPagerAdapter(manager: FragmentManager) : FragmentPagerAdapter(manager) {
    private val mFragmentList = ArrayList<Fragment>()
    private val mFragmentTitleList = ArrayList<String>()

    override fun getItem(position: Int): Fragment = mFragmentList[position]

    override fun getCount(): Int = mFragmentList.size

    fun addFragment(fragment: Fragment, title: String) {
        mFragmentList.add(fragment)
        mFragmentTitleList.add(title)
    }

    override fun getPageTitle(position: Int): CharSequence = mFragmentTitleList[position]
}
