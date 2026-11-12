package com.cyl.search

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.core.content.ContextCompat
import androidx.core.widget.ImageViewCompat
import kotlin.math.max

/**
 * Events of a `CYLMultiSearchView` (iammert `MultiSearchViewListener`). Every method is optional.
 */
interface CYLMultiSearchViewDelegate {

    /**
     * The text of the search being typed changed (`onTextChanged`).
     */
    fun multiSearchViewTextDidChange(multiSearchView: CYLMultiSearchView, text: String, index: Int) {}

    /**
     * A search was completed and became an item (`onSearchComplete`).
     */
    fun multiSearchViewDidCompleteSearch(multiSearchView: CYLMultiSearchView, text: String, index: Int) {}

    /**
     * An item was removed (`onSearchItemRemoved`).
     */
    fun multiSearchViewDidRemoveItemAtIndex(multiSearchView: CYLMultiSearchView, index: Int) {}

    /**
     * An item was selected by a tap (`onItemSelected`).
     */
    fun multiSearchViewDidSelectItem(multiSearchView: CYLMultiSearchView, text: String, index: Int) {}
}

/**
 * Several searches side by side (iOS `CYLMultiSearchView`, iammert `MultiSearchView`): the search button starts a new
 * search; a completed search becomes an item in a horizontally scrolling row, with an indicator under the selected
 * item and a remove button on it. Sizes are in dp, durations in seconds.
 */
class CYLMultiSearchView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : LinearLayout(context, attrs, defStyleAttr) {

    private class Item(context: Context) : FrameLayout(context) {
        val textField = EditText(context)
        val removeButton = ImageButton(context)
        val indicator = View(context)
        var editing = false
    }

    private val density = resources.displayMetrics.density
    private val scrollView = HorizontalScrollView(context)
    private val itemsView = LinearLayout(context)
    private val items = mutableListOf<Item>()

    /**
     * Receives the events.
     */
    var delegate: CYLMultiSearchViewDelegate? = null

    /**
     * The selected item, or -1 (iOS `NSNotFound`) when there is none.
     */
    var selectedIndex: Int = NO_SELECTION
        private set

    /**
     * True while a new search is being typed (`isInSearchMode`).
     */
    var isInSearchMode: Boolean = false
        private set

    /**
     * The button at the end: it starts a search, or completes the one being typed.
     */
    val searchButton: ImageButton = ImageButton(context)

    /**
     * The placeholder of a new search (`android:hint`). The localized "Search" when null.
     */
    var placeholder: String? = null
        get() = field ?: CYLSearchResources.localizedString(context, "search.field")
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The typeface of the items (`android:textStyle`). The default typeface when null.
     */
    var font: Typeface? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The text size in sp (`android:textSize`). 17 by default.
     */
    var fontSize: Float = 17f
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The text color (`android:textColor`). The theme's primary text color when null.
     */
    var textColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The placeholder color (`android:textColorHint`). The theme's hint color when null.
     */
    var placeholderColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The longest search a person can type (`android:maxLength`); 0 means no limit. 0 by default.
     */
    var maximumTextLength: Int = 0
        set(value) {
            field = max(0, value)
            applyStyle()
        }

    /**
     * A search shorter than this is dropped when it is completed. 3 by default, as in MultiSearchView.
     */
    var minimumTextLength: Int = 3

    /**
     * The action key (`android:imeOptions`). `EditorInfo.IME_ACTION_SEARCH` by default.
     */
    var returnKeyType: Int = EditorInfo.IME_ACTION_SEARCH
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The keyboard (`android:inputType` class). `InputType.TYPE_CLASS_TEXT` by default.
     */
    var keyboardType: Int = InputType.TYPE_CLASS_TEXT
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * Capitalization (`textCapSentences`). `Sentences` by default.
     */
    var autocapitalizationType: CYLTextAutocapitalizationType = CYLTextAutocapitalizationType.Sentences
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The color of the indicator under the selected item and of the buttons. The accent color when null.
     */
    var indicatorColor: Int? = null
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The opacity of items that are not selected. 0.5 by default.
     */
    var unselectedItemAlpha: Float = 0.5f
        set(value) {
            field = value.coerceIn(0f, 1f)
            applyStyle()
        }

