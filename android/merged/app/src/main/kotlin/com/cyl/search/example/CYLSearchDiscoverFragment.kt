package com.cyl.search.example

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.CYLBadgeDrawable
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagListView
import com.cyl.search.CYLSearchBarItem
import com.cyl.search.CYLSearchBarStyle
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import org.json.JSONObject
import java.util.Locale

/**
 * One discover topic: a title and an optional icon after it ("hot" for the localized hot icon).
 */
data class CYLDiscoverTopic(val title: String, val icon: String?)

/**
 * The data of the discover demo, from `assets/CYLSearchDiscover.bundle/<language>.lproj/search-discover.json` (the
 * same files as iOS): recent searches, and a pool of topics from which the More button picks another selection.
 */
class CYLSearchDiscoverData(val discoverCount: Int, val recentSearches: List<String>, val discover: List<CYLDiscoverTopic>) {

    /**
     * The first `discoverCount` topics, so the first screen is always the same.
     */
    val initialTopics: List<CYLDiscoverTopic> get() = discover.take(maxOf(0, discoverCount))

    /**
     * Another random selection of `discoverCount` topics, preferring topics that are not shown now.
     */
    fun randomTopics(current: List<CYLDiscoverTopic>, random: kotlin.random.Random = kotlin.random.Random.Default): List<CYLDiscoverTopic> {
        val count = minOf(maxOf(0, discoverCount), discover.size)
        val picked = discover.filter { it !in current }.shuffled(random).take(count).toMutableList()
        if (picked.size < count) {
            picked += discover.filter { it !in picked }.shuffled(random).take(count - picked.size)
        }
        return picked
    }

    companion object {
        /**
         * The `.lproj` folder of the app's language: zh-Hans, zh-Hant, ja, else en.
         */
        fun languageFolder(locale: Locale = Locale.getDefault()): String = when {
            locale.language == "zh" && (locale.script == "Hant" || locale.country in listOf("TW", "HK", "MO")) -> "zh-Hant.lproj"
            locale.language == "zh" -> "zh-Hans.lproj"
            locale.language == "ja" -> "ja.lproj"
            else -> "en.lproj"
        }

        /**
         * Reads the file of the app's language, or an empty set when it cannot be read.
         */
        fun bundled(context: Context): CYLSearchDiscoverData = try {
            val text = context.assets.open("CYLSearchDiscover.bundle/${languageFolder()}/search-discover.json").bufferedReader().use { it.readText() }
            val json = JSONObject(text)
            val recent = json.getJSONArray("recentSearches").let { array -> (0 until array.length()).map { array.getString(it) } }
            val topics = json.getJSONArray("discover").let { array ->
                (0 until array.length()).map { array.getJSONObject(it) }.map { CYLDiscoverTopic(it.getString("title"), it.optString("icon").ifEmpty { null }) }
            }
            CYLSearchDiscoverData(json.optInt("discoverCount", 6), recent, topics)
        } catch (error: Exception) {
            CYLSearchDiscoverData(6, emptyList(), emptyList())
        }

        /**
         * The hot icon of the app's language (3x image), labelled for TalkBack by the caller.
         */
        fun hotIcon(context: Context): Drawable? = try {
            context.assets.open("CYLSearchDiscover.bundle/${languageFolder()}/discover-hot@3x.png").use { stream ->
                // A 3x image: 480 dpi, so it shows at its point size. CYLBadgeDrawable is drawn in its own colors (not
                // tinted like a tag icon) and gives TalkBack its label.
                val bitmap = android.graphics.BitmapFactory.decodeStream(stream).apply { density = 480 }
                CYLBadgeDrawable(context.resources, bitmap, context.getString(R.string.cyl_discover_hot))
            }
        } catch (error: Exception) {
            null
        }
    }
}

