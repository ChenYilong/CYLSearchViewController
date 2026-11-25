package com.cyl.search

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.SizeF
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.ViewAnimationUtils
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.content.ContextCompat
import androidx.core.widget.ImageViewCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.findViewTreeLifecycleOwner
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLEdgeInsets
import com.cyl.classifymenu.CYLFont
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLOffset
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagButton
import kotlin.math.hypot
import kotlin.math.max

/**
 * The icon of the navigation button before the field (lapism `NavigationIconCompat`).
 */
enum class CYLSearchBarNavigationIcon {
    /**
     * No navigation button.
     */
    None,

    /**
     * A back arrow.
     */
    Arrow,

    /**
     * A magnifier.
     */
    Search,
}

/**
 * Where the search button sits while the bar is iconified.
 */
enum class CYLSearchBarIconPosition {
    /**
     * At the end, like an Android `SearchView` in a toolbar.
     */
    Trailing,

    /**
     * In the middle, like a floating action button that opens a search card.
     */
    Center,

    /**
     * At the start.
     */
    Leading,
}

/**
 * How the field opens and closes when `iconified` changes with animation.
 */
enum class CYLSearchBarExpansionAnimation {
    /**
     * The field grows from the icon and fades in.
     */
    Fade,

    /**
     * A circle grows from the icon until it uncovers the whole field (Material circular reveal).
     */
    CircularReveal,
}

/**
 * Whether a `CYLSearchBarView` edits one query or several searches side by side.
 */
enum class CYLSearchBarMode {
    /**
     * One query in the field (the default).
     */
    Single,

    /**
     * Several searches side by side (iammert `MultiSearchView`): `newSearchButton` starts a search, a completed search
     * becomes an entry in a horizontally scrolling row, with an indicator under the selected one and a remove button.
     */
    Multiple,
}

/**
 * Automatic capitalization of the typed text (iOS `UITextAutocapitalizationType`).
 */
enum class CYLTextAutocapitalizationType {
    /**
     * No automatic capitalization.
     */
    None,

    /**
     * The first letter of each word.
     */
    Words,

    /**
     * The first letter of each sentence.
     */
    Sentences,

    /**
     * Every character.
     */
    AllCharacters,
}

/**
 * Automatic correction of the typed text (iOS `UITextAutocorrectionType`).
 */
enum class CYLTextAutocorrectionType {
    /**
     * The keyboard's default.
     */
    Default,

    /**
     * No correction.
     */
    No,

    /**
     * Correction on.
     */
    Yes,
}

/**
 * Events of a `CYLSearchBarView`. Every method is optional.
 */
interface CYLSearchBarViewDelegate {

    /**
     * Asks whether a tap may start editing. Return false to use the bar as a button that opens another search page
     * (lapism `MaterialSearchBar.setOnClickListener`); `searchBarViewDidTapWhileNotEditable` is called instead.
     */
    fun searchBarViewShouldBeginEditing(searchBarView: CYLSearchBarView): Boolean = true

    /**
     * The bar was tapped while `searchBarViewShouldBeginEditing` refused editing.
     */
    fun searchBarViewDidTapWhileNotEditable(searchBarView: CYLSearchBarView) {}

    /**
     * Editing started.
     */
    fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) {}

    /**
     * Editing ended.
     */
    fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) {}

    /**
     * The text changed (typing, the clear button, Cancel with `clearsTextOnCancel`).
     */
    fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) {}

    /**
     * The keyboard's search key.
     */
    fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) {}

    /**
     * Cancel was tapped.
     */
    fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) {}

    /**
     * The navigation button before the field (`navigationIcon`, `navigationImage`).
     */
    fun searchBarViewNavigationButtonClicked(searchBarView: CYLSearchBarView) {}

    /**
     * The voice button (`showsVoiceButton`). Start speech recognition here and pass the result to `setText(text,
     * submit)`.
     */
    fun searchBarViewVoiceButtonClicked(searchBarView: CYLSearchBarView) {}

    /**
     * Asks whether the query may be submitted (the search key, the submit button or `setText(text, true)`). Return
     * false to keep it. By default every non-empty query is submitted.
     */
    fun searchBarViewShouldSubmitText(searchBarView: CYLSearchBarView, text: String): Boolean = true

    /**
     * The field opened or closed (`isIconified`).
     */
    fun searchBarViewDidChangeIconified(searchBarView: CYLSearchBarView, iconified: Boolean) {}

    /**
     * An appended item was tapped (`CYLSearchBarView.addItem`), like `-tabBar:didSelectItem:` (iOS
     * `-searchBarView:didSelectItem:`).
     */
    fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) {}

    /**
     * `Multiple` mode: the text of the search being typed changed (MultiSearchView `onTextChanged`). `Single` mode
     * calls `searchBarViewTextDidChange(searchBarView, text)` instead.
     */
    fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) {}

    /**
     * `Multiple` mode: a search was completed and became an entry (MultiSearchView `onSearchComplete`).
     */
    fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {}

    /**
     * `Multiple` mode: a search was removed (MultiSearchView `onSearchItemRemoved`).
     */
    fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int) {}

    /**
     * `Multiple` mode: a search was selected by a tap (MultiSearchView `onItemSelected`).
     */
    fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int) {}
}

/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, views
 * of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and
 * an optional Cancel button. `mode = Multiple` turns it into several searches side by side. Sizes are in dp,
 * durations in seconds, as on iOS.
 */
class CYLSearchBarView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(context, attrs, defStyleAttr) {

    private val density = resources.displayMetrics.density
    private val row = LinearLayout(context)
    private val leadingContainer = FrameLayout(context)
    private val textContainer = FrameLayout(context)
    private val accessoryContainer = LinearLayout(context)
    private val clearButton = iconButton()
    private val fieldBackground = GradientDrawable()
    private var settingText = false
    private var lengthFilter: InputFilter? = null

    /**
     * Receives the events.
     */
    var delegate: CYLSearchBarViewDelegate? = null

    /**
     * The text field inside the field.
     */
    val textField: EditText = object : EditText(context) {
        // A bar whose delegate refuses editing never takes the focus, also not when the window gives the focus back to the
        // first focusable view after another view cleared it (that would loop: take it, refuse it, clear it).
        override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean =
            delegate?.searchBarViewShouldBeginEditing(this@CYLSearchBarView) != false && super.requestFocus(direction, previouslyFocusedRect)
    }

    /**
     * The rounded field that holds the magnifier, the text and `trailingAccessoryViews`.
     */
    val fieldView: LinearLayout = LinearLayout(context)

    /**
     * The magnifier at the start of the field (decorative: hidden from TalkBack).
     */
    val searchIconView: ImageView = ImageView(context)

    /**
     * The Cancel button after the field (`showsCancelButton`).
     */
    val cancelButton: TextView = TextView(context)

    /**
     * Draws the placeholder, cut off with an ellipsis when it does not fit.
     */
    val placeholderLabel: TextView = TextView(context)

    /**
     * The button before the field. It is shown when `navigationIcon` is not `None` or `navigationImage` is set, and
     * `leadingView` is null; taps call `searchBarViewNavigationButtonClicked` and `navigationHandler`.
     */
    val navigationButton: ImageButton = iconButton()

    /**
     * A microphone inside the field, shown while the text is empty; it calls `searchBarViewVoiceButtonClicked`.
     */
    val voiceButton: ImageButton = iconButton()

    /**
     * A submit button inside the field, shown while there is text; it submits the query like the search key.
     */
    val submitButton: ImageButton = iconButton()

    /**
     * The button shown while `isIconified` is true. TalkBack reads it as "Search".
     */
    val iconButton: ImageButton = iconButton()

    // Text

    /**
     * The text of the field. Setting it does not call `searchBarViewTextDidChange`, as on iOS.
     */
    var text: String?
        get() = textField.text?.toString()
        set(value) {
            settingText = true
            textField.setText(value ?: "")
            textField.setSelection(textField.length())
            settingText = false
            textStateChanged()
        }

    /**
     * The placeholder, drawn by `placeholderLabel` and kept as the field's content description for TalkBack.
     */
    var placeholder: String? = null
        set(value) {
            field = value
            placeholderLabel.text = value
            textField.contentDescription = value ?: CYLSearchResources.localizedString(context, "search.field")
            applyStyle()
        }

