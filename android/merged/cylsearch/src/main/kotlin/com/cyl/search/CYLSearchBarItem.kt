package com.cyl.search

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.SizeF
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.widget.ImageViewCompat
import kotlin.math.max

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

    private var view: CYLSearchBarItemView? = null
    private val titleAttributes = mutableMapOf<CYLSearchBarItemState, CYLSearchBarItemTextAttributes>()
    private val badgeAttributes = mutableMapOf<CYLSearchBarItemState, CYLSearchBarItemTextAttributes>()

    /**
     * The item's view, created on first use with the bar's context (or the given one).
     */
    fun itemView(context: Context): CYLSearchBarItemView =
        view ?: CYLSearchBarItemView(context, this).also { view = it }

    /**
     * The item's view once created, or null.
     */
    val itemView: CYLSearchBarItemView?
        get() = view

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
 * The view of a `CYLSearchBarItem` (iOS `CYLSearchBarItemView`, like `CYLFlatDesignTabBarButton`).
 */
class CYLSearchBarItemView(context: Context, item: CYLSearchBarItem) : FrameLayout(context) {

    /**
     * The item this view draws.
     */
    val item: CYLSearchBarItem = item

    /**
     * The icon.
     */
    val imageView: ImageView = ImageView(context)

    /**
     * The title of a text item.
     */
    val titleLabel: TextView = TextView(context)

    /**
     * The badge (`badgeValue`).
     */
    val badgeLabel: TextView = TextView(context)

    private val content = LinearLayout(context)
    private val divider = View(context)
    private val density = resources.displayMetrics.density

