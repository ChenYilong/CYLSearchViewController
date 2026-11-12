package com.cyl.search

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.os.Parcelable
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
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
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.widget.ImageViewCompat
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
}

/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button, views
 * of the host inside the field after the text (a camera, a "Search" button) or before the field (a back button), and
 * an optional Cancel button. Sizes are in dp, durations in seconds, as on iOS.
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
    val textField: EditText = EditText(context)

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

    init {
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
                submit()
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
        textField.setOnFocusChangeListener { _, focused -> if (focused) didBeginEditing() else didEndEditing() }
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
        accessoryContainer.removeAllViews()
        val hasText = !text.isNullOrEmpty()
        val views = trailingAccessoryViews.toMutableList()
        if (showsVoiceButton && !hasText) {
            views.add(voiceButton)
        }
        if (showsSubmitButton && hasText) {
            views.add(submitButton)
        }
        views.forEach { view ->
            (view.parent as? ViewGroup)?.removeView(view)
            accessoryContainer.addView(view, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
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
        fieldView.visibility = if (isIconified) INVISIBLE else VISIBLE
        iconButton.visibility = if (isIconified) VISIBLE else GONE
        cancelButton.visibility = if (isIconified || !showsCancelButton) GONE else VISIBLE
        navigationButton.visibility = if (isIconified || !showsNavigationButton) GONE else VISIBLE
        leadingView?.visibility = if (isIconified) GONE else VISIBLE
        leadingContainer.visibility = if (leadingView == null && !showsNavigationButton) GONE else VISIBLE
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
        val hint = placeholderColor ?: themeColor(android.R.attr.textColorHint)
        val secondary = searchIconTintColor ?: themeColor(android.R.attr.textColorSecondary)
        textField.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        textField.typeface = font ?: Typeface.DEFAULT
        textField.setTextColor(primary)
        placeholderLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        placeholderLabel.typeface = font ?: Typeface.DEFAULT
        placeholderLabel.setTextColor(hint)
        cancelButton.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        cancelButton.typeface = font ?: Typeface.DEFAULT
        cancelButton.setTextColor(themeColor(android.R.attr.colorAccent))
        cancelButton.text = cancelButtonTitle
        cancelButton.contentDescription = cancelButtonTitle
        if (android.os.Build.VERSION.SDK_INT >= 29) {
            cursorColor?.let { textField.textCursorDrawable?.setTint(it) }
        }
        fieldBackground.setColor(fieldBackgroundColor ?: DEFAULT_FIELD_COLOR)
        val border = fieldBorderColor
        fieldBackground.setStroke(if (border != null) dp(fieldBorderWidth) else 0, border ?: Color.TRANSPARENT)
        fieldView.elevation = fieldShadowOpacity * 6 * density
        val tint = ColorStateList.valueOf(secondary)
        listOf<ImageView>(searchIconView, iconButton, voiceButton, clearButton, submitButton, navigationButton).forEach {
            ImageViewCompat.setImageTintList(it, tint)
        }
        applyLayout()
    }

    private fun applyLayout() {
        val fieldPixels = max(dp(fieldHeight), (fontSize * resources.displayMetrics.scaledDensity * 1.2f + 12 * density).toInt())
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
    }

    // Events

    private fun textStateChanged() {
        val empty = text.isNullOrEmpty()
        placeholderLabel.visibility = if (empty) VISIBLE else INVISIBLE
        clearButton.visibility = if (empty || !textField.hasFocus()) GONE else VISIBLE
        updateAccessories()
    }

    private fun textChanged() {
        textStateChanged()
        delegate?.searchBarViewTextDidChange(this, text.orEmpty())
    }

    private fun cancelTapped() {
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
        delegate?.searchBarViewDidBeginEditing(this)
    }

    private fun didEndEditing() {
        if (clearsTextOnEndEditing && !text.isNullOrEmpty()) {
            text = ""
            textChanged()
        }
        textStateChanged()
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

    private companion object {
        const val ICON_SIZE = 18f
        const val SPACING = 8f
        const val DEFAULT_FIELD_COLOR = 0x1F767680
        const val STATE_SUPER = "CYLSearchBarSuper"
        const val STATE_TEXT = "CYLSearchBarText"
        const val STATE_EDITING = "CYLSearchBarEditing"
        const val STATE_ICONIFIED = "CYLSearchBarIconified"
    }
}