    /**
     * The typeface of the text, the placeholder and Cancel. The default typeface when null.
     */
    var font: Typeface? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The text size in sp (the iOS font's point size). 17 by default (iOS body).
     */
    var fontSize: Float = 17f
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The text color. The theme's primary text color when null.
     */
    var textColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The placeholder color. The theme's hint color when null.
     */
    var placeholderColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The color of the text cursor (MaterialSearchView `setCursorDrawable`). The accent color when null; needs API
     * 29.
     */
    var cursorColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    // Field

    /**
     * The height of the field in dp; it grows when the text needs more. 36 by default.
     */
    var fieldHeight: Float = 36f
        set(value) {
            field = max(0f, value)
            applyLayout()
        }

    /**
     * The space around the field in dp (left, top, right, bottom). (12, 6, 12, 6) by default.
     */
    var contentInsets: Rect = Rect(12, 6, 12, 6)
        set(value) {
            field = value
            applyLayout()
        }

    /**
     * The field's background. A light gray fill (iOS `tertiarySystemFillColor`) when null.
     */
    var fieldBackgroundColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The field's corner radius in dp; negative makes a capsule. -1 by default.
     */
    var fieldCornerRadius: Float = -1f
        set(value) {
            field = value
            applyLayout()
        }

    /**
     * The field's border color; null draws no border.
     */
    var fieldBorderColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The field's border width in dp, used with `fieldBorderColor`. 0 by default.
     */
    var fieldBorderWidth: Float = 0f
        set(value) {
            field = max(0f, value)
            applyStyle()
        }

    /**
     * The field's shadow, 0 to 1 (drawn as elevation). 0 by default.
     */
    var fieldShadowOpacity: Float = 0f
        set(value) {
            field = value.coerceIn(0f, 1f)
            applyStyle()
        }

    /**
     * The magnifier; null shows none. A magnifier by default.
     */
    var searchIcon: Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * The magnifier's tint. The theme's secondary text color when null.
     */
    var searchIconTintColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    // Accessory views

    /**
     * Views of yours inside the field after the text.
     */
    var trailingAccessoryViews: List<View> = emptyList()
        set(value) {
            field = value
            updateAccessories()
        }

    // Items

    private val mutableItems = mutableListOf<CYLSearchBarItem>()

    /**
     * The appended items, in order, after the text and after `trailingAccessoryViews` (like the FlatDesign tab bar's
     * `items`). The field stays; only items are appended.
     */
    val items: List<CYLSearchBarItem>
        get() = mutableItems.toList()

    /**
     * The views of `items` (`CYLTagButton`s), in the same order.
     */
    val itemViews: List<CYLTagButton>
        get() = mutableItems.map { it.loadItemView(context) }

    /**
     * The icon and title color of every item without its own `tintColor`; null uses the primary text color.
     */
    var itemTintColor: Int? = null
        set(value) {
            field = value
            mutableItems.forEach { it.loadedItemView?.reload() }
        }

    /**
     * The fixed look of the bar. `Bordered` draws the field and its items inside one capsule outline.
     */
    var searchBarStyle: CYLSearchBarStyle = CYLSearchBarStyle.Plain
        set(value) {
            field = value
            applySearchBarStyle()
        }

    /**
     * An image drawn behind the field's content, clipped to its corners.
     */
    var fieldBackgroundImage: Drawable? = null
        set(value) {
            field = value
            fieldView.background = if (value != null) LayerDrawable(arrayOf(fieldBackground, value)) else fieldBackground
            fieldView.clipToOutline = value != null
        }

    /**
     * The first selected item (a `isSelectable` item that is on), or null.
     */
    val selectedItem: CYLSearchBarItem?
        get() = mutableItems.firstOrNull { it.isSelected }

    /**
     * The index of `selectedItem`, or -1.
     */
    val selectedIndex: Int
        get() = mutableItems.indexOfFirst { it.isSelected }

    /**
     * Appends an item after the others.
     */
    fun addItem(item: CYLSearchBarItem) {
        insertItem(item, mutableItems.size)
    }

    /**
     * Inserts an item at an index (clamped to `items`); an item already in a bar moves here.
     */
    fun insertItem(item: CYLSearchBarItem, index: Int) {
        itemShapes = null
        item.searchBarView?.removeItem(item)
        mutableItems.add(index.coerceIn(0, mutableItems.size), item)
        item.searchBarView = this
        item.loadItemView(context).reload()
        updateAccessories()
    }

    /**
     * Creates an item and inserts it at an index; -1 or a larger index appends it. Mirrors
     * `-addItemWithTitle:tabBarItemImage:tabBarItemSelectedImage:index:`.
     */
    @JvmOverloads
    fun addItem(
        style: CYLSearchBarItemStyle,
        title: String?,
        image: Drawable?,
        index: Int = -1,
        handler: ((CYLSearchBarItem) -> Unit)? = null,
    ): CYLSearchBarItem {
        val item = CYLSearchBarItem(style, title, image)
        item.handler = handler
        insertItem(item, if (index < 0) mutableItems.size else index)
        return item
    }

    /**
     * Removes an item from the bar.
     */
    fun removeItem(item: CYLSearchBarItem) {
        if (!mutableItems.remove(item)) {
            return
        }
        itemShapes = null
        item.searchBarView = null
        item.itemView?.let { (it.parent as? ViewGroup)?.removeView(it) }
        updateAccessories()
    }

    /**
     * Removes every item.
     */
    fun removeAllItems() {
        mutableItems.toList().forEach { removeItem(it) }
    }

    /**
     * Replaces the items with the ones the maps describe (`CYLSearchBarItem.fromMap`), as the cross-platform bridges send
     * them. When only `animationLoops` and `animationSpeed` differ from the last call, the items stay and take the two
     * values, so the animation is not reloaded; any other difference rebuilds the items.
     */
    fun setItems(maps: List<Map<String, Any?>>) {
        val playbackKeys = setOf("animationLoops", "animationSpeed")
        val shapes = maps.map { map -> map.filterKeys { it !in playbackKeys } }
        if (itemShapes == shapes && mutableItems.size == shapes.size) {
            mutableItems.zip(maps).forEach { (item, map) ->
                item.animationLoops = map["animationLoops"] as? Boolean ?: false
                item.animationSpeed = (map["animationSpeed"] as? Number)?.toFloat() ?: 1f
            }
            return
        }
        removeAllItems()
        maps.forEach { addItem(CYLSearchBarItem.fromMap(context, it)) }
        itemShapes = shapes
    }

    // The item maps of the last `setItems` without the playback keys; null once an item was added or removed in any other way.
    private var itemShapes: List<Map<String, Any?>>? = null

    /**
     * True when an item of the style was appended (a text "Search" button), like `-hasPlusButton`.
     */
    fun hasItem(style: CYLSearchBarItemStyle): Boolean = mutableItems.any { it.style == style }

    internal fun itemTapped(item: CYLSearchBarItem) {
        if (!item.isEnabled) {
            return
        }
        if (item.isSelectable) {
            item.isSelected = !item.isSelected
        }
        if (item.animationURL != null) {
            // An animated icon plays on each tap, as a tab icon does (after the selection, which resets it).
            item.loadedItemView?.playAnimation()
        }
        delegate?.searchBarViewDidSelectItem(this, item)
        item.handler?.invoke(item)
    }

    private fun isNightMode(): Boolean = isNight(context)

    private fun applySearchBarStyle() {
        when (searchBarStyle) {
            CYLSearchBarStyle.Plain -> Unit
            CYLSearchBarStyle.Bordered -> {
                // The shared values: `.secondaryLabel` border (a visible line), `.systemBackground` fill (white in light mode, so the field stands out
                // from an off-white page; the theme background in dark mode).
                val dark = isNightMode()
                fieldBorderColor = if (dark) BORDERED_BORDER_DARK else BORDERED_BORDER_LIGHT
                fieldBorderWidth = 1f
                fieldBackgroundColor = if (dark) themeColor(android.R.attr.colorBackground) else Color.WHITE
                fieldCornerRadius = -1f
            }
        }
    }

    /**
     * The navigation field preset (the Discover look), the one look of every search or text field in a navigation bar or page
     * header on every platform (iOS `applyNavigationFieldStyle()`): a bordered capsule (corner radius 18 dp), a soft shadow
     * (opacity 0.06), no magnifier, 16 sp text (it scales with the font size setting) and an OPAQUE fill, white in light mode
     * and black in dark mode, so a gradient or a sheet behind the bar never shows through. An example calls this, it never sets
     * these values. Add a `CYLSearchBarItem.divider()` before the trailing items (camera, Search) it appends.
     */
    fun applyNavigationFieldStyle() {
        searchIcon = null
        searchBarStyle = CYLSearchBarStyle.Bordered
        fieldCornerRadius = NAVIGATION_FIELD_CORNER_RADIUS
        fieldShadowOpacity = NAVIGATION_FIELD_SHADOW_OPACITY
        fieldBackgroundColor = if (isNightMode()) Color.BLACK else Color.WHITE
        fontSize = NAVIGATION_FIELD_FONT_SIZE
    }

    /**
     * A view of yours before the field (a back button); it wins over the navigation button.
     */
    var leadingView: View? = null
        set(value) {
            field?.let { leadingContainer.removeView(it) }
            field = value
            value?.let { (it.parent as? ViewGroup)?.removeView(it); leadingContainer.addView(it) }
            applyIconifiedVisibility()
        }

    // Cancel button

    /**
     * Shows the Cancel button after the field. False by default.
     */
    var showsCancelButton: Boolean = false
        set(value) {
            field = value
            applyIconifiedVisibility()
        }

    /**
     * The Cancel title. The localized "Cancel" when null.
     */
    var cancelButtonTitle: String? = null
        get() = field ?: CYLSearchResources.localizedString(context, "search.cancel")
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * Taps on Cancel also end editing. True by default.
     */
    var cancelButtonEndsEditing: Boolean = true

    /**
     * Taps on Cancel also clear the text (lapism `setTextClearOnBackPressed`). False by default.
     */
    var clearsTextOnCancel: Boolean = false

    /**
     * Whether the bar is an editing bar (`editingBar`): an edit field in the search bar's look, whose trailing button
     * submits instead of cancelling (iOS `isEditingBar`).
     */
    var isEditingBar: Boolean = false
        internal set

    /**
     * An editing bar's submit: the trimmed text, when its action button or the action key is tapped (after
     * `searchBarViewShouldSubmitText` and `searchBarViewSearchButtonClicked`). Empty text submits nothing (iOS
     * `editingSubmitHandler`).
     */
    var editingSubmitHandler: ((CYLSearchBarView, String) -> Unit)? = null

    /**
     * An editing bar's submit (iOS `submitEditing`): the delegate's checks (`submit()`), then `editingSubmitHandler`.
     */
    private fun submitEditing() {
        val trimmed = text.orEmpty().trim()
        if (trimmed.isEmpty() || !submit()) return
        editingSubmitHandler?.invoke(this, trimmed)
    }

    /**
     * Pins the bar to the bottom of `container`, full width, riding on the keyboard while it is up (iOS
     * `pinToKeyboard(in:)`, the keyboard layout guide): with `SOFT_INPUT_ADJUST_RESIZE` the container already ends at
     * the keyboard; in an edge-to-edge window the bar moves up by the part of the IME inset below the container.
     */
    /**
     * After `pinToKeyboard`: how far the keyboard covers the container's bottom, in pixels (0 while it is down), on every
     * change; a host uses it to keep its own content above the keyboard (iOS: the keyboard layout guide).
     */
    var keyboardOverlapHandler: ((Int) -> Unit)? = null

    fun pinToKeyboard(container: ViewGroup) {
        if (parent !== container) {
            (parent as? ViewGroup)?.removeView(this)
            val params: ViewGroup.LayoutParams = when (container) {
                is android.widget.FrameLayout -> android.widget.FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, android.view.Gravity.BOTTOM)
                is android.widget.LinearLayout -> android.widget.LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
                else -> ViewGroup.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
            }
            container.addView(this, params)
        }
        androidx.core.view.ViewCompat.setOnApplyWindowInsetsListener(container) { view, insets ->
            val ime = insets.getInsets(androidx.core.view.WindowInsetsCompat.Type.ime()).bottom
            val location = IntArray(2)
            view.getLocationInWindow(location)
            val below = (view.rootView.height - (location[1] + view.height)).coerceAtLeast(0)
            val overlap = (ime - below).coerceAtLeast(0)
            translationY = -overlap.toFloat()
            keyboardOverlapHandler?.invoke(overlap)
            insets
        }
        androidx.core.view.ViewCompat.requestApplyInsets(container)
    }

    /**
     * Ending editing also clears the text (lapism `setTextClearOnClearFocus`). False by default.
     */
    var clearsTextOnEndEditing: Boolean = false

    // Navigation button

    /**
     * A built-in navigation icon. `None` by default.
     */
    var navigationIcon: CYLSearchBarNavigationIcon = CYLSearchBarNavigationIcon.None
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * A custom navigation icon; it wins over `navigationIcon`.
     */
    var navigationImage: Drawable? = null
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * What TalkBack reads for the navigation button. "Back" for the arrow and "Search" for the magnifier when null.
     */
    var navigationAccessibilityLabel: String? = null
        get() = field ?: CYLSearchResources.localizedString(
            context,
            if (navigationIcon == CYLSearchBarNavigationIcon.Search) "search.field" else "search.back",
        )
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * A circle drawn behind the navigation icon. Null (none) by default.
     */
    var navigationBackgroundColor: Int? = null
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * The shadow of that circle, 0 to 1 (lapism `setNavigationElevation`). 0 by default.
     */
    var navigationShadowOpacity: Float = 0f
        set(value) {
            field = value.coerceIn(0f, 1f)
            updateButtonImages()
        }

    /**
     * Called on taps on the navigation button, after the delegate.
     */
    var navigationHandler: ((CYLSearchBarView) -> Unit)? = null

    // Voice, submit and clear buttons

    /**
     * Shows `voiceButton` while the text is empty. False by default.
     */
    var showsVoiceButton: Boolean = false
        set(value) {
            field = value
            updateAccessories()
        }