    init {
        content.orientation = LinearLayout.HORIZONTAL
        content.gravity = Gravity.CENTER
        imageView.scaleType = ImageView.ScaleType.FIT_CENTER
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        titleLabel.setTypeface(titleLabel.typeface, Typeface.BOLD)
        titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        titleLabel.maxLines = 1
        titleLabel.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        badgeLabel.gravity = Gravity.CENTER
        badgeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
        badgeLabel.setTextColor(Color.WHITE)
        badgeLabel.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        content.addView(imageView)
        content.addView(titleLabel)
        addView(content, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, Gravity.CENTER))
        addView(divider, LayoutParams(dp(1f), dp(18f), Gravity.CENTER))
        addView(badgeLabel, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.TOP or Gravity.END))
        clipChildren = false
        clipToPadding = false
        setOnClickListener { this.item.searchBarView?.itemTapped(this.item) }
        reload()
    }

    /**
     * The view the badge is drawn in (this view).
     */
    fun actualBadgeSuperView(): View = this

    private fun dp(value: Float): Int = (value * density + 0.5f).toInt()

    private val resolvedTint: Int
        get() = item.tintColor ?: item.searchBarView?.itemTintColor ?: defaultTint()

    private fun defaultTint(): Int {
        val value = TypedValue()
        return if (context.theme.resolveAttribute(android.R.attr.textColorPrimary, value, true)) {
            if (value.resourceId != 0) context.getColor(value.resourceId) else value.data
        } else {
            Color.BLACK
        }
    }

    private val currentImage: Drawable?
        get() = item.animatedImage ?: if (item.isSelected) item.selectedImage ?: item.image else item.image

    internal fun reload() {
        val state = item.currentState
        val tint = resolvedTint
        isEnabled = item.isEnabled
        isSelected = item.isSelected
        alpha = if (item.isEnabled) 1f else 0.4f
        val image = currentImage
        imageView.setImageDrawable(image)
        ImageViewCompat.setImageTintList(imageView, if (item.animatedImage != null) null else ColorStateList.valueOf(tint))
        (image as? Animatable)?.start()
        val imageW = item.imageSize?.width?.takeIf { it > 0 } ?: 20f
        val imageH = item.imageSize?.height?.takeIf { it > 0 } ?: imageW
        imageView.layoutParams = LinearLayout.LayoutParams(dp(imageW), dp(imageH)).apply {
            marginEnd = if (item.style == CYLSearchBarItemStyle.Text) dp(4f) else 0
        }
        imageView.translationX = item.imagePositionAdjustment.getOrElse(0) { 0f } * density
        imageView.translationY = item.imagePositionAdjustment.getOrElse(1) { 0f } * density
        imageView.visibility = if (item.style != CYLSearchBarItemStyle.Divider && image != null) VISIBLE else GONE
        val attributes = item.titleTextAttributes(state) ?: item.titleTextAttributes(CYLSearchBarItemState.Normal)
        if (item.style == CYLSearchBarItemStyle.Text && item.title != null) {
            titleLabel.text = item.title
            titleLabel.setTextColor(attributes?.color ?: tint)
            attributes?.sizeSp?.let { titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, it) }
            attributes?.typeface?.let { titleLabel.typeface = it }
            titleLabel.visibility = VISIBLE
        } else {
            titleLabel.text = null
            titleLabel.visibility = GONE
        }
        titleLabel.translationX = item.titlePositionAdjustment.getOrElse(0) { 0f } * density
        titleLabel.translationY = item.titlePositionAdjustment.getOrElse(1) { 0f } * density
        val insets = item.contentInsets ?: when (item.style) {
            CYLSearchBarItemStyle.Text -> floatArrayOf(4f, 0f, 4f, 0f)
            else -> floatArrayOf(0f, 0f, 0f, 0f)
        }
        setPaddingRelative(dp(insets.getOrElse(0) { 0f }), dp(insets.getOrElse(1) { 0f }), dp(insets.getOrElse(2) { 0f }), dp(insets.getOrElse(3) { 0f }))
        val minimum = if (item.style == CYLSearchBarItemStyle.Divider) 0 else dp(MINIMUM_TOUCH)
        minimumWidth = minimum
        minimumHeight = minimum
        val background = if (item.isSelected) item.selectedBackgroundColor ?: item.backgroundColor else item.backgroundColor
        this.background = background?.let { color ->
            GradientDrawable().apply { setColor(color); cornerRadius = dp(10f).toFloat() }
        }
        divider.visibility = if (item.style == CYLSearchBarItemStyle.Divider) VISIBLE else GONE
        divider.setBackgroundColor(Color.argb(0x33, 0x3C, 0x3C, 0x43))
        content.visibility = if (item.style == CYLSearchBarItemStyle.Divider) GONE else VISIBLE
        reloadBadge(state)
        val accessible = item.style != CYLSearchBarItemStyle.Divider
        importantForAccessibility = if (accessible) IMPORTANT_FOR_ACCESSIBILITY_YES else IMPORTANT_FOR_ACCESSIBILITY_NO
        contentDescription = item.itemAccessibilityLabel ?: item.title
        tag = item.itemAccessibilityIdentifier
        isClickable = accessible
        isFocusable = accessible
        requestLayout()
    }

    private fun reloadBadge(state: CYLSearchBarItemState) {
        val value = item.badgeValue
        if (value == null) {
            badgeLabel.visibility = GONE
            return
        }
        badgeLabel.visibility = VISIBLE
        val isDot = value.isEmpty()
        val side = if (isDot) 8f else if (item.badgeSize > 0) item.badgeSize else 16f
        badgeLabel.text = value
        val attributes = item.badgeTextAttributes(state) ?: item.badgeTextAttributes(CYLSearchBarItemState.Normal)
        badgeLabel.setTextColor(attributes?.color ?: Color.WHITE)
        attributes?.sizeSp?.let { badgeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, it) }
        attributes?.typeface?.let { badgeLabel.typeface = it }
        badgeLabel.minWidth = dp(side)
        badgeLabel.minHeight = dp(side)
        badgeLabel.minimumWidth = dp(side)
        badgeLabel.minimumHeight = dp(side)
        val insets = if (isDot) floatArrayOf(0f, 0f, 0f, 0f) else item.badgeContentInsets
        badgeLabel.setPaddingRelative(dp(insets.getOrElse(0) { 0f }), dp(insets.getOrElse(1) { 0f }), dp(insets.getOrElse(2) { 0f }), dp(insets.getOrElse(3) { 0f }))
        badgeLabel.background = GradientDrawable().apply {
            setColor(item.badgeColor ?: Color.RED)
            cornerRadius = dp(side).toFloat() / 2
        }
        badgeLabel.translationX = item.badgePositionAdjustment.getOrElse(0) { 0f } * density
        badgeLabel.translationY = item.badgePositionAdjustment.getOrElse(1) { 0f } * density
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (item.style == CYLSearchBarItemStyle.Icon) {
            // An icon item is square.
            val side = max(measuredWidth, measuredHeight)
            setMeasuredDimension(side, side)
        }
    }

    private companion object {
        const val MINIMUM_TOUCH = 36f
    }
}
