package com.cyl.search.example

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.speech.RecognizerIntent
import android.view.Gravity
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.ArrayAdapter
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ListView
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.cyl.search.CYLLineBreakMode
import com.cyl.search.CYLMultiSearchView
import com.cyl.search.CYLMultiSearchViewDelegate
import com.cyl.search.CYLSearchBarExpansionAnimation
import com.cyl.search.CYLSearchBarIconPosition
import com.cyl.search.CYLSearchBarNavigationIcon
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.CYLSearchView
import com.cyl.search.CYLSearchViewDelegate
import com.cyl.search.CYLTextAutocapitalizationType
import com.cyl.search.R as SearchR
import com.google.android.material.tabs.TabLayout

/**
 * The ports of the examples of five search libraries (iOS `CYLSearchPortsViewController`). Each port only passes
 * data and style parameters to `cylsearch` and handles taps.
 */
class CYLSearchPortsFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.ports")

    override fun createContent(context: Context): View = context.cylMenuList(listOf(
        Triple("lapism/search", "MaterialSearchBar + MaterialSearchView") { push(CYLLapismPortFragment()) },
        Triple("MiguelCatalan/MaterialSearchView", "Default, Themed, Voice, Sticky, Tabs, Input type") { push(CYLMaterialSearchMenuFragment()) },
        Triple("yechaoa/MaterialDesign", "SearchViewActivity") { push(CYLYechaoaPortFragment()) },
        Triple("android-cjj/MaterialSearchView", "Circular reveal") { push(CYLRevealPortFragment()) },
        Triple("iammert/MultiSearchView", "MultiSearchView") { push(CYLMultiSearchPortFragment()) },
    ))
}

private fun Context.items(count: Int) = (1..count).map { getString(SearchR.string.cyl_demo_port_item, it) }

/**
 * lapism/search (iOS `CYLLapismSearchViewController`): a search bar that opens a search view with a results list.
 */
class CYLLapismPortFragment : CYLExamplePage(), CYLSearchBarViewDelegate, CYLSearchViewDelegate {

    private lateinit var searchBar: CYLSearchBarView
    private lateinit var searchView: CYLSearchView
    private lateinit var results: ArrayAdapter<String>
    private lateinit var items: List<String>

    override fun pageTitle(context: Context) = "lapism/search"

    override fun createContent(context: Context): View {
        items = context.items(40)
        // MaterialSearchBar: navigationIconCompat = SEARCH, setHint, setOnClickListener / setNavigationOnClickListener.
        searchBar = CYLSearchBarView(context).apply {
            navigationIcon = CYLSearchBarNavigationIcon.Search
            searchIcon = null
            placeholder = context.cylDemoText("search.field")
            fieldShadowOpacity = 0.15f
            fieldBackgroundColor = Color.rgb(242, 242, 247)
            delegate = this@CYLLapismPortFragment
            navigationHandler = { searchView.showSearch() }
        }
        val list = ListView(context).apply { adapter = ArrayAdapter(context, android.R.layout.simple_list_item_1, items) }
        val page = FrameLayout(context)
        page.addView(LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(searchBar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        })
        // MaterialSearchView: addView(recyclerView), navigationIconCompat = ARROW, setHint, listeners.
        results = ArrayAdapter(context, android.R.layout.simple_list_item_1, items.toMutableList())
        searchView = CYLSearchView(context).apply {
            contentView = ListView(context).apply { adapter = results }
            searchBarView.navigationIcon = CYLSearchBarNavigationIcon.Arrow
            searchBarView.searchIcon = null
            searchBarView.placeholder = context.cylDemoText("search.field")
            delegate = this@CYLLapismPortFragment
        }
        searchView.installInView(page)
        return page
    }

    override fun searchBarViewShouldBeginEditing(searchBarView: CYLSearchBarView) = false

    override fun searchBarViewDidTapWhileNotEditable(searchBarView: CYLSearchBarView) = searchView.showSearch()

    override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {
        results.clear()
        results.addAll(if (text.isEmpty()) items else items.filter { it.contains(text, ignoreCase = true) })
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String) = true

    override fun searchViewDidChangeFocus(searchView: CYLSearchView, focused: Boolean) {
        searchBar.text = searchView.query
    }
}

/**
 * MiguelCatalan/MaterialSearchView's six samples (iOS `CYLMaterialSearchMenuViewController`).
 */
class CYLMaterialSearchMenuFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = "MaterialSearchView"

    override fun createContent(context: Context): View = context.cylMenuList(CYLMaterialSearchSample.entries.map { sample ->
        Triple(context.cylDemoText(sample.titleKey), null) { push(CYLMaterialSearchSampleFragment.newInstance(sample)) }
    })
}

