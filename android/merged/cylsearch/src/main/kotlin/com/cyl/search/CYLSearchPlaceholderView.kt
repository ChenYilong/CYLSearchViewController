package com.cyl.search

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.drawable.Drawable
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.widget.ImageViewCompat

/**
 * The common placeholder kinds: an empty list, no search results, or an error.
 */
enum class CYLSearchPlaceholderKind {
    /**
     * Nothing to show yet.
     */
    Empty,

    /**
     * The search found nothing.
     */
    NoResults,

    /**
     * Loading failed.
     */
    Error,
}

/**
 * The image of a placeholder; each style has an image in this library's resources.
 */
enum class CYLSearchPlaceholderStyle {
    Empty, NoResults, Error, WifiOff, SignalWifiOff, NoInternet, CloudOff, SyncProblem, SyncDisabled, NetworkLocked,
    BluetoothDisabled, LocationOff, PublicOff, ErrorOutline, Warning, ReportProblem, Blocked, Help, Hourglass, Locked,
    VisibilityOff, SearchOff, FolderOff, FolderOpen, DownloadOff, UploadOff, Inbox, BrokenImage, ImageUnavailable,
    PhotoLibrary, MusicOff, VideoOff, PersonOff, GroupOff, EventBusy, EmptyCart, Favorite, BatteryAlert,
    UnknownDevice, PhoneDisabled, WrongLocation,

    /**
     * The number of styles; not an image.
     */
    Count,
}

/**
 * The localized message of a placeholder.
 */
enum class CYLSearchPlaceholderMessage(internal val key: String) {
    /**
     * "No data".
     */
    Empty("placeholder.empty"),

    /**
     * "No matching results".
     */
    NoResults("placeholder.search"),

    /**
     * "Something went wrong".
     */
    Error("placeholder.error"),

    /**
     * "Check your internet connection".
     */
    Network("placeholder.network"),
}

/**
 * An image above a message, centered in its bounds: the empty, no-result and error states of a list (iOS
 * `CYLSearchPlaceholderView`).
 */
class CYLSearchPlaceholderView(context: Context, image: Drawable?, text: String) : FrameLayout(context) {

    /**
     * The image, 80 × 80 dp, tinted with the secondary text color (except the colored empty image).
     */
    val imageView: ImageView = ImageView(context)

    /**
     * The message, centered, in the body text size.
     */
    val textLabel: TextView = TextView(context)

    /**
     * A placeholder of a common kind with its built-in image and message.
     */
    constructor(context: Context, kind: CYLSearchPlaceholderKind) : this(
        context,
        when (kind) {
            CYLSearchPlaceholderKind.Empty -> CYLSearchPlaceholderStyle.Empty
            CYLSearchPlaceholderKind.NoResults -> CYLSearchPlaceholderStyle.NoResults
            CYLSearchPlaceholderKind.Error -> CYLSearchPlaceholderStyle.Error
        },
        when (kind) {
            CYLSearchPlaceholderKind.Empty -> CYLSearchPlaceholderMessage.Empty
            CYLSearchPlaceholderKind.NoResults -> CYLSearchPlaceholderMessage.NoResults
            CYLSearchPlaceholderKind.Error -> CYLSearchPlaceholderMessage.Error
        },
    )

    /**
     * A built-in image with a built-in message.
     */
    constructor(context: Context, style: CYLSearchPlaceholderStyle, message: CYLSearchPlaceholderMessage) :
        this(context, imageFor(context, style), CYLSearchResources.localizedString(context, message.key)) {
        tintUnlessEmpty(style)
    }

    /**
     * A built-in image with your own text.
     */
    constructor(context: Context, style: CYLSearchPlaceholderStyle, text: String) : this(context, imageFor(context, style), text) {
        tintUnlessEmpty(style)
    }

    /**
     * Your own image with a built-in message.
     */
    constructor(context: Context, image: Drawable?, message: CYLSearchPlaceholderMessage) :
        this(context, image, CYLSearchResources.localizedString(context, message.key))

    init {
        val density = resources.displayMetrics.density
        val secondary = secondaryTextColor(context)
        imageView.setImageDrawable(image)
        imageView.scaleType = ImageView.ScaleType.FIT_CENTER
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        ImageViewCompat.setImageTintList(imageView, ColorStateList.valueOf(secondary))
        textLabel.text = text
        textLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        textLabel.setTextColor(secondary)
        textLabel.gravity = Gravity.CENTER
        val stack = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            val side = (80 * density).toInt()
            addView(imageView, LinearLayout.LayoutParams(side, side))
            addView(textLabel, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
                topMargin = (12 * density).toInt()
            })
        }
        val margin = (16 * density).toInt()
        addView(stack, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER).apply {
            leftMargin = margin
            rightMargin = margin
        })
    }

    private fun tintUnlessEmpty(style: CYLSearchPlaceholderStyle) {
        if (style == CYLSearchPlaceholderStyle.Empty) {
            ImageViewCompat.setImageTintList(imageView, null)
        }
    }

    companion object {

        /**
         * The iOS name of the image of `style` ("CYLSearchNoResults"); its drawable is
         * `CYLSearchResources.drawableName(name)`. Throws `IllegalArgumentException` for `Count`, like iOS's
         * NSInvalidArgumentException.
         */
        @JvmStatic
        fun imageNameForStyle(style: CYLSearchPlaceholderStyle): String {
            require(style != CYLSearchPlaceholderStyle.Count) { "Unknown placeholder style: ${style.ordinal}" }
            return "CYLSearch" + style.name
        }

        private fun imageFor(context: Context, style: CYLSearchPlaceholderStyle): Drawable? =
            CYLSearchResources.imageNamed(context, imageNameForStyle(style))

        internal fun secondaryTextColor(context: Context): Int {
            val value = TypedValue()
            context.theme.resolveAttribute(android.R.attr.textColorSecondary, value, true)
            return if (value.resourceId != 0) context.getColor(value.resourceId) else value.data
        }
    }
}
