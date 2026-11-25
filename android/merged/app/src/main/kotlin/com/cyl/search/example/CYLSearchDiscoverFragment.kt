package com.cyl.search.example

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
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
import android.widget.Button
import android.widget.ScrollView
import android.widget.SeekBar
import android.widget.Switch
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import com.cyl.classifymenu.CYLBadgeDrawable
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.search.CYLSearchBarItem
import com.cyl.search.CYLSearchBarStyle
import com.cyl.search.CYLSearchBarView
import com.cyl.search.CYLSearchBarViewDelegate
import com.cyl.search.CYLSearchTagListHeader
import com.cyl.search.CYLSearchTagListStyle
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
     * The number of whole pages of `discoverCount` topics (the pool is a multiple of it; docs/animated-icon-component.md, B).
     */
    val pages: Int get() = if (discoverCount <= 0) 0 else discover.size / discoverCount

    /**
     * The topics of `page` (wrapped into 0 until pages): whole records, the hot mark inside the record of its tag.
     */
    fun topicsOnPage(page: Int): List<CYLDiscoverTopic> {
        if (pages == 0) return emptyList()
        val index = ((page % pages) + pages) % pages
        return discover.subList(index * discoverCount, (index + 1) * discoverCount)
    }

    /**
     * The page the refresh shows after `page`: the next one, cyclically (no random pick, the same rule on every platform).
     */
    fun nextPage(after: Int): Int = if (pages == 0) 0 else (after + 1) % pages

    /**
     * The first page, so the first screen is always the same.
     */
    val initialTopics: List<CYLDiscoverTopic> get() = topicsOnPage(0)

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
    // The page of the discover topics the refresh shows next (CYLSearchDiscoverData.nextPage).
    private var discoverPage = 0
    private lateinit var hintLabel: TextView
    // The playback state of the animation item (the Switch and the SeekBar under the bar write it).
    private var animationLoops = false
    private var animationSpeed = 1f
    // The tag lists' background style, switched by the toggle under the playback row: Liquid Glass (default, owner rule 6) or flat.
    private var glassStyle = true

    private inner class RecentSource : CYLMenuDataSource {
        var searches: MutableList<String> = mutableListOf()

        override fun numberOfSectionsInMenu() = if (searches.isEmpty()) 0 else 1
        override fun menuNumberOfItemsInSection(section: Int) = searches.size
        override fun menuTitleForSection(section: Int) = getString(R.string.cyl_discover_recent)
        override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = searches[indexPath.item]
        // The list's built-in clear button (trash), on the header's 16 dp inset.
        override fun menuShowsClearButtonForSection(section: Int) = true
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
        override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = CYLSearchTagListHeader.refreshLabel(requireContext())
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
            // The 16 dp inset of the tag list's header and tags (docs/animated-icon-component.md, "Default layout contract"). Set here
            // until the core default moves from 12 to 16 (that change makes CYLSearchViewQMUIPortTest fail in the full suite: open).
            contentInsets = android.graphics.Rect(16, 6, 16, 6)
            fieldHeight = 46f
            searchBarStyle = CYLSearchBarStyle.Bordered
            fieldCornerRadius = 22f
            fieldBackgroundColor = pageBackground(context)
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
        // The camera button itself plays the animation (Animation demo rule): search_camera.json, the same Lottie file on
        // every platform; the static camera drawable stays the fallback when the engine is missing.
        camera.animationURL = android.net.Uri.parse("file:///android_asset/search_camera.json")
        camera.animationLoops = animationLoops
        camera.animationSpeed = animationSpeed
        val search = CYLSearchBarItem.textItem(getString(R.string.cyl_discover_search)) { searchTapped() }
        search.itemAccessibilityIdentifier = "CYLSearchDiscoverSearchButton"
        // No item tint of the example's own: the core's default is the label color (accent when selected).
        searchBar.addItem(camera)
        searchBar.addItem(CYLSearchBarItem.divider())
        searchBar.addItem(search)

        // Recent searches: folded to two rows, the chevron as the last tag; the trash clears the list.
        recentList = CYLTagListView(context).apply {
            foldControl = CYLMenuFoldControl().apply {
                position = CYLMenuFoldControlPosition.TAIL
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

        // Always a second-level page: the toolbar's navigation icon (the back arrow) is on the left and the core embeds the bar in
        // the toolbar so that it fills the rest (CYLSearchBarView.embedInToolbar); this page sets no width, margin or padding.
        val toolbar = androidx.appcompat.widget.Toolbar(context).apply {
            setNavigationIcon(ContextCompat.getDrawable(context, androidx.appcompat.R.drawable.abc_ic_ab_back_material)?.also { it.setTint(primary) })
            navigationContentDescription = getString(R.string.cyl_discover_back)
            setNavigationOnClickListener { parentFragmentManager.popBackStack() }
        }
        searchBar.embedInToolbar(toolbar)
        // Playback controls under the bar: loop switch, speed 0.25 to 3 and Play again (each at least 48dp high).
        val speedLabel = TextView(context).apply {
            setTextColor(secondary)
            minWidth = dp(48f)
            gravity = Gravity.CENTER
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        val speedBar = SeekBar(context).apply {
            max = 275
            progress = ((animationSpeed - 0.25f) * 100f).toInt()
            minimumHeight = dp(48f)
            contentDescription = getString(R.string.cyl_discover_animationSpeed)
        }
        fun showSpeed() {
            val text = String.format(Locale.getDefault(), "%.2fx", animationSpeed)
            speedLabel.text = text
            ViewCompat.setStateDescription(speedBar, text)
        }
        showSpeed()
        speedBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(bar: SeekBar, progress: Int, fromUser: Boolean) {
                animationSpeed = 0.25f + progress / 100f
                camera.animationSpeed = animationSpeed
                showSpeed()
            }
            override fun onStartTrackingTouch(bar: SeekBar) {}
            override fun onStopTrackingTouch(bar: SeekBar) {}
        })
        val loopSwitch = Switch(context).apply {
            isChecked = animationLoops
            minimumHeight = dp(48f)
            minimumWidth = dp(48f)
            contentDescription = getString(R.string.cyl_discover_animationLoops)
            setOnCheckedChangeListener { _, checked ->
                animationLoops = checked
                camera.animationLoops = checked
            }
        }
        val playAgain = Button(context).apply {
            text = getString(R.string.cyl_discover_animationPlay)
            minHeight = dp(48f)
            minimumWidth = dp(48f)
            contentDescription = getString(R.string.cyl_discover_animationPlay)
            setOnClickListener { camera.restartAnimation() }
        }
        val playback = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(16f), dp(8f), dp(16f), dp(8f))
            addView(loopSwitch)
            addView(speedBar, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            addView(speedLabel)
            addView(playAgain)
        }
        // Background style of both tag lists: Liquid Glass or flat, the current style as text (CYLSearchTagListStyle.applyBackgroundStyle).
        val styleText = TextView(context).apply { setTextColor(secondary) }
        fun showStyle() {
            styleText.text = getString(
                R.string.cyl_discover_styleLabel,
                getString(if (glassStyle) R.string.cyl_discover_styleGlass else R.string.cyl_discover_styleFlat),
            )
        }
        showStyle()
        val styleSwitch = Switch(context).apply {
            isChecked = glassStyle
            minimumHeight = dp(48f)
            minimumWidth = dp(48f)
            contentDescription = getString(R.string.cyl_discover_styleLabel, getString(R.string.cyl_discover_styleGlass))
            setOnCheckedChangeListener { _, checked ->
                glassStyle = checked
                showStyle()
                val name = if (checked) "liquidGlass" else "flat"
                CYLSearchTagListStyle.applyBackgroundStyle(name, recentList)
                CYLSearchTagListStyle.applyBackgroundStyle(name, discoverList)
            }
        }
        val styleRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(16f), dp(8f), dp(16f), dp(8f))
            addView(styleSwitch)
            addView(styleText, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = dp(12f) })
        }
        val lists = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(recentList, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(discoverList, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            // The playback row closes the page options: outside the bar, never between the bar and the lists.
            addView(playback)
            addView(styleRow)
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
        // The gradient is a SIBLING plate behind the page (rule 7), not the background of the lists' ancestor; both lists' glass samples it.
        val plate = cylBackdropPlate(context)
        recentList.backdropSource = plate
        discoverList.backdropSource = plate
        val page = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            // The page takes the first focus, so the keyboard stays down until the field is tapped (as on iOS).
            isFocusableInTouchMode = true
            descendantFocusability = ViewGroup.FOCUS_BEFORE_DESCENDANTS
            addView(toolbar, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(ScrollView(context).apply { addView(lists) }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f).apply { topMargin = dp(10f) })
            addView(hintLabel, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { bottomMargin = dp(4f) })
            addView(bottom, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(110f)))
        }
        return FrameLayout(context).apply {
            addView(plate, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            addView(page, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        }
    }

    // Styles

    // The search bar core's default tag look (CYLSearchTagListStyle: capsule tags, light border, bold header, 16 dp inset);
    // the list stays clear: the gradient plate behind the page shows through the glass (rule 7).
    private fun recentStyle(): CYLMenuStyle = CYLMenuStyle().apply {
        CYLSearchTagListStyle.applyDefaults(this, requireContext())
        backgroundColor = Color.TRANSPARENT
        CYLSearchTagListStyle.applyBackgroundStyle(if (glassStyle) "liquidGlass" else "flat", this)
    }

    private fun discoverStyle(): CYLMenuStyle = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2).apply {
        CYLSearchTagListStyle.applyGrid(this, requireContext())
        backgroundColor = Color.TRANSPARENT
        // The refresh action is the built-in icon (docs/animated-icon-component.md, A), never the three dots. After the style.
        CYLSearchTagListHeader.applyRefreshIcon(requireContext(), this)
        CYLSearchTagListStyle.applyBackgroundStyle(if (glassStyle) "liquidGlass" else "flat", this)
    }

    // Data

    private fun reloadLists() {
        searchBar.placeholder = discoverSource.topics.firstOrNull()?.title ?: getString(R.string.cyl_discover_search)
        recentList.reloadMenuData()
        discoverList.reloadMenuData()
    }

    private fun refreshDiscover() {
        discoverPage = data.nextPage(discoverPage)
        discoverSource.topics = data.topicsOnPage(discoverPage)
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
    override fun menuDidTapClearButtonInSection(menu: Any, section: Int) = clearRecentSearches()

    // CYLSearchBarViewDelegate

    override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {
        searchTapped()
        searchBarView.hideKeyboard()
    }

    // The page and field fill: the theme's window background (white in light, near black in dark), not a hard-coded white.
    private fun pageBackground(context: Context): Int = themeColor(context, android.R.attr.colorBackground)

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