/**
 * The samples of MaterialSearchView.
 */
enum class CYLMaterialSearchSample(val titleKey: String) {
    Standard("demo.port.default"),
    Themed("demo.port.themed"),
    Voice("demo.port.voice"),
    Sticky("demo.port.sticky"),
    Tabs("demo.port.tab"),
    InputType("demo.port.inputType"),
}

/**
 * One MaterialSearchView sample (iOS `CYLMaterialSearchSampleViewController`): a toolbar search action that opens a
 * `CYLSearchView` with the sample's suggestions and style.
 */
class CYLMaterialSearchSampleFragment : CYLExamplePage(), CYLSearchViewDelegate {

    private lateinit var searchView: CYLSearchView
    private val sample get() = CYLMaterialSearchSample.valueOf(requireArguments().getString("sample")!!)
    private val voice = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        searchView.searchBarView.placeholder = null
        val text = result.data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
        if (result.resultCode == Activity.RESULT_OK && !text.isNullOrEmpty()) {
            // REQUEST_VOICE + onActivityResult: the first result becomes the query, without submitting it.
            searchView.setQuery(text, false)
        }
    }

    override fun pageTitle(context: Context) = context.cylDemoText(sample.titleKey)

    override fun onCreateActions(menu: Menu) {
        menu.add(requireContext().cylDemoText("demo.port.open")).apply {
            icon = ContextCompat.getDrawable(requireContext(), SearchR.drawable.cyl_search_ic_search)
            setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
            searchItem = this
        }
    }

    private var searchItem: MenuItem? = null

    override fun createContent(context: Context): View {
        val page = FrameLayout(context)
        page.addView(content(context))
        val themed = sample == CYLMaterialSearchSample.Themed || sample == CYLMaterialSearchSample.Voice
        // searchView.setVoiceSearch, setCursorDrawable, setEllipsize, setSuggestions and the two listeners.
        searchView = CYLSearchView(context).apply {
            searchBarView.showsVoiceButton = sample == CYLMaterialSearchSample.Voice
            searchBarView.cursorColor = if (themed) Color.WHITE else Color.rgb(255, 45, 85)
            suggestionLineBreakMode = if (sample == CYLMaterialSearchSample.Standard || sample == CYLMaterialSearchSample.InputType) {
                CYLLineBreakMode.TruncatingTail
            } else {
                CYLLineBreakMode.WordWrapping
            }
            suggestions = if (sample == CYLMaterialSearchSample.Sticky) emptyList() else SUGGESTIONS
            searchBarView.isSecureTextEntry = sample == CYLMaterialSearchSample.InputType
            // A query that matches nothing shows CYLTableViewPlaceHolder's "no search results" state (docs/sub-repositories.md).
            showsEmptyResultsPlaceholder = true
            // Submitted queries are cached in the core's local database (docs/core-todo.md), one cache for these samples.
            suggestionCachePolicy = com.cyl.search.CYLSearchSuggestionCachePolicy.Database
            suggestionCacheName = "MaterialSearchView"
            if (themed) {
                // The colored theme: white text on the primary color.
                setBackgroundColor(Color.rgb(88, 86, 214))
                searchBarView.textColor = Color.WHITE
                searchBarView.placeholderColor = Color.argb(179, 255, 255, 255)
                searchBarView.searchIconTintColor = Color.WHITE
                suggestionTextColor = Color.WHITE
                suggestionImageTintColor = Color.argb(204, 255, 255, 255)
                dividerColor = Color.argb(77, 255, 255, 255)
            }
            delegate = this@CYLMaterialSearchSampleFragment
        }
        searchView.installInView(page)
        // The whole search bar takes the toolbar's place (as MaterialSearchView opens over the toolbar): the toolbar
        // hides first, so the search view, which fills the page, puts its bar where the toolbar was; nothing is covered.
        searchItem?.setOnMenuItemClickListener {
            toolbar.visibility = View.GONE
            searchView.showSearch()
            true
        }
        return page
    }

    private fun content(context: Context): View {
        val label = TextView(context).apply {
            text = context.cylDemoText(sample.titleKey)
            textSize = 22f
            gravity = Gravity.CENTER
        }
        return when (sample) {
            // StickyActivity: a long list scrolls under the toolbar.
            CYLMaterialSearchSample.Sticky -> ScrollView(context).apply {
                addView(TextView(context).apply {
                    text = context.items(60).joinToString("\n\n")
                    textSize = 17f
                    val padding = (16 * resources.displayMetrics.density).toInt()
                    setPadding(padding, padding, padding, padding)
                })
            }
            // TabActivity: three pages under tabs.
            CYLMaterialSearchSample.Tabs -> LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                val pages = (1..3).map { context.getString(SearchR.string.cyl_demo_port_page, it) }
                label.text = pages[0]
                addView(TabLayout(context).apply {
                    pages.forEach { addTab(newTab().setText(it)) }
                    addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
                        override fun onTabSelected(tab: TabLayout.Tab) {
                            label.text = tab.text
                        }
                        override fun onTabUnselected(tab: TabLayout.Tab) = Unit
                        override fun onTabReselected(tab: TabLayout.Tab) = Unit
                    })
                })
                addView(label, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
            }
            else -> label
        }
    }

    override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean {
        snackbar(requireContext().getString(SearchR.string.cyl_demo_port_query, text))
        return false
    }

    override fun searchViewDidClose(searchView: CYLSearchView) {
        toolbar.visibility = View.VISIBLE
    }

    override fun searchViewVoiceButtonClicked(searchView: CYLSearchView) {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
            .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        if (intent.resolveActivity(requireContext().packageManager) == null) {
            snackbar(requireContext().cylDemoText("demo.port.voiceUnavailable"))
            return
        }
        searchView.searchBarView.placeholder = requireContext().cylDemoText("demo.port.listening")
        voice.launch(intent)
    }

    companion object {
        /**
         * The suggestions of the sample (MaterialSearchView `R.array.query_suggestions`).
         */
        val SUGGESTIONS = listOf(
            "A very very long suggestion that would span multiple lines.", "Android", "iOS", "SCALA", "Ruby",
            "JavaScript", "C#", "Python", "C", "C++", "PHP", "Go", "Perl", "Bash", "Lua", "R", "TCL", "Haskell",
            "Objective C", "Swift", "Kotlin", "jQuery", "Development", "Web", "Ajax", "Test", "Testing", "CookBook",
            "Beagle", "VMware", "Less.js", "IDE", "Arduino", "Xamarin", "UI", "Microsoft", "Application", "Development",
            "JUnit", "SQL", "Beagle",
        )

        /**
         * The page of `sample`.
         */
        fun newInstance(sample: CYLMaterialSearchSample) = CYLMaterialSearchSampleFragment().apply {
            arguments = android.os.Bundle().apply { putString("sample", sample.name) }
        }
    }
}

