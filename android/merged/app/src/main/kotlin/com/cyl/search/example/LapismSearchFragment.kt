package com.cyl.search.example

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import android.widget.ListView
import androidx.fragment.app.Fragment
import com.lapism.search.widget.MaterialSearchBar
import com.lapism.search.widget.MaterialSearchView
import com.lapism.search.widget.NavigationIconCompat

/**
 * lapism/search: its README usage (search bar, and a search view that opens with the results list).
 */
class LapismSearchFragment : Fragment() {

    private val items = listOf("Android", "Kotlin", "Material", "Search", "Swift", "iOS", "CYLTabBarController")

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val root = FrameLayout(context)
        val bar = MaterialSearchBar(context)
        val searchView = MaterialSearchView(context)
        val adapter = ArrayAdapter(context, android.R.layout.simple_list_item_1, items.toMutableList())
        val list = ListView(context).apply { this.adapter = adapter }
        bar.apply {
            navigationIconCompat = NavigationIconCompat.SEARCH
            setHint("Search")
            setOnClickListener { searchView.requestFocus() }
            setNavigationOnClickListener { searchView.requestFocus() }
        }
        searchView.apply {
            addView(list)
            navigationIconCompat = NavigationIconCompat.ARROW
            setNavigationOnClickListener { searchView.clearFocus() }
            setHint("Search")
            setOnQueryTextListener(object : MaterialSearchView.OnQueryTextListener {
                override fun onQueryTextChange(newText: CharSequence) {
                    adapter.clear()
                    adapter.addAll(items.filter { it.contains(newText, ignoreCase = true) })
                }

                override fun onQueryTextSubmit(query: CharSequence) {
                    searchView.clearFocus()
                }
            })
        }
        root.addView(bar, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        root.addView(searchView, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        return root
    }
}