    /**
     * The voice button's icon. A microphone when null.
     */
    var voiceImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_mic)
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * Shows `submitButton` while there is text (Android `isSubmitButtonEnabled`). False by default.
     */
    var showsSubmitButton: Boolean = false
        set(value) {
            field = value
            updateAccessories()
        }

    /**
     * The submit button's icon. An arrow in a circle when null.
     */
    var submitImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_submit)
        set(value) {
            field = value
            updateButtonImages()
        }

    /**
     * The clear button's icon, shown while editing with text. A cross in a circle when null.
     */
    var clearImage: Drawable? = null
        set(value) {
            field = value
            updateButtonImages()
        }

    // Keyboard

    /**
     * The keyboard (an `InputType` class, iOS `keyboardType`). `InputType.TYPE_CLASS_TEXT` by default.
     */
    var keyboardType: Int = InputType.TYPE_CLASS_TEXT
        set(value) {
            field = value
            applyInputType()
        }

    /**
     * The action key (an `EditorInfo.IME_ACTION_*`, iOS `returnKeyType`). `IME_ACTION_SEARCH` by default.
     */
    var returnKeyType: Int = EditorInfo.IME_ACTION_SEARCH
        set(value) {
            field = value
            textField.imeOptions = value or EditorInfo.IME_FLAG_NO_EXTRACT_UI
            multiSearchContent.applyStyle()
        }

    /**
     * Automatic capitalization. `Sentences` by default.
     */
    var autocapitalizationType: CYLTextAutocapitalizationType = CYLTextAutocapitalizationType.Sentences
        set(value) {
            field = value
            applyInputType()
        }

    /**
     * Automatic correction. `Default` by default.
     */
    var autocorrectionType: CYLTextAutocorrectionType = CYLTextAutocorrectionType.Default
        set(value) {
            field = value
            applyInputType()
        }

    /**
     * Hides the typed characters (Android `inputType="textPassword"`). False by default.
     */
    var isSecureTextEntry: Boolean = false
        set(value) {
            field = value
            applyInputType()
        }

    /**
     * The longest text a person can type (Android `maxLength`); 0 means no limit. 0 by default.
     */
    var maximumTextLength: Int = 0
        set(value) {
            field = max(0, value)
            lengthFilter = if (field > 0) InputFilter.LengthFilter(field) else null
            textField.filters = listOfNotNull(lengthFilter).toTypedArray()
            val current = text.orEmpty()
            if (field > 0 && current.length > field) {
                text = current.substring(0, field)
            }
            multiSearchContent.applyStyle()
        }

    // Iconified

    private var iconifiedState = false

    /**
     * Shows only a search button instead of the field (Android `SearchView.isIconified`). Tapping the button opens
     * the field and starts editing. False by default.
     */
    var isIconified: Boolean
        get() = iconifiedState
        set(value) = setIconified(value, false)

    /**
     * When true, the field closes back to its icon when editing ends with no text (Android
     * `setIconifiedByDefault`). False by default.
     */
    var iconifiedByDefault: Boolean = false
        set(value) {
            field = value
            if (value && !textField.hasFocus() && text.isNullOrEmpty()) {
                setIconified(true, false)
            }
        }

    /**
     * How the field opens and closes. `Fade` by default.
     */
    var expansionAnimation: CYLSearchBarExpansionAnimation = CYLSearchBarExpansionAnimation.Fade

    /**
     * Where `iconButton` sits while iconified; the field opens from there. `Trailing` by default.
     */
    var iconPosition: CYLSearchBarIconPosition = CYLSearchBarIconPosition.Trailing
        set(value) {
            field = value
            applyLayout()
        }

    /**
     * The length of the opening and closing animations, in seconds. 0.3 by default.
     */
    var animationDuration: Double = 0.3

    // Multiple searches (mode = Multiple; iammert MultiSearchView)

    /**
     * Whether the bar edits one query (`Single`, the default) or several searches side by side (`Multiple`).
     */
    var mode: CYLSearchBarMode = CYLSearchBarMode.Single
        set(value) {
            field = value
            applyMode()
        }

    /**
     * In `Multiple` mode, the button at the end: it starts a new search, or completes the one being typed.
     */
    val newSearchButton: ImageButton = ImageButton(context)

    private val multiSearchContent = MultiSearchContent(context)

    // The system Back gesture ends the search being typed, like `completeSearch`, while one is typed.
    private val multiSearchBackCallback = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() = completeSearch()
    }

    /**
     * The texts of the searches in `Multiple` mode, completed searches first, then the one being typed.
     */
    val searches: List<String>
        get() = multiSearchContent.searchTexts

    /**
     * The selected search in `Multiple` mode, or -1 (iOS `NSNotFound`) when there is none.
     */
    val selectedSearchIndex: Int
        get() = multiSearchContent.selectedIndex

    /**
     * True while a new search is being typed in `Multiple` mode.
     */
    val isEditingNewSearch: Boolean
        get() = multiSearchContent.isInSearchMode

    /**
     * A search shorter than this is dropped by `completeSearch`. 3 by default, as in MultiSearchView.
     */
    var minimumTextLength: Int = 3

    /**
     * The color of the indicator under the selected search and of `newSearchButton`. The accent color when null.
     */
    var searchIndicatorColor: Int? = null
        set(value) {
            field = value
            multiSearchContent.applyStyle()
        }

    /**
     * The opacity of the searches that are not selected. 0.5 by default.
     */
    var unselectedSearchAlpha: Float = 0.5f
        set(value) {
            field = value.coerceIn(0f, 1f)
            multiSearchContent.applyStyle()
        }

    /**
     * The width of the field of a new search, in dp. 160 by default.
     */
    var searchFieldWidth: Float = 160f
        set(value) {
            field = max(44f, value)
            multiSearchContent.applyStyle()
        }

    /**
     * The icon of `newSearchButton`. A magnifier when null.
     */
    var newSearchImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
        set(value) {
            field = value
            multiSearchContent.applyStyle()
        }

    /**
     * The icon of the remove button on the selected search. A cross in a circle when null.
     */
    var removeSearchImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_clear)
        set(value) {
            field = value
            multiSearchContent.applyStyle()
        }

    /**
     * Starts a new search and shows the keyboard (MultiSearchView `search`). Does nothing while a search is typed.
     */
    fun beginNewSearch() = multiSearchContent.search()

    /**
     * Completes the search being typed: it becomes the selected search, or is dropped when shorter than
     * `minimumTextLength`.
     */
    fun completeSearch() = multiSearchContent.completeSearch()

    /**
     * Adds a completed search without typing it and selects it.
     */
    fun addSearch(text: String) = multiSearchContent.addSearchText(text)

    /**
     * Selects a search, like a tap on it.
     */
    fun selectSearch(index: Int) = multiSearchContent.selectItemAtIndex(index)

    /**
     * Removes a search, like a tap on its remove button.
     */
    fun removeSearch(index: Int) = multiSearchContent.removeItemAtIndex(index)

    private fun applyMode() {
        val multiple = mode == CYLSearchBarMode.Multiple
        multiSearchContent.visibility = if (multiple) VISIBLE else GONE
        multiSearchBackCallback.isEnabled = multiple && isEditingNewSearch
        applyIconifiedVisibility()
    }

    /** A live light/dark switch re-resolves every default color: the placeholder, the items, the dividers and a bordered field. */
    override fun onConfigurationChanged(newConfig: android.content.res.Configuration) {
        super.onConfigurationChanged(newConfig)
        applyStyle()
        applySearchBarStyle()
        mutableItems.forEach { it.loadedItemView?.reload() }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        var base: Context? = context
        while (base is ContextWrapper && base !is ComponentActivity) {
            base = base.baseContext
        }
        (base as? ComponentActivity)?.onBackPressedDispatcher?.addCallback(multiSearchBackCallback)
        multiSearchBackCallback.isEnabled = mode == CYLSearchBarMode.Multiple && isEditingNewSearch
        if (focusesOnAppear) {
            observeAppearLifecycle(base as? LifecycleOwner)
            focusIfAppearing()
        }
    }

    override fun onDetachedFromWindow() {
        stopObservingAppearLifecycle()
        multiSearchBackCallback.remove()
        super.onDetachedFromWindow()
    }

    // MARK: Focus on appear

    /**
     * Whether the field takes focus (and the soft keyboard shows) every time the bar appears on screen, like a `viewDidAppear`: the
     * first time its page is entered, after a tab switch or a push and pop (the view is attached again or becomes visible), when the
     * window regains focus and when the Activity or Fragment resumes (return from the background). Nothing is observed while this is
     * false. False by default. FILTER (owner, 2026-11-26): only a bar embedded in a toolbar that shows a back button (navigation
     * icon) focuses; a root tab or a plain bar never auto-focuses, even when this is true.
     *
     * The moments come from the view itself (attach, visibility, window focus) and from the lifecycle owner of the view tree
     * (`ViewTreeLifecycleOwner`, else the host Activity) at ON_RESUME. TODO: CYLDeallocBlockExecutor's Android dependency is deferred
     * until the library ships an on-screen event; then these callbacks move there (docs/task-log.md, 2026-11-26).
     */
    var focusesOnAppear: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            if (value) {
                if (isAttachedToWindow) {
                    observeAppearLifecycle(null)
                    focusIfAppearing()
                }
            } else {
                stopObservingAppearLifecycle()
            }
        }

    private var appearLifecycle: Lifecycle? = null
    private val appearObserver = object : DefaultLifecycleObserver {
        override fun onResume(owner: LifecycleOwner) {
            focusIfAppearing()
        }
    }

    private fun observeAppearLifecycle(fallback: LifecycleOwner?) {
        stopObservingAppearLifecycle()
        val owner = findViewTreeLifecycleOwner() ?: fallback ?: hostLifecycleOwner() ?: return
        appearLifecycle = owner.lifecycle.also { it.addObserver(appearObserver) }
    }

    private fun stopObservingAppearLifecycle() {
        appearLifecycle?.removeObserver(appearObserver)
        appearLifecycle = null
    }

    private fun hostLifecycleOwner(): LifecycleOwner? {
        var base: Context? = context
        while (base is ContextWrapper && base !is LifecycleOwner) base = base.baseContext
        return base as? LifecycleOwner
    }

    /** True when the bar sits in a toolbar (embedInToolbar) that currently shows a navigation icon, the back button. */
    private fun hasBackButton(): Boolean {
        var view: View? = parent as? View
        while (view != null && view !is androidx.appcompat.widget.Toolbar) view = view.parent as? View
        return (view as? androidx.appcompat.widget.Toolbar)?.navigationIcon != null
    }

    /** Focuses the field and shows the keyboard when `focusesOnAppear` is on, the bar is on screen, has a back button and is not editing yet. */
    private fun focusIfAppearing() {
        if (!focusesOnAppear) return
        post {
            val resumed = appearLifecycle?.currentState?.isAtLeast(Lifecycle.State.RESUMED) != false
            if (focusesOnAppear && resumed && isAttachedToWindow && isShown && hasBackButton() && textField.isEnabled && !textField.hasFocus()) {
                showKeyboard()
            }
        }
    }

    override fun onWindowFocusChanged(hasWindowFocus: Boolean) {
        super.onWindowFocusChanged(hasWindowFocus)
        if (hasWindowFocus) focusIfAppearing()
    }

    override fun onVisibilityChanged(changedView: View, visibility: Int) {
        super.onVisibilityChanged(changedView, visibility)
        if (visibility == View.VISIBLE) focusIfAppearing()
    }

    // QMUI search bar port (docs/qmui-search-controller.md, "Android (Kotlin, android/merged...): QMUI search port")

    // The views of `trailingAccessoryViews` sit in their own container at the start of `accessoryContainer`, so that one slot
    // can animate them without touching the items, the voice and the submit button.
    private val trailingViewsContainer = LinearLayout(context)
    private val leadingSlot = AccessorySlot(leadingContainer)
    private val trailingViewsSlot = AccessorySlot(trailingViewsContainer)
    private val cancelSlot = AccessorySlot(cancelButton)
    private var leadingShown = true
    private var trailingShown = true
    private var animatesCancel = false
    private val focusSink = View(context).apply {
        isFocusableInTouchMode = true
        alpha = 0f
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /**
     * Whether the bar is being edited (the field has the focus): the "active" state of `textFieldMarginsProvider`,
     * `cancelButtonMarginsProvider` and `centersPlaceholder` (iOS: the search controller is active).
     */
    val isActive: Boolean
        get() = textField.hasFocus()

    /**
     * Draws the placeholder (and the magnifier) in the middle of the field while the bar is not being edited and the
     * text is empty, and at the start otherwise (QMUI `qmui_centerPlaceholder`). False by default.
     */
    var centersPlaceholder: Boolean = false
        set(value) {
            field = value
            updatePlaceholderCentering()
        }

    /**
     * The space around the field in dp (left, top, right, bottom) on top of `contentInsets`, in both states. Zero by
     * default; `textFieldMarginsProvider` wins when it is set.
     */
    var textFieldMargins: Rect = Rect()
        set(value) {
            field = value
            applyActiveState()
        }

    /**
     * The field's margins in dp for each state: the bar and whether it is active (iOS `textFieldMarginsProvider`).
     * Null uses `textFieldMargins`.
     */
    var textFieldMarginsProvider: ((CYLSearchBarView, Boolean) -> Rect)? = null
        set(value) {
            field = value
            applyActiveState()
        }

    /**
     * The space around the Cancel button in dp (left, top, right, bottom) on top of the 8 dp gap. A negative left
     * value pulls Cancel toward the field, at most until it touches it: Cancel never covers the field. Zero by
     * default; `cancelButtonMarginsProvider` wins when it is set.
     */
    var cancelButtonMargins: Rect = Rect()
        set(value) {
            field = value
            applyActiveState()
        }

    /**
     * Cancel's margins in dp for each state (iOS `cancelButtonMarginsProvider`), see `cancelButtonMargins`. Null uses
     * `cancelButtonMargins`.
     */
    var cancelButtonMarginsProvider: ((CYLSearchBarView, Boolean) -> Rect)? = null
        set(value) {
            field = value
            applyActiveState()
        }

    /**
     * The typeface of the Cancel button. `font` when null.
     */
    var cancelButtonFont: Typeface? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The text size of the Cancel button in sp, the size half of iOS `cancelButtonFont` (a `UIFont` has both). `fontSize`
     * when null.
     */
    var cancelButtonFontSize: Float? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * Shows Cancel while the bar is being edited, as a `UISearchBar` does in a search (also when `showsCancelButton` is
     * false). False by default.
     */
    var showsCancelButtonWhenEditing: Boolean = false
        set(value) {
            field = value
            syncCancelButton(isAttachedToWindow)
        }

    /**
     * The color of Cancel and of the cursor (iOS `tintColor`). The accent color when null.
     */
    var tintColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * Whether the view before the field (`leadingView`, or the navigation button) is shown (iOS `showsLeadingView`). True
     * by default; a hidden view gives its room to the field. `setShowsLeadingView` animates it.
     */
    var showsLeadingView: Boolean
        get() = leadingShown
        set(value) = setShowsLeadingView(value, false)

    /**
     * Whether `trailingAccessoryViews` are shown (iOS `showsTrailingAccessoryViews`). True by default; hidden views give
     * their room to the text. `setShowsTrailingAccessoryViews` animates them.
     */
    var showsTrailingAccessoryViews: Boolean
        get() = trailingShown
        set(value) = setShowsTrailingAccessoryViews(value, false)

    /**
     * The same view as `leadingView` (QMUI `qmui_leftAccessoryView`).
     */
    @Deprecated("One slot before the field: use leadingView.", ReplaceWith("leadingView"))
    var leadingAccessoryView: View?
        get() = leadingView
        set(value) {
            leadingView = value
        }

    /**
     * The same flag as `showsLeadingView`.
     */
    @Deprecated("Use showsLeadingView.", ReplaceWith("showsLeadingView"))
    var showsLeadingAccessoryView: Boolean
        get() = showsLeadingView
        set(value) {
            showsLeadingView = value
        }

    /**
     * The space around the view before the field in dp (left, top, right, bottom), as padding of its slot. Zero by default.
     */
    @Deprecated("Give the view its own margins in its layout parameters.")
    var leadingAccessoryViewMargins: Rect = Rect()
        set(value) {
            field = value
            leadingContainer.setPaddingRelative(dp(value.left.toFloat()), dp(value.top.toFloat()), dp(value.right.toFloat()), dp(value.bottom.toFloat()))
        }

    /**
     * The first of `trailingAccessoryViews` (QMUI `qmui_rightAccessoryView`); setting it makes it the only one.
     */
    @Deprecated("Use trailingAccessoryViews.", ReplaceWith("trailingAccessoryViews.firstOrNull()"))
    var trailingAccessoryView: View?
        get() = trailingAccessoryViews.firstOrNull()
        set(value) {
            trailingAccessoryViews = listOfNotNull(value)
        }

    /**
     * The same flag as `showsTrailingAccessoryViews`.
     */
    @Deprecated("Use showsTrailingAccessoryViews.", ReplaceWith("showsTrailingAccessoryViews"))
    var showsTrailingAccessoryView: Boolean
        get() = showsTrailingAccessoryViews
        set(value) {
            showsTrailingAccessoryViews = value
        }

    /**
     * The space around each of `trailingAccessoryViews` in dp (left, top, right, bottom), on top of the 8 dp gap. Zero by
     * default.
     */
    @Deprecated("Give the views their own margins in their layout parameters.")
    var trailingAccessoryViewMargins: Rect = Rect()
        set(value) {
            field = value
            updateAccessories()
        }

    /**
     * Whether the bar is a list's header item (QMUI `qmui_usedAsTableHeaderView`). Set by the screens that install the bar
     * as the first item of a list (`CYLSearchListView`, `CYLSearchView.installSearchBar`); false by default.
     */
    var usedAsTableHeaderView: Boolean = false

    /**
     * Whether the Cancel button stays enabled while the field is not being edited (QMUI `qmui_alwaysEnableCancelButton`).
     * False disables it until the field has the focus. True by default.
     */
    var alwaysEnablesCancelButton: Boolean = true
        set(value) {
            field = value
            updateCancelButtonEnabled()
        }

    /**
     * The view that draws the bar's background (QMUI `qmui_backgroundView`): the bar itself, whose `background` is the
     * bar's image, color and border (`CYLSearchBarAppearance.barBackgroundImage`, `barBackgroundColor`, `barBorderColor`).
     */
    val backgroundView: View?
        get() = this

    /**
     * The titles of the scope bar under the field (iOS `UISearchBar.scopeButtonTitles`); empty (the default) has none.
     * The first title is selected; read the selection from `segmentedControl`.
     */
    var scopeButtonTitles: List<String> = emptyList()
        set(value) {
            field = value
            rebuildScopeBar()
        }

    /**
     * The scope bar, a segmented `RadioGroup` under the field (QMUI `qmui_segmentedControl`); null without
     * `scopeButtonTitles`. One button per title; `checkedRadioButtonId` and `setOnCheckedChangeListener` read the selection.
     */
    val segmentedControl: RadioGroup?
        get() = scopeBar

    private var scopeBar: RadioGroup? = null
    private var scopeBarHeight = 0

    private fun rebuildScopeBar() {
        scopeBar?.let { removeView(it) }
        scopeBar = null
        setPadding(paddingLeft, paddingTop, paddingRight, paddingBottom - scopeBarHeight)
        scopeBarHeight = 0
        if (scopeButtonTitles.isEmpty()) {
            return
        }
        val height = dp(SCOPE_BAR_HEIGHT)
        val group = RadioGroup(context)
        group.orientation = RadioGroup.HORIZONTAL
        scopeButtonTitles.forEachIndexed { index, title ->
            val button = RadioButton(context)
            button.id = View.generateViewId()
            button.text = title
            group.addView(button, RadioGroup.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f))
            if (index == 0) {
                group.check(button.id)
            }
        }
        // The strip below the row is the bar's own padding, so the bar grows by the scope bar's height and the row stays put.
        scopeBarHeight = height
        clipToPadding = false
        setPadding(paddingLeft, paddingTop, paddingRight, paddingBottom + height)
        addView(group, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height, Gravity.BOTTOM).apply { bottomMargin = -height })
        scopeBar = group
    }

    private fun updateCancelButtonEnabled() {
        cancelButton.isEnabled = alwaysEnablesCancelButton || textField.hasFocus()
    }

    /**
     * The merged default style (iOS `appearanceStyle`): applying it sets the properties it covers; a property set
     * after it wins. Null until set; `applyDefaultAppearance` sets the default.
     */
    var appearanceStyle: CYLSearchBarAppearance? = null
        set(value) {
            field = value
            value?.applyTo(this)
        }

    /**
     * Applies `CYLSearchBarAppearance.defaultAppearance` (iOS `applyDefaultAppearance`).
     */
    fun applyDefaultAppearance() {
        appearanceStyle = CYLSearchBarAppearance.defaultAppearance(context)
    }

    /**
     * Shows or hides the view before the field, with an animation when `animated` is true (iOS
     * `setShowsLeadingView(_:animated:)`). The last call decides: two quick calls end in the state of the second.
     */
    fun setShowsLeadingView(shows: Boolean, animated: Boolean) {
        leadingShown = shows
        syncAccessories(animated)
    }

    /**
     * Shows or hides `trailingAccessoryViews`, with an animation when `animated` is true (iOS
     * `setShowsTrailingAccessoryViews(_:animated:)`). The last call decides.
     */
    fun setShowsTrailingAccessoryViews(shows: Boolean, animated: Boolean) {
        trailingShown = shows
        syncAccessories(animated)
    }

    /**
     * The same as `setShowsLeadingView`.
     */
    @Deprecated("Use setShowsLeadingView.", ReplaceWith("setShowsLeadingView(shows, animated)"))
    fun setShowsLeadingAccessoryView(shows: Boolean, animated: Boolean) = setShowsLeadingView(shows, animated)

    /**
     * The same as `setShowsTrailingAccessoryViews`.
     */
    @Deprecated("Use setShowsTrailingAccessoryViews.", ReplaceWith("setShowsTrailingAccessoryViews(shows, animated)"))
    fun setShowsTrailingAccessoryView(shows: Boolean, animated: Boolean) = setShowsTrailingAccessoryViews(shows, animated)

    /**
     * Shows or hides Cancel, with an animation when `animated` is true (iOS `setShowsCancelButton(_:animated:)`).
     */
    fun setShowsCancelButton(shows: Boolean, animated: Boolean) {
        animatesCancel = animated
        showsCancelButton = shows
        animatesCancel = false
    }

    private fun syncAccessories(animated: Boolean) {
        leadingSlot.set(leadingShown && (leadingView != null || showsNavigationButton), animated)
        trailingViewsSlot.set(trailingShown && trailingAccessoryViews.isNotEmpty(), animated)
    }

    private fun syncCancelButton(animated: Boolean) {
        val onScreen = !isIconified && mode != CYLSearchBarMode.Multiple
        cancelSlot.set(onScreen && (showsCancelButton || (showsCancelButtonWhenEditing && isActive)), animated)
    }

    private fun applyActiveState() {
        val active = isActive
        val field = textFieldMarginsProvider?.invoke(this, active) ?: textFieldMargins
        (fieldView.layoutParams as? LinearLayout.LayoutParams)?.let {
            it.marginStart = dp(field.left.toFloat())
            it.topMargin = dp(field.top.toFloat())
            it.marginEnd = dp(field.right.toFloat())
            it.bottomMargin = dp(field.bottom.toFloat())
            fieldView.layoutParams = it
        }
        val cancel = cancelButtonMarginsProvider?.invoke(this, active) ?: cancelButtonMargins
        (cancelButton.layoutParams as? LinearLayout.LayoutParams)?.let {
            it.marginStart = max(0, dp(SPACING) + dp(cancel.left.toFloat()))
            it.topMargin = max(0, dp(cancel.top.toFloat()))
            it.marginEnd = max(0, dp(cancel.right.toFloat()))
            it.bottomMargin = max(0, dp(cancel.bottom.toFloat()))
            cancelButton.layoutParams = it
        }
        updatePlaceholderCentering()
        syncCancelButton(isAttachedToWindow)
    }

    private fun updatePlaceholderCentering() {
        val centered = centersPlaceholder && !isActive && text.isNullOrEmpty()
        val params = textContainer.layoutParams as? LinearLayout.LayoutParams ?: return
        val width = if (centered) LayoutParams.WRAP_CONTENT else 0
        val weight = if (centered) 0f else 1f
        if (params.width == width && params.weight == weight) {
            return
        }
        if (isAttachedToWindow) {
            android.transition.TransitionManager.beginDelayedTransition(fieldView)
        }
        params.width = width
        params.weight = weight
        textContainer.layoutParams = params
        fieldView.gravity = if (centered) Gravity.CENTER else Gravity.CENTER_VERTICAL
    }

    /**
     * Shows and hides one view beside the field (an accessory view, Cancel): its width and alpha animate together, and
     * a state flag, not the visibility, decides, so quick toggles end in the requested state (QMUI's guard).
     */
    private inner class AccessorySlot(val view: View) {
        var target = false
            private set
        private var progress = 0f
        private var animator: android.animation.ValueAnimator? = null

        fun set(shows: Boolean, animated: Boolean) {
            if (shows == target && (animator != null || (view.visibility == VISIBLE) == shows)) {
                return
            }
            target = shows
            animator?.cancel()
            if (!animated || !isAttachedToWindow || !view.isLaidOut) {
                finish()
                return
            }
            view.visibility = VISIBLE
            view.measure(MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED)
            val full = view.measuredWidth
            val running = android.animation.ValueAnimator.ofFloat(progress, if (shows) 1f else 0f)
            running.duration = 250
            running.addUpdateListener {
                progress = it.animatedValue as Float
                view.alpha = progress
                view.layoutParams = view.layoutParams.also { params -> params.width = (full * progress).toInt() }
            }
            running.addListener(object : AnimatorListenerAdapter() {
                private var cancelled = false

                override fun onAnimationCancel(animation: Animator) {
                    cancelled = true
                }

                override fun onAnimationEnd(animation: Animator) {
                    if (!cancelled) {
                        animator = null
                        finish()
                    }
                }
            })
            animator = running
            running.start()
        }

        private fun finish() {
            animator = null
            progress = if (target) 1f else 0f
            view.alpha = 1f
            view.layoutParams = view.layoutParams.also { it.width = LayoutParams.WRAP_CONTENT }
            view.visibility = if (target) VISIBLE else GONE
        }
    }

    init {
        addView(focusSink, LayoutParams(1, 1))
        row.orientation = LinearLayout.HORIZONTAL
        row.gravity = Gravity.CENTER_VERTICAL
        addView(row, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL))
        row.addView(leadingContainer, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT))
        leadingContainer.addView(navigationButton)
        navigationButton.visibility = GONE
        navigationButton.setOnClickListener { navigationTapped() }

        fieldView.orientation = LinearLayout.HORIZONTAL
        fieldView.gravity = Gravity.CENTER_VERTICAL
        fieldView.background = fieldBackground
        row.addView(fieldView, LinearLayout.LayoutParams(0, LayoutParams.WRAP_CONTENT, 1f))
        searchIconView.scaleType = ImageView.ScaleType.FIT_CENTER
        searchIconView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        fieldView.addView(searchIconView)
        fieldView.addView(textContainer, LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
        placeholderLabel.maxLines = 1
        placeholderLabel.ellipsize = TextUtils.TruncateAt.END
        placeholderLabel.gravity = Gravity.CENTER_VERTICAL or Gravity.START
        placeholderLabel.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        textContainer.addView(placeholderLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        textField.background = null
        textField.setPadding(0, 0, 0, 0)
        textField.isSingleLine = true
        textField.gravity = Gravity.CENTER_VERTICAL or Gravity.START
        textField.textAlignment = TEXT_ALIGNMENT_VIEW_START
        textField.imeOptions = EditorInfo.IME_ACTION_SEARCH or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        textField.contentDescription = CYLSearchResources.localizedString(context, "search.field")
        textContainer.addView(textField, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        fieldView.addView(accessoryContainer, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        accessoryContainer.orientation = LinearLayout.HORIZONTAL
        accessoryContainer.gravity = Gravity.CENTER_VERTICAL
        trailingViewsContainer.orientation = LinearLayout.HORIZONTAL
        trailingViewsContainer.gravity = Gravity.CENTER_VERTICAL
        accessoryContainer.addView(trailingViewsContainer, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        voiceButton.contentDescription = CYLSearchResources.localizedString(context, "search.voice")
        voiceButton.setOnClickListener { delegate?.searchBarViewVoiceButtonClicked(this) }
        submitButton.contentDescription = CYLSearchResources.localizedString(context, "search.submit")
        submitButton.setOnClickListener { submit() }
        clearButton.contentDescription = CYLSearchResources.localizedString(context, "search.clear")
        clearButton.setOnClickListener { clearTapped() }
        fieldView.addView(clearButton)

        cancelButton.visibility = GONE
        cancelButton.gravity = Gravity.CENTER
        cancelButton.maxLines = 1
        cancelButton.setOnClickListener { cancelTapped() }
        cancelButton.isClickable = true
        cancelButton.isFocusable = true
        row.addView(cancelButton, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))

        iconButton.visibility = GONE
        iconButton.contentDescription = CYLSearchResources.localizedString(context, "search.field")
        iconButton.setOnClickListener { setIconified(false, true) }
        addView(iconButton)
        addView(multiSearchContent, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER_VERTICAL))

        textField.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) {
                if (!settingText) {
                    textChanged()
                }
            }
        })
        textField.setOnEditorActionListener { _, actionId, event ->
            val enter = event != null && event.keyCode == KeyEvent.KEYCODE_ENTER && event.action == KeyEvent.ACTION_DOWN
            if (actionId == returnKeyType || actionId == EditorInfo.IME_ACTION_SEARCH || enter) {
                if (isEditingBar) submitEditing() else submit()
                true
            } else {
                false
            }
        }
        textField.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_UP && !textField.hasFocus() && delegate?.searchBarViewShouldBeginEditing(this) == false) {
                delegate?.searchBarViewDidTapWhileNotEditable(this)
                true
            } else {
                false
            }
        }
        // A field that is not being edited shows no caret (a steady caret was seen in the idle bar after the search closed).
        textField.isCursorVisible = false
        textField.setOnFocusChangeListener { _, focused ->
            textField.isCursorVisible = focused
            if (focused) didBeginEditing() else didEndEditing()
        }
        applyInputType()
        updateButtonImages()
        applyStyle()
        applyLayout()
        textStateChanged()
    }

    private fun iconButton(): ImageButton = ImageButton(context).apply {
        setBackgroundResource(TypedValue().also {
            context.theme.resolveAttribute(android.R.attr.selectableItemBackgroundBorderless, it, true)
        }.resourceId)
        scaleType = ImageView.ScaleType.CENTER_INSIDE
        val padding = (4 * resources.displayMetrics.density).toInt()
        setPadding(padding, padding, padding, padding)
    }

    private fun dp(value: Float): Int = (value * density + 0.5f).toInt()

    private fun themeColor(attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    // Text and keyboard

    /**
     * Sets the text and, when `submit` is true and the text is not empty, submits it as if the search key were tapped
     * (MaterialSearchView `setQuery`, lapism `setTextQuery`).
     */
    fun setText(text: String?, submit: Boolean) {
        this.text = text
        if (submit) {
            submit()
        }
    }

    /**
     * Submits the current text: asks `searchBarViewShouldSubmitText`, then calls `searchBarViewSearchButtonClicked`.
     * Returns false when the text is empty or the delegate refused it.
     */
    fun submit(): Boolean {
        val current = text.orEmpty()
        if (current.isBlank()) {
            return false
        }
        if (delegate?.searchBarViewShouldSubmitText(this, current) == false) {
            return false
        }
        delegate?.searchBarViewSearchButtonClicked(this)
        return true
    }

    /**
     * Starts editing and shows the keyboard. When `searchBarViewShouldBeginEditing` refuses, reports a tap instead.
     */
    fun showKeyboard() {
        if (delegate?.searchBarViewShouldBeginEditing(this) == false) {
            delegate?.searchBarViewDidTapWhileNotEditable(this)
            return
        }
        textField.requestFocus()
        textField.post {
            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
                .showSoftInput(textField, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    /**
     * Ends editing and hides the keyboard.
     */
    fun hideKeyboard() {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
            .hideSoftInputFromWindow(textField.windowToken, 0)
        textField.clearFocus()
        // Android gives the focus back to the only focusable view: the field would stay active after Cancel.
        if (textField.hasFocus()) {
            focusSink.requestFocus()
        }
    }

    private fun applyInputType() {
        var type = keyboardType
        if (type and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_TEXT) {
            type = type or when (autocapitalizationType) {
                CYLTextAutocapitalizationType.None -> 0
                CYLTextAutocapitalizationType.Words -> InputType.TYPE_TEXT_FLAG_CAP_WORDS
                CYLTextAutocapitalizationType.Sentences -> InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
                CYLTextAutocapitalizationType.AllCharacters -> InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS
            }
            type = type or when (autocorrectionType) {
                CYLTextAutocorrectionType.Default -> 0
                CYLTextAutocorrectionType.No -> InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
                CYLTextAutocorrectionType.Yes -> InputType.TYPE_TEXT_FLAG_AUTO_CORRECT
            }
            if (isSecureTextEntry) {
                type = (type and InputType.TYPE_MASK_VARIATION.inv()) or InputType.TYPE_TEXT_VARIATION_PASSWORD
            }
        }
        val typeface = textField.typeface
        textField.inputType = type
        textField.isSingleLine = true
        textField.typeface = typeface
        multiSearchContent.applyStyle()
    }

    // Buttons

    private val showsNavigationButton: Boolean
        get() = leadingView == null && (navigationImage != null || navigationIcon != CYLSearchBarNavigationIcon.None)

    private fun updateButtonImages() {
        val navigation = navigationImage ?: when (navigationIcon) {
            CYLSearchBarNavigationIcon.Arrow -> ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_arrow_back)
            CYLSearchBarNavigationIcon.Search -> ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
            CYLSearchBarNavigationIcon.None -> null
        }
        navigationButton.setImageDrawable(navigation)
        val circle = navigationBackgroundColor?.let { color ->
            GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(color) }
        }
        if (circle != null) {
            navigationButton.background = circle
        }
        navigationButton.elevation = navigationShadowOpacity * 6 * density
        navigationButton.contentDescription = navigationAccessibilityLabel
        voiceButton.setImageDrawable(voiceImage)
        submitButton.setImageDrawable(submitImage)
        clearButton.setImageDrawable(clearImage ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_clear))
        iconButton.setImageDrawable(searchIcon)
        searchIconView.setImageDrawable(searchIcon)
        searchIconView.visibility = if (searchIcon != null) VISIBLE else GONE
        applyIconifiedVisibility()
        applyStyle()
    }

    private fun updateAccessories() {
        // Everything but the container of `trailingAccessoryViews` (the first child) is rebuilt.
        if (accessoryContainer.childCount > 1) {
            accessoryContainer.removeViews(1, accessoryContainer.childCount - 1)
        }
        trailingViewsContainer.removeAllViews()
        val margins = trailingAccessoryViewMargins
        trailingAccessoryViews.forEach { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            val given = view.layoutParams
            trailingViewsContainer.addView(view, LinearLayout.LayoutParams(given?.width ?: LayoutParams.WRAP_CONTENT, given?.height ?: LayoutParams.WRAP_CONTENT).apply {
                setMargins(dp(SPACING + margins.left), dp(margins.top.toFloat()), dp(margins.right.toFloat()), dp(margins.bottom.toFloat()))
            })
        }
        syncAccessories(false)
        val hasText = !text.isNullOrEmpty()
        val views = itemViews.toMutableList<View>()
        if (showsVoiceButton && !hasText) {
            views.add(voiceButton)
        }
        if (showsSubmitButton && hasText) {
            views.add(submitButton)
        }
        views.forEach { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            // A view keeps the size it was given (a 1 dp divider); otherwise it wraps its content.
            val given = view.layoutParams
            accessoryContainer.addView(view, LinearLayout.LayoutParams(given?.width ?: LayoutParams.WRAP_CONTENT, given?.height ?: LayoutParams.WRAP_CONTENT).apply {
                marginStart = dp(SPACING)
            })
        }
    }

    // Iconified

    /**
     * Opens or closes the field, with `expansionAnimation` when `animated` is true. Opening also starts editing.
     */
    fun setIconified(iconified: Boolean, animated: Boolean) {
        if (iconifiedState == iconified) {
            if (!iconified && animated) {
                showKeyboard()
            }
            return
        }
        iconifiedState = iconified
        if (iconified) {
            hideKeyboard()
        }
        if (!animated || animationDuration <= 0 || !isAttachedToWindow || width == 0) {
            applyIconifiedVisibility()
            if (!iconified && animated) {
                showKeyboard()
            }
            notifyIconified()
            return
        }
        // Both are visible during the animation; the field animates from (or to) the icon's center.
        fieldView.visibility = VISIBLE
        iconButton.visibility = VISIBLE
        row.visibility = VISIBLE
        val iconCenterX = iconButton.left + iconButton.width / 2f - (row.left + fieldView.left)
        val iconCenterY = iconButton.top + iconButton.height / 2f - (row.top + fieldView.top)
        val duration = (animationDuration * 1000).toLong()
        val finish = {
            fieldView.alpha = 1f
            fieldView.scaleX = 1f
            iconButton.alpha = 1f
            applyIconifiedVisibility()
            if (!iconified) {
                showKeyboard()
            }
            notifyIconified()
        }
        iconButton.animate().alpha(if (iconified) 1f else 0f).setDuration(duration).start()
        if (expansionAnimation == CYLSearchBarExpansionAnimation.CircularReveal) {
            val radius = hypot(max(iconCenterX, fieldView.width - iconCenterX), max(iconCenterY, fieldView.height - iconCenterY))
            val small = max(iconButton.width, iconButton.height) / 2f
            val reveal = ViewAnimationUtils.createCircularReveal(
                fieldView, iconCenterX.toInt(), iconCenterY.toInt(), if (iconified) radius else small, if (iconified) small else radius,
            )
            reveal.duration = duration
            reveal.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) = finish()
            })
            reveal.start()
        } else {
            fieldView.pivotX = iconCenterX
            fieldView.alpha = if (iconified) 1f else 0f
            fieldView.scaleX = if (iconified) 1f else 0.1f
            fieldView.animate().alpha(if (iconified) 0f else 1f).scaleX(if (iconified) 0.1f else 1f).setDuration(duration)
                .withEndAction { finish() }.start()
        }
    }

    private fun applyIconifiedVisibility() {
        if (mode == CYLSearchBarMode.Multiple) {
            // The searches replace the field, its buttons and the iconified button.
            row.visibility = GONE
            iconButton.visibility = GONE
            syncCancelButton(false)
            syncAccessories(false)
            return
        }
        row.visibility = VISIBLE
        fieldView.visibility = if (isIconified) INVISIBLE else VISIBLE
        iconButton.visibility = if (isIconified) VISIBLE else GONE
        syncCancelButton(animatesCancel && isAttachedToWindow)
        syncAccessories(false)
        navigationButton.visibility = if (isIconified || !showsNavigationButton) GONE else VISIBLE
        leadingView?.visibility = if (isIconified) GONE else VISIBLE
    }

    private fun notifyIconified() {
        (if (isIconified) iconButton else textField).sendAccessibilityEvent(android.view.accessibility.AccessibilityEvent.TYPE_VIEW_FOCUSED)
        delegate?.searchBarViewDidChangeIconified(this, isIconified)
    }

    // State restoration

    override fun onSaveInstanceState(): Parcelable = Bundle().apply {
        putParcelable(STATE_SUPER, super.onSaveInstanceState())
        putString(STATE_TEXT, text.orEmpty())
        putBoolean(STATE_EDITING, textField.hasFocus())
        putBoolean(STATE_ICONIFIED, isIconified)
    }

    @Suppress("DEPRECATION")
    override fun onRestoreInstanceState(state: Parcelable?) {
        if (state !is Bundle) {
            super.onRestoreInstanceState(state)
            return
        }
        super.onRestoreInstanceState(state.getParcelable(STATE_SUPER))
        text = state.getString(STATE_TEXT)
        setIconified(state.getBoolean(STATE_ICONIFIED), false)
        if (state.getBoolean(STATE_EDITING)) {
            post { showKeyboard() }
        }
    }

    override fun dispatchSaveInstanceState(container: android.util.SparseArray<Parcelable>) = dispatchFreezeSelfOnly(container)

    override fun dispatchRestoreInstanceState(container: android.util.SparseArray<Parcelable>) = dispatchThawSelfOnly(container)

    // Style

    private fun applyStyle() {
        val size = fontSize
        val primary = textColor ?: themeColor(android.R.attr.textColorPrimary)
        // The secondary label color, not the platform's dim hint color; also on the field itself, for a host that sets its hint directly.
        val hint = placeholderColor ?: secondaryLabelColor(context)
        val secondary = searchIconTintColor ?: themeColor(android.R.attr.textColorSecondary)
        textField.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        textField.typeface = font ?: Typeface.DEFAULT
        textField.setTextColor(primary)
        placeholderLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        placeholderLabel.typeface = font ?: Typeface.DEFAULT
        placeholderLabel.setTextColor(hint)
        textField.setHintTextColor(hint)
        cancelButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, cancelButtonFontSize ?: size)
        cancelButton.typeface = cancelButtonFont ?: font ?: Typeface.DEFAULT
        cancelButton.setTextColor(tintColor ?: themeColor(android.R.attr.colorAccent))
        cancelButton.text = cancelButtonTitle
        cancelButton.contentDescription = cancelButtonTitle
        if (android.os.Build.VERSION.SDK_INT >= 29) {
            (cursorColor ?: tintColor)?.let { textField.textCursorDrawable?.setTint(it) }
        }
        fieldBackground.setColor(fieldBackgroundColor ?: DEFAULT_FIELD_COLOR)
        val border = fieldBorderColor
        fieldBackground.setStroke(if (border != null) dp(fieldBorderWidth) else 0, border ?: Color.TRANSPARENT)
        fieldView.elevation = fieldShadowOpacity * 6 * density
        val tint = ColorStateList.valueOf(secondary)
        listOf<ImageView>(searchIconView, iconButton, voiceButton, clearButton, submitButton, navigationButton).forEach {
            ImageViewCompat.setImageTintList(it, tint)
        }
        multiSearchContent.applyStyle()
        applyLayout()
    }

    /** The field's height as `applyLayout` set it, px; `onMeasure` shortens the field when the host gives the bar less. */
    private var wantedFieldPixels = 0

    /**
     * The field never gets taller than the bar: a host that is shorter than the field plus `contentInsets` (a 44 dp toolbar
     * slot of a Flutter or React Native page) first takes the space from the insets above and below the field, then from the
     * field; before, the field kept its height and the host clipped its top and bottom edges, so the border showed only
     * as the two side arcs.
     */
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val available = MeasureSpec.getSize(heightMeasureSpec)
        if (wantedFieldPixels > 0 && MeasureSpec.getMode(heightMeasureSpec) != MeasureSpec.UNSPECIFIED) {
            var top = dp(contentInsets.top.toFloat())
            var bottom = dp(contentInsets.bottom.toFloat())
            var height = wantedFieldPixels
            if (available < height + top + bottom) {
                val room = available - height
                if (room >= 0) {
                    top = room / 2
                    bottom = room - top
                } else {
                    top = 0
                    bottom = 0
                    height = max(0, available)
                }
            }
            // Embedded in a toolbar: after a back arrow the bar starts where the toolbar's content starts (EMBEDDED_BAR_START) and the host's left inset adds
            // nothing (the native example's 16 dp and the Flutter plugin's default 12 dp gave 72 dp and 84 dp before: the same bar, two positions); without an
            // arrow, and at the end, the host's inset counts, the default 12 dp becoming the 16 dp inset of the tag list.
            var start = row.paddingStart
            var end = row.paddingEnd
            if (embedsInToolbar) {
                val hasArrow = (parent as? androidx.appcompat.widget.Toolbar)?.navigationIcon != null
                start = if (hasArrow) 0 else if (contentInsets.left == DEFAULT_CONTENT_INSETS.left) dp(EMBEDDED_TAG_INSET) else dp(contentInsets.left.toFloat())
                end = if (contentInsets.right == DEFAULT_CONTENT_INSETS.right) dp(EMBEDDED_TAG_INSET) else dp(contentInsets.right.toFloat())
            }
            if (row.paddingTop != top || row.paddingBottom != bottom || row.paddingStart != start || row.paddingEnd != end) row.setPaddingRelative(start, top, end, bottom)
            (fieldView.layoutParams as? LinearLayout.LayoutParams)?.let {
                if (it.height != height) {
                    it.height = height
                    fieldView.layoutParams = it
                }
            }
            fieldBackground.cornerRadius = if (fieldCornerRadius < 0) height / 2f else dp(fieldCornerRadius).toFloat()
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    }

    private fun applyLayout() {
        val fieldPixels = max(dp(fieldHeight), (fontSize * resources.displayMetrics.scaledDensity * 1.2f + 12 * density).toInt())
        wantedFieldPixels = fieldPixels
        row.setPaddingRelative(dp(contentInsets.left.toFloat()), dp(contentInsets.top.toFloat()), dp(contentInsets.right.toFloat()), dp(contentInsets.bottom.toFloat()))
        (fieldView.layoutParams as? LinearLayout.LayoutParams)?.let { it.height = fieldPixels; fieldView.layoutParams = it }
        fieldBackground.cornerRadius = if (fieldCornerRadius < 0) fieldPixels / 2f else dp(fieldCornerRadius).toFloat()
        val inner = dp(max(10f, minOf(14f, fieldHeight / 3)))
        fieldView.setPaddingRelative(inner, 0, inner - dp(4f), 0)
        searchIconView.layoutParams = LinearLayout.LayoutParams(dp(ICON_SIZE), dp(ICON_SIZE)).apply { marginEnd = dp(6f) }
        val buttonSide = dp(30f)
        clearButton.layoutParams = LinearLayout.LayoutParams(buttonSide, buttonSide)
        val touch = max(dp(44f), fieldPixels)
        leadingContainer.layoutParams = LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
            marginStart = -dp(8f)
            marginEnd = dp(2f)
        }
        navigationButton.layoutParams = LayoutParams(touch, touch)
        (cancelButton.layoutParams as? LinearLayout.LayoutParams)?.let {
            it.marginStart = dp(SPACING)
            it.height = fieldPixels
            cancelButton.layoutParams = it
        }
        cancelButton.minWidth = dp(44f)
        cancelButton.setPadding(dp(4f), 0, dp(4f), 0)
        iconButton.layoutParams = LayoutParams(touch, touch, Gravity.CENTER_VERTICAL or when (iconPosition) {
            CYLSearchBarIconPosition.Trailing -> Gravity.END
            CYLSearchBarIconPosition.Center -> Gravity.CENTER_HORIZONTAL
            CYLSearchBarIconPosition.Leading -> Gravity.START
        }).apply {
            marginStart = dp(contentInsets.left.toFloat())
            marginEnd = dp(contentInsets.right.toFloat())
        }
        minimumHeight = fieldPixels + dp((contentInsets.top + contentInsets.bottom).toFloat())
        multiSearchContent.setPaddingRelative(dp(contentInsets.left.toFloat()), 0, dp(contentInsets.right.toFloat()), 0)
        applyActiveState()
    }

    // Events

    private fun textStateChanged() {
        val empty = text.isNullOrEmpty()
        placeholderLabel.visibility = if (empty) VISIBLE else INVISIBLE
        updatePlaceholderCentering()
        clearButton.visibility = if (empty || !textField.hasFocus()) GONE else VISIBLE
        updateAccessories()
    }

    private fun textChanged() {
        textStateChanged()
        delegate?.searchBarViewTextDidChange(this, text.orEmpty())
    }

    private fun cancelTapped() {
        if (isEditingBar) {
            // An editing bar's trailing button is its action, not a cancel (iOS `cancelTapped`).
            submitEditing()
            return
        }
        if (clearsTextOnCancel && !text.isNullOrEmpty()) {
            text = ""
            textChanged()
        }
        if (cancelButtonEndsEditing) {
            hideKeyboard()
        }
        delegate?.searchBarViewCancelButtonClicked(this)
    }

    private fun navigationTapped() {
        delegate?.searchBarViewNavigationButtonClicked(this)
        navigationHandler?.invoke(this)
    }

    private fun clearTapped() {
        text = ""
        textChanged()
    }

    private fun didBeginEditing() {
        if (delegate?.searchBarViewShouldBeginEditing(this) == false) {
            textField.clearFocus()
            return
        }
        textStateChanged()
        applyActiveState()
        updateCancelButtonEnabled()
        delegate?.searchBarViewDidBeginEditing(this)
    }

    private fun didEndEditing() {
        if (clearsTextOnEndEditing && !text.isNullOrEmpty()) {
            text = ""
            textChanged()
        }
        textStateChanged()
        applyActiveState()
        updateCancelButtonEnabled()
        if (iconifiedByDefault && text.isNullOrEmpty() && !isIconified) {
            setIconified(true, true)
        }
        delegate?.searchBarViewDidEndEditing(this)
    }

    /**
     * Starts editing in the text field (iOS `becomeFirstResponder`).
     */
    override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean = textField.requestFocus(direction, previouslyFocusedRect)

    /**
     * Ends editing in the text field and hides the keyboard (iOS `resignFirstResponder`).
     */
    override fun clearFocus() {
        hideKeyboard()
        super.clearFocus()
    }

    /**
     * The content of `Multiple` mode (a private helper, was iOS `CYLMultiSearchView`; iammert `MultiSearchView`): a
     * horizontally scrolling row of searches, an indicator under the selected one, and `newSearchButton` at the end.
     */
    private inner class MultiSearchContent(context: Context) : LinearLayout(context) {

        private inner class SearchItem(context: Context) : FrameLayout(context) {
            val textField = EditText(context)
            val removeButton = ImageButton(context)
            val indicator = View(context)
            var editing = false
            var reportedText = ""
        }

        private val bar: CYLSearchBarView
            get() = this@CYLSearchBarView
        private val scrollView = HorizontalScrollView(context)
        private val itemsView = LinearLayout(context)
        private val items = mutableListOf<SearchItem>()

        var selectedIndex: Int = NO_SELECTION
            private set

        var isInSearchMode: Boolean = false
            private set(value) {
                field = value
                bar.multiSearchBackCallback.isEnabled = value && bar.mode == CYLSearchBarMode.Multiple
            }

        val searchTexts: List<String>
            get() = items.map { it.textField.text.toString() }

        init {
            orientation = HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            minimumHeight = dp(56f)
            visibility = GONE
            scrollView.isHorizontalScrollBarEnabled = false
            scrollView.isFillViewport = false
            itemsView.orientation = HORIZONTAL
            scrollView.addView(itemsView, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT))
            addView(scrollView, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
            val button = bar.newSearchButton
            button.setBackgroundResource(TypedValue().also {
                context.theme.resolveAttribute(android.R.attr.selectableItemBackgroundBorderless, it, true)
            }.resourceId)
            button.contentDescription = CYLSearchResources.localizedString(context, "multisearch.add")
            button.setOnClickListener { if (isInSearchMode) completeSearch() else search() }
            addView(button, LinearLayout.LayoutParams(dp(48f), dp(48f)))
        }

        fun applyStyle() {
            val accent = bar.searchIndicatorColor ?: themeColor(android.R.attr.colorAccent)
            bar.newSearchButton.setImageDrawable(bar.newSearchImage)
            ImageViewCompat.setImageTintList(bar.newSearchButton, ColorStateList.valueOf(accent))
            items.forEachIndexed { index, item -> style(item, index == selectedIndex, accent) }
        }

        private fun style(item: SearchItem, selected: Boolean, accent: Int) {
            val field = item.textField
            field.setTextSize(TypedValue.COMPLEX_UNIT_SP, bar.fontSize)
            field.typeface = bar.font ?: Typeface.DEFAULT
            field.setTextColor(bar.textColor ?: themeColor(android.R.attr.textColorPrimary))
            field.setHintTextColor(bar.placeholderColor ?: secondaryLabelColor(context))
            field.hint = bar.placeholder ?: CYLSearchResources.localizedString(context, "search.field")
            field.imeOptions = bar.returnKeyType or EditorInfo.IME_FLAG_NO_EXTRACT_UI
            var type = bar.keyboardType
            if (type and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_TEXT) {
                type = type or when (bar.autocapitalizationType) {
                    CYLTextAutocapitalizationType.None -> 0
                    CYLTextAutocapitalizationType.Words -> InputType.TYPE_TEXT_FLAG_CAP_WORDS
                    CYLTextAutocapitalizationType.Sentences -> InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
                    CYLTextAutocapitalizationType.AllCharacters -> InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS
                }
            }
            field.inputType = type
            field.isSingleLine = true
            val limit = bar.maximumTextLength
            field.filters = if (limit > 0) arrayOf(InputFilter.LengthFilter(limit)) else emptyArray()
            field.alpha = if (selected || item.editing) 1f else bar.unselectedSearchAlpha
            field.isFocusableInTouchMode = item.editing
            field.isCursorVisible = item.editing
            item.removeButton.setImageDrawable(bar.removeSearchImage)
            ImageViewCompat.setImageTintList(item.removeButton, ColorStateList.valueOf(themeColor(android.R.attr.textColorSecondary)))
            item.removeButton.visibility = if (selected && !item.editing) VISIBLE else GONE
            item.indicator.setBackgroundColor(accent)
            item.indicator.visibility = if (selected || item.editing) VISIBLE else INVISIBLE
            field.minWidth = if (item.editing) dp(bar.searchFieldWidth) else 0
            field.maxWidth = if (item.editing) dp(bar.searchFieldWidth) else Int.MAX_VALUE
            (field.layoutParams as? FrameLayout.LayoutParams)?.let {
                it.width = FrameLayout.LayoutParams.WRAP_CONTENT
                it.marginEnd = if (item.removeButton.visibility == VISIBLE) dp(REMOVE_SIZE) else 0
                field.layoutParams = it
            }
            if (!item.editing) {
                val index = items.indexOf(item)
                field.contentDescription = context.getString(R.string.cyl_multisearch_item, index + 1, items.size)
                field.isSelected = selected
            } else {
                field.contentDescription = null
            }
        }

        private fun newItem(): SearchItem {
            val item = SearchItem(context)
            val padding = dp(ITEM_PADDING)
            item.setPaddingRelative(padding, 0, padding, 0)
            item.textField.background = null
            item.textField.setPadding(0, 0, 0, 0)
            item.textField.gravity = Gravity.CENTER_VERTICAL or Gravity.START
            item.addView(item.textField, FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.MATCH_PARENT))
            item.removeButton.background = null
            item.removeButton.contentDescription = CYLSearchResources.localizedString(context, "multisearch.remove")
            item.removeButton.setOnClickListener { items.indexOf(item).takeIf { it >= 0 }?.let { removeItemAtIndex(it) } }
            item.addView(item.removeButton, FrameLayout.LayoutParams(dp(REMOVE_SIZE), dp(REMOVE_SIZE), Gravity.END or Gravity.CENTER_VERTICAL))
            item.addView(item.indicator, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, dp(INDICATOR_HEIGHT), Gravity.BOTTOM))
            item.textField.addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
                override fun afterTextChanged(s: Editable?) {
                    val index = items.indexOf(item)
                    // Restyling the field (input type, filters) also runs the watcher: report only real edits, as iOS.
                    if (index >= 0 && item.editing && s.toString() != item.reportedText) {
                        item.reportedText = s.toString()
                        bar.delegate?.searchBarViewTextDidChange(bar, s.toString(), index)
                    }
                }
            })
            item.textField.setOnEditorActionListener { _, _, _ ->
                completeSearch()
                true
            }
            val select = View.OnClickListener {
                val index = items.indexOf(item)
                if (!item.editing && index >= 0 && index != selectedIndex) {
                    selectItemAtIndex(index)
                }
            }
            item.setOnClickListener(select)
            item.textField.setOnClickListener(select)
            return item
        }

        fun search() {
            if (isInSearchMode) {
                return
            }
            isInSearchMode = true
            selectedIndex = NO_SELECTION
            val item = newItem()
            item.editing = true
            items.add(item)
            itemsView.addView(item, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT))
            applyStyle()
            item.alpha = 0f
            item.animate().alpha(1f).setDuration((bar.animationDuration * 1000).toLong()).start()
            scrollTo(item)
            item.textField.requestFocus()
            item.textField.post {
                (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
                    .showSoftInput(item.textField, InputMethodManager.SHOW_IMPLICIT)
            }
        }

        fun completeSearch() {
            val item = items.lastOrNull()
            if (!isInSearchMode || item == null) {
                return
            }
            isInSearchMode = false
            item.editing = false
            hideKeyboard(item)
            val text = item.textField.text.toString()
            if (text.isEmpty() || text.length < bar.minimumTextLength) {
                remove(item, false)
                return
            }
            val index = items.size - 1
            selectedIndex = index
            applyStyle()
            bar.delegate?.searchBarViewDidCompleteSearch(bar, text, index)
        }

        fun addSearchText(text: String) {
            if (text.isEmpty()) {
                return
            }
            if (isInSearchMode) {
                completeSearch()
            }
            val limit = bar.maximumTextLength
            val item = newItem()
            item.textField.setText(if (limit > 0 && text.length > limit) text.take(limit) else text)
            items.add(item)
            itemsView.addView(item, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT))
            selectedIndex = items.size - 1
            applyStyle()
            scrollTo(item)
        }

        fun selectItemAtIndex(index: Int) {
            if (index !in items.indices || items[index].editing) {
                return
            }
            if (isInSearchMode) {
                completeSearch()
            }
            if (index !in items.indices) {
                return
            }
            selectedIndex = index
            applyStyle()
            scrollTo(items[index])
            bar.delegate?.searchBarViewDidSelectSearch(bar, items[index].textField.text.toString(), index)
        }

        fun removeItemAtIndex(index: Int) {
            if (index in items.indices) {
                remove(items[index], true)
            }
        }

        private fun remove(item: SearchItem, notify: Boolean) {
            val index = items.indexOf(item)
            if (index < 0) {
                return
            }
            if (item.editing) {
                isInSearchMode = false
            }
            hideKeyboard(item)
            itemsView.removeView(item)
            items.removeAt(index)
            // As in MultiSearchView: the next search is selected, or the previous one when the last went away.
            selectedIndex = when {
                items.isEmpty() -> NO_SELECTION
                selectedIndex == index || selectedIndex == NO_SELECTION -> minOf(index, items.size - 1)
                selectedIndex > index -> selectedIndex - 1
                else -> selectedIndex
            }
            applyStyle()
            if (notify) {
                bar.delegate?.searchBarViewDidRemoveSearchAtIndex(bar, index)
            }
        }

        private fun hideKeyboard(item: SearchItem) {
            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
                .hideSoftInputFromWindow(item.textField.windowToken, 0)
            item.textField.clearFocus()
        }

        private fun scrollTo(item: SearchItem) {
            scrollView.post { scrollView.smoothScrollTo(item.left, 0) }
        }
    }

    // Navigation bar

    /**
     * Puts this bar into `toolbar` as a custom view that FILLS the space between the navigation icon (the back arrow) and the
     * end of the toolbar: the core sizes it (match parent width inside the Toolbar, which measures a custom view in what the
     * navigation button and the menu leave), never the page. A page that has a back arrow passes no width, margin or padding
     * (docs/animated-icon-component.md, "The adaptive width is the core's job"; iOS `embedInNavigationBar(of:)`). The bar leaves
     * the parent it had. Returns `toolbar` for chaining.
     */
    fun embedInToolbar(toolbar: androidx.appcompat.widget.Toolbar): androidx.appcompat.widget.Toolbar {
        (parent as? ViewGroup)?.removeView(this)
        embedsInToolbar = true
        // A navigation bar slot is 44 dp: the 36 dp field plus 4 dp above and below, not the 6 dp of a free bar (the border of a
        // taller bar was clipped top and bottom by the slot).
        contentInsets = Rect(contentInsets.left, TOOLBAR_VERTICAL_INSET, contentInsets.right, TOOLBAR_VERTICAL_INSET)
        // The toolbar's own start / end content insets (16 dp) would add to this bar's contentInsets and move the capsule off the
        // 16 dp inset of the tag list: the bar carries the inset itself.
        toolbar.setContentInsetsRelative(0, 0)
        // After a back arrow the toolbar starts its content at 72 dp (Material's keyline), 36 dp from the arrow's ink, the bar 84 dp (+ its own inset);
        // the bar starts at EMBEDDED_BAR_START instead.
        toolbar.contentInsetStartWithNavigation = (EMBEDDED_BAR_START * resources.displayMetrics.density).toInt()
        toolbar.addView(
            this,
            androidx.appcompat.widget.Toolbar.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER_VERTICAL,
            ),
        )
        return toolbar
    }

    /**
     * Same, for an activity: the existing action bar's toolbar (the AppCompat decor toolbar) when there is one, otherwise a
     * toolbar the core creates and inserts at the top of `content` (a vertical LinearLayout or any other ViewGroup, index 0).
     * After the call the bar always sits in a toolbar. Returns that toolbar.
     */
    fun embedInToolbar(activity: Activity, content: ViewGroup): androidx.appcompat.widget.Toolbar {
        val existing = activity.findViewById<androidx.appcompat.widget.Toolbar>(androidx.appcompat.R.id.action_bar)
        if (existing != null) {
            return embedInToolbar(existing)
        }
        val created = CYLSearchNavigationBar(activity)
        content.addView(
            created,
            0,
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT),
        )
        return embedInToolbar(created)
    }

    /**
     * True once `embedInToolbar` put this bar into a toolbar.
     */
    var embedsInToolbar: Boolean = false
        private set

    companion object {
        private const val NO_SELECTION = -1

        /** The navigation field preset's corner radius in dp. */
        internal const val NAVIGATION_FIELD_CORNER_RADIUS = 18f

        /** The navigation field preset's shadow opacity. */
        internal const val NAVIGATION_FIELD_SHADOW_OPACITY = 0.06f

        /** The navigation field preset's text size in sp. */
        internal const val NAVIGATION_FIELD_FONT_SIZE = 16f

        /**
         * The toolbar's vertical content inset in dp: 36 dp field + 2 x 4 dp = the 44 dp slot of a navigation bar, so the field's
         * border is not clipped by the slot (iOS `CYLSearchNavigationBar`).
         */
        internal const val TOOLBAR_VERTICAL_INSET = 4

        /**
         * The border of a bordered field, light and dark: iOS `UIColor.secondaryLabel` (60,60,67 at 60%; 235,235,245 at 60%), the same on every platform. The
         * earlier `.separator` (60,60,67 at 29%) was a 1.3:1 line on the page and hard to see; this one is about 3:1.
         */
        internal val BORDERED_BORDER_LIGHT = Color.argb(153, 60, 60, 67)
        internal val BORDERED_BORDER_DARK = Color.argb(153, 235, 235, 245)

        /**
         * Whether the page the bar is on is dark: the luminance of the theme's window background, so an app with a fixed light theme stays
         * light while the system is dark (the default colors never turn white on a light page, iOS: the view's own trait collection). The
         * resources' `uiMode` only decides when the theme has no background color.
         */
        internal fun isNight(context: Context): Boolean {
            val value = TypedValue()
            if (context.theme.resolveAttribute(android.R.attr.colorBackground, value, true) &&
                value.type >= TypedValue.TYPE_FIRST_COLOR_INT && value.type <= TypedValue.TYPE_LAST_COLOR_INT) {
                return androidx.core.graphics.ColorUtils.calculateLuminance(value.data) < DARK_BACKGROUND_LUMINANCE
            }
            return (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
                android.content.res.Configuration.UI_MODE_NIGHT_YES
        }

        private const val DARK_BACKGROUND_LUMINANCE = 0.5

        /** iOS `UIColor.label`: black in light mode, white in dark mode. The default color of an item without a tint of its own. */
        internal fun labelColor(context: Context): Int = if (isNight(context)) Color.WHITE else Color.BLACK

        /**
         * iOS `UIColor.secondaryLabel` (60,60,67 at 60% light, 235,235,245 at 60% dark): the default placeholder, the divider between items and the
         * bordered field's border, the same on every platform.
         */
        internal fun secondaryLabelColor(context: Context): Int = if (isNight(context)) BORDERED_BORDER_DARK else BORDERED_BORDER_LIGHT
        private const val SCOPE_BAR_HEIGHT = 36f
        private const val ITEM_PADDING = 12f
        private const val REMOVE_SIZE = 28f
        private const val INDICATOR_HEIGHT = 2f
        private const val ICON_SIZE = 18f
        private const val SPACING = 8f
        /** The inset of the tag list and its headers (16 dp, iOS 16 pt): the embedded bar's capsule edge sits on it where no back button is. */
        private const val EMBEDDED_TAG_INSET = 16f

        /**
         * Where the embedded bar starts after a back arrow, from the screen edge: 56 dp, 20.6 dp from the arrow's ink. The references: HarmonyOS 21.4 vp
         * (the bar at 40 vp), iOS 31 pt from the chevron (the bar at 73 pt, after the 44 pt glass back button that starts at 16 pt).
         */
        private const val EMBEDDED_BAR_START = 56f
        private val DEFAULT_CONTENT_INSETS = Rect(12, 6, 12, 6)
        private const val DEFAULT_FIELD_COLOR = 0x1F767680
        private const val STATE_SUPER = "CYLSearchBarSuper"
        private const val STATE_TEXT = "CYLSearchBarText"
        private const val STATE_EDITING = "CYLSearchBarEditing"
        private const val STATE_ICONIFIED = "CYLSearchBarIconified"

        /**
         * A drawable of a text field in `color`, for `fieldBackgroundImage` and `CYLSearchBarAppearance.textFieldBackgroundImage`
         * (QMUI `qmui_generateTextFieldBackgroundImageWithColor:`); null for a null color. The field clips its corners.
         */
        @JvmStatic
        fun textFieldBackgroundImage(color: Int?): Drawable? = color?.let { ColorDrawable(it) }

        /**
         * A drawable for the bar's `background`: `color` (white by default) with a one pixel bottom border in
         * `borderColor`, or null when both are null (QMUI `qmui_generateBackgroundImageWithColor:borderColor:`).
         */
        @JvmStatic
        fun backgroundImage(color: Int?, borderColor: Int?): Drawable? {
            if (color == null && borderColor == null) {
                return null
            }
            val fill = ColorDrawable(color ?: Color.WHITE)
            if (borderColor == null) {
                return fill
            }
            return LayerDrawable(arrayOf<Drawable>(fill, ColorDrawable(borderColor))).apply {
                setLayerGravity(1, Gravity.BOTTOM)
                setLayerHeight(1, 1)
            }
        }

        /**
         * An editing bar (iOS `editingBar(placeholder:actionTitle:)`): the search bar's field and look for editing a name
         * (a tag, a title), without the magnifier, with `actionTitle` ("Add", "Done") as its trailing button, which submits
         * through `editingSubmitHandler`, as the action key does. Words are capitalized and never autocorrected. Pin it
         * above the keyboard with `pinToKeyboard`; change `cancelButtonTitle` to change the action.
         */
        @JvmStatic
        fun editingBar(context: Context, placeholder: String?, actionTitle: String): CYLSearchBarView =
            CYLSearchBarView(context).apply {
                isEditingBar = true
                searchIcon = null
                this.placeholder = placeholder
                showsCancelButton = true
                cancelButtonTitle = actionTitle
                cancelButtonEndsEditing = false
                returnKeyType = EditorInfo.IME_ACTION_DONE
                autocapitalizationType = CYLTextAutocapitalizationType.Words
                autocorrectionType = CYLTextAutocorrectionType.No
                setBackgroundColor(android.graphics.Color.WHITE)
                tag = "CYLSearchEditingBar"
            }
    }
}