/**
 * The search history and discover page (iOS `CYLSearchDiscoverViewController`, copied from CollectionViewClassifyMenu):
 * "Recent searches" is a `CYLTagListView` folded to two rows with the chevron as the last tag and a trash button;
 * "Discover" is a grid of two titles per row with a hot icon and the More button that refreshes the topics; the search
 * bar (camera and Search inside the field) replaces the toolbar; "hold to ask" at the bottom.
 */
class CYLSearchDiscoverFragment : Fragment(), CYLMenuDelegate, CYLSearchBarViewDelegate {

    private lateinit var data: CYLSearchDiscoverData
    private val recentSource = RecentSource()
    private val discoverSource = DiscoverSource()
    private lateinit var searchBar: CYLSearchBarView
    private lateinit var recentList: CYLTagListView
    private lateinit var discoverList: CYLTagListView
    private lateinit var hintLabel: TextView

    private inner class RecentSource : CYLMenuDataSource {
        var searches: MutableList<String> = mutableListOf()
        lateinit var clearButton: ImageButton

        override fun numberOfSectionsInMenu() = if (searches.isEmpty()) 0 else 1
        override fun menuNumberOfItemsInSection(section: Int) = searches.size
        override fun menuTitleForSection(section: Int) = getString(R.string.cyl_discover_recent)
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = searches[indexPath.item]
        override fun menuAccessoryViewForSection(section: Int): View = clearButton
        override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath) = getString(R.string.cyl_discover_tapToSearch)
    }

    private inner class DiscoverSource : CYLMenuDataSource {
        var topics: List<CYLDiscoverTopic> = emptyList()

        override fun numberOfSectionsInMenu() = 1
        override fun menuNumberOfItemsInSection(section: Int) = topics.size
        override fun menuTitleForSection(section: Int) = getString(R.string.cyl_discover_title)
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = topics[indexPath.item].title
        override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? =
            if (topics[indexPath.item].icon == "hot") CYLSearchDiscoverData.hotIcon(requireContext()) else null
        override fun menuAccessibilityHintForItemAtIndexPath(indexPath: CYLIndexPath) = getString(R.string.cyl_discover_tapToSearch)
        override fun menuShowsMoreButtonInSection(section: Int) = true
        override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = getString(R.string.cyl_discover_refresh)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val density = resources.displayMetrics.density
        fun dp(value: Float) = (value * density).toInt()
        data = CYLSearchDiscoverData.bundled(context)
        recentSource.searches = data.recentSearches.toMutableList()
        discoverSource.topics = data.initialTopics
        val primary = themeColor(context, android.R.attr.textColorPrimary)
        val secondary = themeColor(context, android.R.attr.textColorSecondary)

        // A white capsule with a soft shadow, no magnifier: the camera and the Search button sit inside it.
        searchBar = CYLSearchBarView(context).apply {
            delegate = this@CYLSearchDiscoverFragment
            searchIcon = null
            contentInsets = android.graphics.Rect(0, 0, 0, 0)
            fieldHeight = 46f
            searchBarStyle = CYLSearchBarStyle.Bordered
            fieldCornerRadius = 22f
            fieldBackgroundColor = Color.WHITE
            fieldBorderColor = Color.argb(40, 0, 0, 0)
            fieldBorderWidth = 1f
            fieldShadowOpacity = 0.06f
            fontSize = 16f
            textField.contentDescription = getString(R.string.cyl_discover_search)
        }
        // The field stays; the camera, a divider and the Search button are items appended to the bar.
        val camera = CYLSearchBarItem.iconItem(context.getDrawable(R.drawable.cyl_ic_camera), getString(R.string.cyl_discover_imageSearch)) {
            searchByImage()
        }
        camera.imageSize = android.util.SizeF(22f, 22f)
        val search = CYLSearchBarItem.textItem(getString(R.string.cyl_discover_search)) { searchTapped() }
        search.itemAccessibilityIdentifier = "CYLSearchDiscoverSearchButton"
        searchBar.itemTintColor = primary
        searchBar.addItem(camera)
        searchBar.addItem(CYLSearchBarItem.divider())
        searchBar.addItem(search)

        // Recent searches: folded to two rows, the chevron as the last tag; the trash clears the list.
        recentSource.clearButton = ImageButton(context).apply {
            setImageResource(R.drawable.cyl_ic_delete)
            background = null
            setColorFilter(secondary)
            contentDescription = getString(R.string.cyl_discover_clear)
            layoutParams = ViewGroup.LayoutParams(dp(44f), dp(44f))
            setOnClickListener { clearRecentSearches() }
        }
        recentList = CYLTagListView(context).apply {
            foldControl = CYLMenuFoldControl().apply {
                position = CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline
                content = CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
            }
            style = recentStyle()
            selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
            defaultVisibleRows = 2
            isScrollEnabled = false
            menuDataSource = recentSource
            menuDelegate = this@CYLSearchDiscoverFragment
        }
        // Discover: two per row, the More button refreshes the topics.
        discoverList = CYLTagListView(context).apply {
            style = discoverStyle()
            selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
            isScrollEnabled = false
            menuDataSource = discoverSource
            menuDelegate = this@CYLSearchDiscoverFragment
        }

        val pushed = parentFragment != null
        val top = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(if (pushed) dp(6f) else dp(14f), dp(8f), dp(14f), 0)
            if (pushed) {
                addView(ImageButton(context).apply {
                    setImageDrawable(ContextCompat.getDrawable(context, androidx.appcompat.R.drawable.abc_ic_ab_back_material))
                    background = null
                    contentDescription = getString(R.string.cyl_discover_back)
                    setOnClickListener { parentFragmentManager.popBackStack() }
                }, LinearLayout.LayoutParams(dp(36f), dp(44f)))
            }
            addView(searchBar, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        }
        val lists = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(recentList, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(discoverList, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        }
        hintLabel = TextView(context).apply {
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTextColor(secondary)
            gravity = Gravity.CENTER
        }
        showHint(getString(R.string.cyl_discover_askHint))
        val mic = ImageButton(context).apply {
            setImageResource(com.cyl.search.R.drawable.cyl_search_ic_mic)
            setColorFilter(Color.rgb(0xFF, 0x3B, 0x30))
            background = GradientDrawable().apply { setColor(Color.WHITE); cornerRadius = dp(26f).toFloat() }
            elevation = dp(3f).toFloat()
            contentDescription = getString(R.string.cyl_discover_ask)
            setOnClickListener { view?.announceForAccessibility(getString(R.string.cyl_discover_holdMic)) }
            setOnTouchListener(holdToAsk())
        }
        val bottom = FrameLayout(context).apply {
            addView(AskBackgroundView(context), FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(120f), Gravity.BOTTOM))
            addView(mic, FrameLayout.LayoutParams(dp(68f), dp(52f), Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL).apply { bottomMargin = dp(16f) })
        }
        reloadLists()
        return LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.WHITE)
            // The page takes the first focus, so the keyboard stays down until the field is tapped (as on iOS).
            isFocusableInTouchMode = true
            descendantFocusability = ViewGroup.FOCUS_BEFORE_DESCENDANTS
            addView(top)
            addView(ScrollView(context).apply { addView(lists) }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f).apply { topMargin = dp(10f) })
            addView(hintLabel, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { bottomMargin = dp(4f) })
            addView(bottom, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(110f)))
        }
    }

    // Styles

    private fun recentStyle(): CYLMenuStyle = CYLMenuStyle().apply {
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            appearanceForState(state).apply {
                backgroundColor = Color.WHITE
                borderColor = Color.argb(40, 0, 0, 0)
                borderWidth = 1f
                cornerRadius = 0f
                margin = 14f
                font = CYLFont(17f)
                textColor = Color.BLACK
            }
        }
        itemHeight = 36f
        interitemSpacing = 12f
        lineSpacing = 12f
        sectionInsets = CYLEdgeInsets(4f, 16f, 24f, 16f)
        applyHeaderLook(this)
    }

    private fun discoverStyle(): CYLMenuStyle = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2).apply {
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            appearanceForState(state).font = CYLFont(17f, Typeface.create("sans-serif-medium", Typeface.NORMAL))
        }
        // The hot icon at its own size.
        imageSize = CYLSize(0f, 0f)
        itemHeight = 36f
        lineSpacing = 16f
        sectionInsets = CYLEdgeInsets(4f, 16f, 16f, 16f)
        applyHeaderLook(this)
    }

    private fun applyHeaderLook(style: CYLMenuStyle) {
        style.backgroundColor = Color.WHITE
        style.headerHeight = 44f
        style.headerFont = CYLFont(20f, Typeface.DEFAULT_BOLD)
        style.headerTextColor = Color.BLACK
        style.headerHorizontalInset = 16f
    }

    // Data

    private fun reloadLists() {
        searchBar.placeholder = discoverSource.topics.firstOrNull()?.title ?: getString(R.string.cyl_discover_search)
        recentList.reloadMenuData()
        discoverList.reloadMenuData()
    }

    private fun refreshDiscover() {
        discoverSource.topics = data.randomTopics(discoverSource.topics)
        reloadLists()
    }

    /**
     * Searches `text`: shows it in the field and moves it to the front of the recent searches.
     */
    fun search(text: String) {
        val query = text.trim()
        if (query.isEmpty()) return
        searchBar.text = query
        recentSource.searches.remove(query)
        recentSource.searches.add(0, query)
        reloadLists()
        view?.announceForAccessibility(getString(R.string.cyl_discover_searching, query))
    }

    private fun searchTapped() {
        search(searchBar.text?.takeIf { it.isNotEmpty() } ?: searchBar.placeholder.orEmpty())
    }

    private fun clearRecentSearches() {
        recentSource.searches.clear()
        reloadLists()
        view?.announceForAccessibility(getString(R.string.cyl_discover_cleared))
    }

    private fun searchByImage() {
        AlertDialog.Builder(requireContext())
            .setTitle(R.string.cyl_discover_imageSearch)
            .setMessage(R.string.cyl_discover_imageSearchUnavailable)
            .setPositiveButton(R.string.cyl_discover_ok, null)
            .show()
    }

    private fun showHint(text: String) {
        hintLabel.text = "$text ✨"
        hintLabel.contentDescription = text
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun holdToAsk() = View.OnTouchListener { button, event ->
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> showHint(getString(R.string.cyl_discover_listening))
            MotionEvent.ACTION_UP -> {
                showHint(getString(R.string.cyl_discover_askHint))
                button.performClick()
            }
            MotionEvent.ACTION_CANCEL -> showHint(getString(R.string.cyl_discover_askHint))
        }
        true
    }

    // CYLMenuDelegate

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        if (menu === recentList) search(recentSource.searches[indexPath.item]) else search(discoverSource.topics[indexPath.item].title)
    }

    override fun menuDidTapMoreButtonInSection(menu: Any, section: Int) = refreshDiscover()

    // CYLSearchBarViewDelegate

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        searchTapped()
        searchBarView.hideKeyboard()
    }

    private fun themeColor(context: Context, attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    /**
     * The light gray area behind the mic button, its top edge a wide arc.
     */
    private class AskBackgroundView(context: Context) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(0xF2, 0xF2, 0xF7) }
        private val path = Path()

        init {
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }

        override fun onDraw(canvas: Canvas) {
            val rise = minOf(height.toFloat(), 40 * resources.displayMetrics.density)
            path.reset()
            path.moveTo(0f, rise)
            path.quadTo(width / 2f, -rise, width.toFloat(), rise)
            path.lineTo(width.toFloat(), height.toFloat())
            path.lineTo(0f, height.toFloat())
            path.close()
            canvas.drawPath(path, paint)
        }
    }
}