/**
 * yechaoa/MaterialDesign's SearchViewActivity (iOS `CYLYechaoaSearchViewController`): an iconified search bar in the
 * toolbar that opens over the title; a submitted query shows a pretend result.
 */
class CYLYechaoaPortFragment : CYLExamplePage(), CYLSearchBarViewDelegate {

    private lateinit var resultLabel: TextView
    private lateinit var searchBar: CYLSearchBarView

    override fun pageTitle(context: Context) = "SearchView"

    override fun createContent(context: Context): View {
        // setIconifiedByDefault(true), isSubmitButtonEnabled, imeOptions, isIconified, queryHint, text colors.
        searchBar = CYLSearchBarView(context).apply {
            contentInsets = Rect(0, 0, 0, 0)
            iconifiedByDefault = true
            showsSubmitButton = true
            returnKeyType = EditorInfo.IME_ACTION_SEARCH
            placeholder = context.cylDemoText("demo.port.keyword")
            placeholderColor = Color.rgb(0xDC, 0xDC, 0xDC)
            delegate = this@CYLYechaoaPortFragment
            setIconified(true, false)
        }
        toolbar.addView(searchBar, androidx.appcompat.widget.Toolbar.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.END))
        resultLabel = TextView(context).apply {
            text = context.cylDemoText("demo.port.result")
            textSize = 22f
            gravity = Gravity.CENTER
            visibility = View.INVISIBLE
        }
        return resultLabel
    }

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        snackbar(requireContext().getString(SearchR.string.cyl_demo_port_searched, searchBarView.text.orEmpty()))
        resultLabel.visibility = View.VISIBLE
    }

    override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {
        if (text.isEmpty()) resultLabel.visibility = View.INVISIBLE
    }

    override fun searchBarViewDidChangeIconified(searchBarView: CYLSearchBarView, iconified: Boolean) {
        // The opened field takes the room of the title, like an expanded SearchView in the toolbar.
        searchBar.layoutParams = searchBar.layoutParams.apply {
            width = if (iconified) ViewGroup.LayoutParams.WRAP_CONTENT else ViewGroup.LayoutParams.MATCH_PARENT
        }
        toolbar.title = if (iconified) "SearchView" else null
    }
}