/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
 */
enum class CYLSearchBarItemStyle {
    /**
     * An icon button with a 36 dp touch area (a camera, a filter).
     */
    Icon,

    /**
     * A thin vertical line between two items; it takes no taps and TalkBack skips it.
     */
    Divider,

    /**
     * A text button (a "Search" button); an image, when set, comes before the title.
     */
    Text,
}

/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
 */
enum class CYLSearchBarStyle {
    /**
     * The field as configured by its own properties (the default; nothing is changed).
     */
    Plain,

    /**
     * A capsule with a 1 dp outline on the surface color, the field and its items inside one outline.
     */
    Bordered,
}

/**
 * The item states for text attributes (iOS `UIControlState`).
 */
enum class CYLSearchBarItemState {
    /**
     * Enabled and not selected.
     */
    Normal,

    /**
     * Selected (`isSelected`).
     */
    Selected,

    /**
     * Disabled (`isEnabled` false).
     */
    Disabled,
}

/**
 * Title or badge text attributes (iOS `NSAttributedString` attributes): a color in ARGB, a size in sp, a typeface.
 */
data class CYLSearchBarItemTextAttributes(
    val color: Int? = null,
    val sizeSp: Float? = null,
    val typeface: Typeface? = null,
)

/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; its view is `itemView`.
 */
