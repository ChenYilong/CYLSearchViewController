// Kotlin transcription of MiguelCatalan/MaterialSearchView's sample (commit 53e163c), Apache License 2.0.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX.
package com.miguelcatalan.materialsearchview.sample

import android.content.Intent
import android.os.Bundle
import android.speech.RecognizerIntent
import android.text.TextUtils
import android.view.Menu
import androidx.activity.addCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import com.google.android.material.snackbar.Snackbar
import com.miguelcatalan.materialsearchview.MaterialSearchView

/**
 * DefaultActivity of the MaterialSearchView sample.
 *
 * @author Miguel Catalan Bañuls
 */
class DefaultActivity : AppCompatActivity() {

    private lateinit var searchView: MaterialSearchView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_default)
        setSupportActionBar(findViewById<Toolbar>(R.id.toolbar))

        searchView = findViewById(R.id.search_view)
        searchView.setVoiceSearch(false)
        searchView.setCursorDrawable(R.drawable.custom_cursor)
        searchView.setEllipsize(true)
        searchView.setSuggestions(resources.getStringArray(R.array.query_suggestions))
        searchView.setOnQueryTextListener(object : MaterialSearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String): Boolean {
                Snackbar.make(findViewById(R.id.container), "Query: $query", Snackbar.LENGTH_LONG).show()
                return false
            }

            override fun onQueryTextChange(newText: String): Boolean {
                // Do some magic
                return false
            }
        })
        searchView.setOnSearchViewListener(object : MaterialSearchView.SearchViewListener {
            override fun onSearchViewShown() {
                // Do some magic
            }

            override fun onSearchViewClosed() {
                // Do some magic
            }
        })
        // onBackPressed: the back button closes the search view first.
        onBackPressedDispatcher.addCallback(this) {
            if (searchView.isSearchOpen()) {
                searchView.closeSearch()
            } else {
                isEnabled = false
                onBackPressedDispatcher.onBackPressed()
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)
        searchView.setMenuItem(menu.findItem(R.id.action_search))
        return true
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == MaterialSearchView.REQUEST_VOICE && resultCode == RESULT_OK) {
            val matches = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            if (!matches.isNullOrEmpty()) {
                val searchWrd = matches[0]
                if (!TextUtils.isEmpty(searchWrd)) {
                    searchView.setQuery(searchWrd, false)
                }
            }
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }
}