/**
 * android-cjj/MaterialSearchView (iOS `CYLRevealSearchViewController`): a floating search button that reveals a
 * search card with a circular reveal.
 */
class CYLRevealPortFragment : CYLExamplePage() {

    private lateinit var searchBar: CYLSearchBarView

    override fun pageTitle(context: Context) = "MaterialSearchView (cjj)"

    override fun createContent(context: Context): View {
        val density = context.resources.displayMetrics.density
        // CardView: background #f2f2f2, corner radius 2; EditText: hint "search". Readable dark text (upstream issue #4).
        searchBar = CYLSearchBarView(context).apply {
            fieldBackgroundColor = Color.rgb(0xF2, 0xF2, 0xF2)
            fieldCornerRadius = 2f
            fieldHeight = 60f
            fieldShadowOpacity = 0.2f
            placeholder = "search"
            textColor = Color.rgb(0x21, 0x21, 0x21)
            searchIcon = null
            // The magnifier inside the card closes it (mAnimator.reverse()).
            trailingAccessoryViews = listOf(ImageButton(context).apply {
                setImageDrawable(ContextCompat.getDrawable(context, SearchR.drawable.cyl_search_ic_search))
                background = null
                contentDescription = context.cylDemoText("search.field")
                setOnClickListener { searchBar.setIconified(true, true) }
            })
            // The floating action button and the reveal (ViewAnimationUtils.createCircularReveal, 1000 ms).
            expansionAnimation = CYLSearchBarExpansionAnimation.CircularReveal
            animationDuration = 1.0
            iconButton.background = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(Color.WHITE) }
            iconButton.elevation = 6 * density
            iconPosition = CYLSearchBarIconPosition.Center
            iconifiedByDefault = true
            // The button's own magnifier (iOS sets iconButton's image directly; searchIcon is null above).
            iconButton.setImageDrawable(ContextCompat.getDrawable(context, SearchR.drawable.cyl_search_ic_search))
            iconButton.imageTintList = android.content.res.ColorStateList.valueOf(Color.rgb(88, 86, 214))
        }
        return FrameLayout(context).apply {
            setBackgroundColor(Color.rgb(88, 86, 214))
            addView(searchBar, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL).apply {
                val margin = (4 * density).toInt()
                setMargins(margin, 0, margin, 0)
            })
        }
    }
}

/**
 * iammert/MultiSearchView (iOS `CYLMultiSearchDemoViewController`): several searches side by side, with an event log.
 */
class CYLMultiSearchPortFragment : CYLExamplePage(), CYLMultiSearchViewDelegate {

    private lateinit var logView: TextView

    override fun pageTitle(context: Context) = "MultiSearchView"

    override fun createContent(context: Context): View {
        val density = context.resources.displayMetrics.density
        val multiSearchView = CYLMultiSearchView(context).apply {
            placeholder = context.cylDemoText("search.field")
            fontSize = 18f
            maximumTextLength = 15
            autocapitalizationType = CYLTextAutocapitalizationType.Sentences
            returnKeyType = EditorInfo.IME_ACTION_SEARCH
            placeholderColor = Color.argb(0x80, 0x99, 0x99, 0x99)
            delegate = this@CYLMultiSearchPortFragment
        }
        logView = TextView(context).apply {
            typeface = Typeface.MONOSPACE
            textSize = 13f
            contentDescription = context.cylDemoText("demo.port.events")
        }
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            val margin = (16 * density).toInt()
            addView(multiSearchView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                setMargins((8 * density).toInt(), margin, (8 * density).toInt(), 0)
            })
            addView(ScrollView(context).apply { addView(logView) }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f).apply {
                setMargins(margin, margin, margin, 0)
            })
        }
    }

    private fun log(line: String) {
        logView.text = line + "\n" + logView.text
    }

    override fun multiSearchViewDidSelectItem(multiSearchView: CYLMultiSearchView, text: String, index: Int) =
        log("onItemSelected: index: $index, query: $text")

    override fun multiSearchViewTextDidChange(multiSearchView: CYLMultiSearchView, text: String, index: Int) =
        log("changed: index: $index, query: $text")

    override fun multiSearchViewDidCompleteSearch(multiSearchView: CYLMultiSearchView, text: String, index: Int) =
        log("complete: index: $index, query: $text")

    override fun multiSearchViewDidRemoveItemAtIndex(multiSearchView: CYLMultiSearchView, index: Int) = log("remove: index: $index")
}