class CYLSearchBarItem @JvmOverloads constructor(
    /**
     * How the item looks (icon, divider or text); set when the item is created.
     */
    val style: CYLSearchBarItemStyle,
    title: String? = null,
    image: Drawable? = null,
) {

    /**
     * The text of a text item, and the TalkBack label of an icon item without `itemAccessibilityLabel`.
     */
    var title: String? = title
        set(value) { field = value; itemChanged() }

    /**
     * The icon (tinted with `tintColor`).
     */
    var image: Drawable? = image
        set(value) { field = value; itemChanged() }

    /**
     * The icon while `isSelected` is true; null uses `image`.
     */
    var selectedImage: Drawable? = null
        set(value) { field = value; itemChanged() }

    /**
     * An animated icon (an `AnimatedVectorDrawable` or `AnimationDrawable`), started when shown; it wins over `image`.
     */
    var animatedImage: Drawable? = null
        set(value) { field = value; itemChanged() }

    /**
     * An animated icon file (Lottie .json, .pag, .riv, .svga, .gif), drawn by the item's `CYLTagButton` (a
     * `CYLAnimatedItemView`) when the app adds the file's animation library (the core adds none) and played on each tap.
     * Otherwise `image` shows, or the component's placeholder when there is no `image`.
     */
    var animationURL: Uri? = null
        set(value) { field = value; itemChanged() }

    /**
     * Whether `animationURL` plays again after each pass; false plays once on each tap. The same on every platform.
     */
    var animationLoops: Boolean = false
        set(value) { field = value; itemChanged() }

    /**
     * The playback speed of `animationURL`; 1 is the file's own. An engine without speed ignores it. The same on every
     * platform.
     */
    var animationSpeed: Float = 1f
        set(value) { field = value; itemChanged() }

    /**
     * Plays `animationURL` again from the start, as a tap does. Does nothing without an animation. The same on every
     * platform.
     */
    fun restartAnimation() {
        if (animationURL != null) {
            loadedItemView?.restartAnimation()
        }
    }

    /**
     * The icon size in dp; null uses 20 x 20 dp.
     */
    var imageSize: SizeF? = null
        set(value) { field = value; itemChanged() }

    /**
     * What TalkBack reads; null reads `title`.
     */
    var itemAccessibilityLabel: String? = null
        set(value) { field = value; itemChanged() }

    /**
     * A test tag for the item view (its content description stays `itemAccessibilityLabel`).
     */
    var itemAccessibilityIdentifier: String? = null
        set(value) { field = value; itemChanged() }

    /**
     * False dims the item and ignores taps. True by default.
     */
    var isEnabled: Boolean = true
        set(value) { field = value; itemChanged() }

    /**
     * True makes each tap toggle `isSelected` (a filter that stays on). False by default.
     */
    var isSelectable: Boolean = false

    /**
     * The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected text attributes).
     */
    var isSelected: Boolean = false
        set(value) { field = value; itemChanged() }

    /**
     * The icon and title color; null uses the bar's `itemTintColor`.
     */
    var tintColor: Int? = null
        set(value) { field = value; itemChanged() }

    /**
     * The item background; null is transparent.
     */
    var backgroundColor: Int? = null
        set(value) { field = value; itemChanged() }

    /**
     * The item background while selected; null uses `backgroundColor`.
     */
    var selectedBackgroundColor: Int? = null
        set(value) { field = value; itemChanged() }

    /**
     * Padding around the icon and title, in dp (start, top, end, bottom); null uses the style's default.
     */
    var contentInsets: FloatArray? = null
        set(value) { field = value; itemChanged() }

    /**
     * Moves the icon, in dp (x, y), without changing the item's size.
     */
    var imagePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)
        set(value) { field = value; itemChanged() }

    /**
     * Moves the title, in dp (x, y), without changing the item's size.
     */
    var titlePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)
        set(value) { field = value; itemChanged() }

    /**
     * The badge text; null hides the badge, an empty string draws a dot.
     */
    var badgeValue: String? = null
        set(value) { field = value; itemChanged() }

    /**
     * The badge background; null is red.
     */
    var badgeColor: Int? = null
        set(value) { field = value; itemChanged() }

    /**
     * The smallest badge size in dp; 0 uses 16 dp (a dot is 8 dp).
     */
    var badgeSize: Float = 0f
        set(value) { field = value; itemChanged() }

    /**
     * Padding around the badge text, in dp (start, top, end, bottom).
     */
    var badgeContentInsets: FloatArray = floatArrayOf(4f, 0f, 4f, 0f)
        set(value) { field = value; itemChanged() }

    /**
     * Moves the badge from the icon's top end corner, in dp (x, y).
     */
    var badgePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)
        set(value) { field = value; itemChanged() }

    /**
     * Called on each tap, after `CYLSearchBarViewDelegate.searchBarViewDidSelectItem`.
     */
    var handler: ((CYLSearchBarItem) -> Unit)? = null

    /**
     * The bar the item was appended to; null before `addItem` and after `removeItem`.
     */
    var searchBarView: CYLSearchBarView? = null
        internal set

    /**
     * The item's position in its bar's `items`; -1 when it is in no bar.
     */
    val index: Int
        get() = searchBarView?.items?.indexOf(this) ?: -1

    /**
     * An icon item, or a text item when the title is set and the image is null (iOS `-initWithTitle:image:`).
     */
    constructor(title: String?, image: Drawable?) :
        this(if (image == null && title != null) CYLSearchBarItemStyle.Text else CYLSearchBarItemStyle.Icon, title, image)

    /**
     * Like `constructor(title, image)`, with an icon for the selected state (iOS `-initWithTitle:image:selectedImage:`).
     */
    constructor(title: String?, image: Drawable?, selectedImage: Drawable?) : this(title, image) {
        this.selectedImage = selectedImage
    }

    private var view: CYLSearchBarItemButton? = null
    private val titleAttributes = mutableMapOf<CYLSearchBarItemState, CYLSearchBarItemTextAttributes>()
    private val badgeAttributes = mutableMapOf<CYLSearchBarItemState, CYLSearchBarItemTextAttributes>()

    /**
     * The item's view, a `CYLTagButton` (CollectionViewClassifyMenu), created on first use with the bar's context (or
     * the given one).
     */
    fun itemView(context: Context): CYLTagButton = loadItemView(context)

    /**
     * The item's view once created, or null.
     */
    val itemView: CYLTagButton?
        get() = view

    internal val loadedItemView: CYLSearchBarItemButton?
        get() = view

    internal fun loadItemView(context: Context): CYLSearchBarItemButton =
        view ?: CYLSearchBarItemButton(context, this).also { view = it }

    /**
     * The title attributes for a state.
     */
    fun setTitleTextAttributes(attributes: CYLSearchBarItemTextAttributes?, state: CYLSearchBarItemState) {
        if (attributes == null) titleAttributes.remove(state) else titleAttributes[state] = attributes
        itemChanged()
    }

    /**
     * The title attributes set for a state, or null.
     */
    fun titleTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes? = titleAttributes[state]

    /**
     * The badge text attributes for a state.
     */
    fun setBadgeTextAttributes(attributes: CYLSearchBarItemTextAttributes?, state: CYLSearchBarItemState) {
        if (attributes == null) badgeAttributes.remove(state) else badgeAttributes[state] = attributes
        itemChanged()
    }

    /**
     * The badge text attributes set for a state, or null.
     */
    fun badgeTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes? = badgeAttributes[state]

    /**
     * The view the badge is drawn in (the item view), or null before it exists.
     */
    fun actualBadgeSuperView(): View? = view

    internal val currentState: CYLSearchBarItemState
        get() = when {
            !isEnabled -> CYLSearchBarItemState.Disabled
            isSelected -> CYLSearchBarItemState.Selected
            else -> CYLSearchBarItemState.Normal
        }

    private fun itemChanged() {
        view?.reload()
        searchBarView?.requestLayout()
    }

    companion object {
        /**
         * An icon item: the title is what TalkBack reads.
         */
        @JvmStatic
        fun iconItem(image: Drawable?, title: String?, handler: ((CYLSearchBarItem) -> Unit)?): CYLSearchBarItem =
            CYLSearchBarItem(CYLSearchBarItemStyle.Icon, title, image).also { it.handler = handler }

        /**
         * A text item (a "Search" button).
         */
        @JvmStatic
        fun textItem(title: String, handler: ((CYLSearchBarItem) -> Unit)?): CYLSearchBarItem =
            CYLSearchBarItem(CYLSearchBarItemStyle.Text, title, null).also { it.handler = handler }

        /**
         * A divider between two items.
         */
        @JvmStatic
        fun divider(): CYLSearchBarItem = CYLSearchBarItem(CYLSearchBarItemStyle.Divider)

        /**
         * An item from plain values, for the cross-platform wrappers (Flutter, React Native): `style` (`icon`,
         * `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`, else a drawable name of the app),
         * `accessibilityIdentifier`, `isEnabled`, `isSelectable`, `isSelected`, `badgeValue` (iOS
         * `+itemWithDictionary:`).
         */
        @JvmStatic
        fun fromMap(context: Context, map: Map<String, Any?>): CYLSearchBarItem {
            val style = when (map["style"]) {
                "divider" -> CYLSearchBarItemStyle.Divider
                "text" -> CYLSearchBarItemStyle.Text
                else -> CYLSearchBarItemStyle.Icon
            }
            return CYLSearchBarItem(style, map["title"] as? String, namedImage(context, map["image"] as? String)).apply {
                itemAccessibilityIdentifier = map["accessibilityIdentifier"] as? String
                isEnabled = map["isEnabled"] as? Boolean ?: true
                isSelectable = map["isSelectable"] as? Boolean ?: false
                isSelected = map["isSelected"] as? Boolean ?: false
                badgeValue = map["badgeValue"] as? String
                // A name with no scheme and no leading slash is an asset of the app ("tab_activity.svga").
                animationURL = (map["animationURL"] as? String)?.takeIf { it.isNotEmpty() }?.let {
                    Uri.parse(if (it.contains(':') || it.startsWith('/')) it else "file:///android_asset/$it")
                }
                animationLoops = map["animationLoops"] as? Boolean ?: false
                animationSpeed = (map["animationSpeed"] as? Number)?.toFloat() ?: 1f
                if (style == CYLSearchBarItemStyle.Icon) imageSize = SizeF(22f, 22f)
            }
        }

        private fun namedImage(context: Context, name: String?): Drawable? {
            if (name.isNullOrEmpty()) return null
            val core = when (name) {
                "camera" -> R.drawable.cyl_search_ic_camera
                "mic" -> R.drawable.cyl_search_ic_mic
                "search" -> R.drawable.cyl_search_ic_search
                "back" -> R.drawable.cyl_search_ic_arrow_back
                else -> 0
            }
            @Suppress("DiscouragedApi")
            val id = if (core != 0) core else context.resources.getIdentifier(name, "drawable", context.packageName)
            return if (id != 0) androidx.core.content.ContextCompat.getDrawable(context, id) else null
        }
    }
}