    /**
     * The width of the field for a new search, in dp. 160 by default.
     */
    var searchFieldWidth: Float = 160f
        set(value) {
            field = max(44f, value)
            applyStyle()
        }

    /**
     * The length of the animations, in seconds. 0.25 by default.
     */
    var animationDuration: Double = 0.25

    /**
     * The search button's icon. A magnifier when null.
     */
    var searchImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The remove button's icon. A cross in a circle when null.
     */
    var removeImage: Drawable? = null
        get() = field ?: ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_clear)
        set(value) {
            field = value
            applyStyle()
        }

    /**
     * The texts of the items, completed searches first, then the one being typed.
     */
    val searchTexts: List<String>
        get() = items.map { it.textField.text.toString() }

    init {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        minimumHeight = (56 * density).toInt()
        scrollView.isHorizontalScrollBarEnabled = false
        scrollView.isFillViewport = false
        itemsView.orientation = HORIZONTAL
        scrollView.addView(itemsView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        addView(scrollView, LayoutParams(0, LayoutParams.MATCH_PARENT, 1f))
        searchButton.setBackgroundResource(TypedValue().also {
            context.theme.resolveAttribute(android.R.attr.selectableItemBackgroundBorderless, it, true)
        }.resourceId)
        searchButton.contentDescription = CYLSearchResources.localizedString(context, "multisearch.add")
        searchButton.setOnClickListener { if (isInSearchMode) completeSearch() else search() }
        val side = (48 * density).toInt()
        addView(searchButton, LayoutParams(side, side))
        applyStyle()
    }

    private fun dp(value: Float): Int = (value * density + 0.5f).toInt()

    private fun themeColor(attribute: Int): Int {
        val value = TypedValue()
        context.theme.resolveAttribute(attribute, value, true)
        return if (value.resourceId != 0) ContextCompat.getColor(context, value.resourceId) else value.data
    }

    // Style

    private fun applyStyle() {
        val accent = indicatorColor ?: themeColor(android.R.attr.colorAccent)
        searchButton.setImageDrawable(searchImage)
        ImageViewCompat.setImageTintList(searchButton, ColorStateList.valueOf(accent))
        items.forEachIndexed { index, item -> style(item, index == selectedIndex, accent) }
    }

    private fun style(item: Item, selected: Boolean, accent: Int) {
        val field = item.textField
        field.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize)
        field.typeface = font ?: Typeface.DEFAULT
        field.setTextColor(textColor ?: themeColor(android.R.attr.textColorPrimary))
        field.setHintTextColor(placeholderColor ?: themeColor(android.R.attr.textColorHint))
        field.hint = placeholder
        field.imeOptions = returnKeyType or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        var type = keyboardType
        if (type and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_TEXT) {
            type = type or when (autocapitalizationType) {
                CYLTextAutocapitalizationType.None -> 0
                CYLTextAutocapitalizationType.Words -> InputType.TYPE_TEXT_FLAG_CAP_WORDS
                CYLTextAutocapitalizationType.Sentences -> InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
                CYLTextAutocapitalizationType.AllCharacters -> InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS
            }
        }
        field.inputType = type
        field.isSingleLine = true
        field.filters = if (maximumTextLength > 0) arrayOf(InputFilter.LengthFilter(maximumTextLength)) else emptyArray()
        field.alpha = if (selected || item.editing) 1f else unselectedItemAlpha
        field.isFocusableInTouchMode = item.editing
        field.isCursorVisible = item.editing
        item.removeButton.setImageDrawable(removeImage)
        ImageViewCompat.setImageTintList(item.removeButton, ColorStateList.valueOf(themeColor(android.R.attr.textColorSecondary)))
        item.removeButton.visibility = if (selected && !item.editing) VISIBLE else GONE
        item.indicator.setBackgroundColor(accent)
        item.indicator.visibility = if (selected || item.editing) VISIBLE else INVISIBLE
        val width = if (item.editing) LayoutParams.WRAP_CONTENT else LayoutParams.WRAP_CONTENT
        field.minWidth = if (item.editing) dp(searchFieldWidth) else 0
        field.maxWidth = if (item.editing) dp(searchFieldWidth) else Int.MAX_VALUE
        (field.layoutParams as? FrameLayout.LayoutParams)?.let {
            it.width = width
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

    // Actions

    private fun newItem(): Item {
        val item = Item(context)
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
                if (index >= 0 && item.editing) {
                    delegate?.multiSearchViewTextDidChange(this@CYLMultiSearchView, s.toString(), index)
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

    /**
     * Starts a new search and shows the keyboard (`search`). Does nothing while a search is being typed.
     */
    fun search() {
        if (isInSearchMode) {
            return
        }
        isInSearchMode = true
        selectedIndex = NO_SELECTION
        val item = newItem()
        item.editing = true
        items.add(item)
        itemsView.addView(item, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        applyStyle()
        item.alpha = 0f
        item.animate().alpha(1f).setDuration((animationDuration * 1000).toLong()).start()
        scrollTo(item)
        item.textField.requestFocus()
        item.textField.post {
            (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
                .showSoftInput(item.textField, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    /**
     * Completes the search being typed (`completeSearch`): it becomes the selected item, or is dropped when shorter
     * than `minimumTextLength`.
     */
    fun completeSearch() {
        val item = items.lastOrNull()
        if (!isInSearchMode || item == null) {
            return
        }
        isInSearchMode = false
        item.editing = false
        hideKeyboard(item)
        val text = item.textField.text.toString()
        if (text.isEmpty() || text.length < minimumTextLength) {
            remove(item, false)
            return
        }
        val index = items.size - 1
        selectedIndex = index
        applyStyle()
        delegate?.multiSearchViewDidCompleteSearch(this, text, index)
    }

    /**
     * Adds a completed search without typing it and selects it.
     */
    fun addSearchText(text: String) {
        if (text.isEmpty()) {
            return
        }
        if (isInSearchMode) {
            completeSearch()
        }
        val item = newItem()
        item.textField.setText(if (maximumTextLength > 0 && text.length > maximumTextLength) text.take(maximumTextLength) else text)
        items.add(item)
        itemsView.addView(item, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT))
        selectedIndex = items.size - 1
        applyStyle()
        scrollTo(item)
    }

    /**
     * Selects an item, like a tap on it.
     */
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
        delegate?.multiSearchViewDidSelectItem(this, items[index].textField.text.toString(), index)
    }

    /**
     * Removes an item, like a tap on its remove button.
     */
    fun removeItemAtIndex(index: Int) {
        if (index in items.indices) {
            remove(items[index], true)
        }
    }

    private fun remove(item: Item, notify: Boolean) {
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
        // As in MultiSearchView: the next item is selected, or the previous one when the last item went away.
        selectedIndex = when {
            items.isEmpty() -> NO_SELECTION
            selectedIndex == index || selectedIndex == NO_SELECTION -> minOf(index, items.size - 1)
            selectedIndex > index -> selectedIndex - 1
            else -> selectedIndex
        }
        applyStyle()
        if (notify) {
            delegate?.multiSearchViewDidRemoveItemAtIndex(this, index)
        }
    }

    private fun hideKeyboard(item: Item) {
        (context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager)
            .hideSoftInputFromWindow(item.textField.windowToken, 0)
        item.textField.clearFocus()
    }

    private fun scrollTo(item: Item) {
        scrollView.post { scrollView.smoothScrollTo(item.left, 0) }
    }

    private companion object {
        const val NO_SELECTION = -1
        const val ITEM_PADDING = 12f
        const val REMOVE_SIZE = 28f
        const val INDICATOR_HEIGHT = 2f
    }
}