/**
 * The view of a `CYLSearchBarItem`: CollectionViewClassifyMenu's `CYLTagButton` (the one icon + title + animated icon
 * component), styled from the item for each state, plus what only a bar item has: the link to its item, the divider
 * line, the 36 dp touch area and the item's badge metrics. Callers reach it as a `CYLTagButton` through
 * `CYLSearchBarItem.itemView` and `CYLSearchBarView.itemViews`.
 */
internal class CYLSearchBarItemButton(context: Context, item: CYLSearchBarItem) : CYLTagButton(context) {

    /**
     * The item this view draws.
     */
    val item: CYLSearchBarItem = item

    private val divider = View(context)
    private val density = resources.displayMetrics.density

    init {
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        titleLabel.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        divider.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        addView(divider)
        setOnClickListener { this.item.searchBarView?.itemTapped(this.item) }
        reload()
    }

    /**
     * The view the badge is drawn in (this view).
     */
    fun actualBadgeSuperView(): View = this

    /**
     * What TalkBack reads (CYLAnimatedItemView's hook, which sets the content description on every state change): the
     * item's accessibility label or its title, also for an icon item that shows no title.
     */
    override fun accessibilityText(): CharSequence {
        // The base class asks while it is being built, before `item` is set.
        @Suppress("SENSELESS_COMPARISON")
        if (item == null) return super.accessibilityText()
        return item.itemAccessibilityLabel ?: item.title ?: super.accessibilityText()
    }

    private fun dp(value: Float): Int = (value * density + 0.5f).toInt()

    /** The tint the host chose (the item's, else the bar's `itemTintColor`); null: the item sets no tint of its own. */
    private val explicitTint: Int?
        get() = item.tintColor ?: item.searchBarView?.itemTintColor

    /**
     * The default tint of a state, from the iOS item: normal and disabled the label color (disabled is dimmed by the item's alpha), selected the
     * accent (the bar's `tintColor`, else the app's accent). A host tint wins for every state.
     */
    private fun tintForState(state: Int): Int {
        explicitTint?.let { return it }
        if (state != CYLControlState.SELECTED) return CYLSearchBarView.labelColor(context)
        val value = TypedValue()
        context.theme.resolveAttribute(android.R.attr.colorAccent, value, true)
        return item.searchBarView?.tintColor ?: if (value.resourceId != 0) context.getColor(value.resourceId) else value.data
    }

    private val resolvedInsets: FloatArray
        get() = item.contentInsets ?: when (item.style) {
            CYLSearchBarItemStyle.Text -> floatArrayOf(4f, 0f, 4f, 0f)
            CYLSearchBarItemStyle.Divider -> floatArrayOf(DIVIDER_GAP, 0f, DIVIDER_GAP, 0f)
            else -> floatArrayOf(0f, 0f, 0f, 0f)
        }

    /**
     * The tag style that draws the item: no border, the item's background (transparent by default), its tint for the
     * title and icons, its title attributes per state, its icon size, insets and position adjustments.
     */
    private fun makeStyle(): CYLMenuStyle {
        val style = CYLMenuStyle()
        val insets = resolvedInsets
        val imageW = item.imageSize?.width?.takeIf { it > 0 } ?: DEFAULT_IMAGE_SIDE
        val imageH = item.imageSize?.height?.takeIf { it > 0 } ?: imageW
        style.imageSize = CYLSize(imageW, imageH)
        style.animationSize = CYLSize(imageW, imageH)
        style.imageTitleSpacing = IMAGE_TITLE_SPACING
        style.itemHeight = if (item.style == CYLSearchBarItemStyle.Divider) DIVIDER_HEIGHT else MINIMUM_TOUCH
        style.imagePositionAdjustment = CYLOffset(item.imagePositionAdjustment.getOrElse(0) { 0f }, item.imagePositionAdjustment.getOrElse(1) { 0f })
        style.titlePositionAdjustment = CYLOffset(item.titlePositionAdjustment.getOrElse(0) { 0f }, item.titlePositionAdjustment.getOrElse(1) { 0f })
        val hasBackground = item.backgroundColor != null || item.selectedBackgroundColor != null
        val background = if (item.isSelected) item.selectedBackgroundColor ?: item.backgroundColor else item.backgroundColor
        val states = mapOf(
            CYLControlState.NORMAL to CYLSearchBarItemState.Normal,
            CYLControlState.SELECTED to CYLSearchBarItemState.Selected,
            CYLControlState.DISABLED to CYLSearchBarItemState.Disabled,
        )
        for ((state, itemState) in states) {
            val appearance = style.appearanceForState(state)
            val tint = tintForState(state)
            val attributes = item.titleTextAttributes(itemState) ?: item.titleTextAttributes(CYLSearchBarItemState.Normal)
            appearance.font = CYLFont(attributes?.sizeSp ?: TITLE_SIZE, attributes?.typeface ?: Typeface.DEFAULT_BOLD)
            appearance.textColor = attributes?.color ?: tint
            appearance.iconColor = tint
            appearance.backgroundColor = background ?: Color.TRANSPARENT
            appearance.borderColor = null
            appearance.borderWidth = 0f
            appearance.contentInsets = CYLEdgeInsets(insets.getOrElse(1) { 0f }, insets.getOrElse(0) { 0f }, insets.getOrElse(3) { 0f }, insets.getOrElse(2) { 0f })
            appearance.cornerRadius = if (hasBackground) BACKGROUND_CORNER_RADIUS else 0f
        }
        return style
    }

    internal fun reload() {
        val isDivider = item.style == CYLSearchBarItemStyle.Divider
        style = makeStyle()
        // A text item shows its title (and its icon before it); an icon item only its icon, the title is what TalkBack
        // reads; a divider neither.
        title = if (item.style == CYLSearchBarItemStyle.Text) item.title else null
        image = if (isDivider) null else item.animatedImage ?: item.image
        selectedImage = if (isDivider || item.animatedImage != null) null else item.selectedImage
        animationURL = if (isDivider) null else item.animationURL?.toString()
        animationLoops = item.animationLoops
        animationSpeed = item.animationSpeed
        badgeValue = if (isDivider) null else item.badgeValue
        badgeColor = item.badgeColor
        isEnabled = item.isEnabled
        isSelected = item.isSelected
        alpha = if (item.isEnabled) 1f else DISABLED_ALPHA
        (item.animatedImage as? Animatable)?.start()
        val attributes = item.badgeTextAttributes(item.currentState) ?: item.badgeTextAttributes(CYLSearchBarItemState.Normal)
        badgeLabel.setTextColor(attributes?.color ?: Color.WHITE)
        badgeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, attributes?.sizeSp ?: BADGE_SIZE)
        badgeLabel.typeface = attributes?.typeface ?: Typeface.DEFAULT_BOLD
        divider.visibility = if (isDivider) VISIBLE else GONE
        // The secondary label color, resolved at every reload so a live light/dark switch recolors it.
        divider.setBackgroundColor(CYLSearchBarView.secondaryLabelColor(context))
        val accessible = !isDivider
        importantForAccessibility = if (accessible) IMPORTANT_FOR_ACCESSIBILITY_YES else IMPORTANT_FOR_ACCESSIBILITY_NO
        contentDescription = item.itemAccessibilityLabel ?: item.title
        tag = item.itemAccessibilityIdentifier
        isClickable = accessible
        isFocusable = accessible
        requestLayout()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        val insets = resolvedInsets
        var width = measuredWidth
        var height = measuredHeight
        when (item.style) {
            CYLSearchBarItemStyle.Divider -> {
                width = dp(1f + insets.getOrElse(0) { 0f } + insets.getOrElse(2) { 0f })
                height = dp(DIVIDER_HEIGHT)
            }
            CYLSearchBarItemStyle.Icon -> {
                // An icon item is square, at least 36 dp.
                val side = max(dp(MINIMUM_TOUCH), max(width, height))
                width = side
                height = side
            }
            CYLSearchBarItemStyle.Text -> {
                width = max(dp(MINIMUM_TOUCH), width)
                height = max(dp(MINIMUM_TOUCH), height)
            }
        }
        setMeasuredDimension(resolveSize(width, widthMeasureSpec), resolveSize(height, heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        super.onLayout(changed, l, t, r, b)
        val width = r - l
        val height = b - t
        if (item.style == CYLSearchBarItemStyle.Divider) {
            val lineHeight = minOf(dp(DIVIDER_HEIGHT), height)
            val x = dp(resolvedInsets.getOrElse(0) { 0f })
            val y = (height - lineHeight) / 2
            divider.measure(MeasureSpec.makeMeasureSpec(dp(1f), MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(lineHeight, MeasureSpec.EXACTLY))
            divider.layout(x, y, x + dp(1f), y + lineHeight)
        }
        // The whole item is dimmed while disabled; the animated icon is not dimmed a second time.
        animationView?.alpha = 1f
        layOutItemBadge(width, height)
    }

    /**
     * The item's badge metrics on the tag's badge: its smallest size, text padding and position adjustment, from the
     * corner the tag placed it at.
     */
    private fun layOutItemBadge(width: Int, height: Int) {
        val value = item.badgeValue ?: return
        if (item.style == CYLSearchBarItemStyle.Divider || badgeLabel.visibility != VISIBLE) return
        val isDot = value.isEmpty()
        val side = dp(if (isDot) 8f else if (item.badgeSize > 0) item.badgeSize else 16f)
        val insets = if (isDot) floatArrayOf(0f, 0f, 0f, 0f) else item.badgeContentInsets
        badgeLabel.measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
        val textWidth = if (isDot) 0 else badgeLabel.measuredWidth
        val textHeight = if (isDot) 0 else badgeLabel.measuredHeight
        val badgeWidth = max(side, textWidth + dp(insets.getOrElse(0) { 0f } + insets.getOrElse(2) { 0f }))
        val badgeHeight = max(side, textHeight + dp(insets.getOrElse(1) { 0f } + insets.getOrElse(3) { 0f }))
        // Kept inside the tag, which clips its content.
        val x = (badgeFrame.x * density).toInt().coerceIn(0, max(0, width - badgeWidth))
        val y = (badgeFrame.y * density).toInt().coerceIn(0, max(0, height - badgeHeight))
        badgeLabel.measure(MeasureSpec.makeMeasureSpec(badgeWidth, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(badgeHeight, MeasureSpec.EXACTLY))
        badgeLabel.layout(x, y, x + badgeWidth, y + badgeHeight)
        (badgeLabel.background as? GradientDrawable)?.cornerRadius = badgeHeight / 2f
        badgeLabel.translationX = item.badgePositionAdjustment.getOrElse(0) { 0f } * density
        badgeLabel.translationY = item.badgePositionAdjustment.getOrElse(1) { 0f } * density
    }

    private companion object {
        const val MINIMUM_TOUCH = 36f
        /** The built-in divider: a 1 x 20 line with an 8 gap on each side (the iOS stack divider). */
        const val DIVIDER_HEIGHT = 20f
        const val DIVIDER_GAP = 8f
        const val DEFAULT_IMAGE_SIDE = 20f
        const val IMAGE_TITLE_SPACING = 4f
        const val BACKGROUND_CORNER_RADIUS = 10f
        const val TITLE_SIZE = 17f
        const val BADGE_SIZE = 11f
        const val DISABLED_ALPHA = 0.4f
    }
}
