package com.cyl.search

import android.text.SpannableString
import android.text.Spanned
import android.text.style.ForegroundColorSpan
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import com.cyl.placeholder.CYLPlaceholderStackView
import java.text.Normalizer
import java.util.Locale

/**
 * The one holder of an empty view (iOS `CYLSearchEmptyViewSlot`): the placeholders of `CYLSearchView`
 * (`emptyResultsView`, `emptySuggestionsView`, the view of `showEmptyView`) and of `CYLSearchListView` are all kept,
 * shown and removed here. `index` is where it goes in `host`, -1 for the top; `bottomPadding` is the part of the host
 * the keyboard covers, so the placeholder is centred in what stays visible.
 */
internal class CYLSearchEmptyViewSlot(private val host: FrameLayout, private val index: Int, private val bottomPadding: () -> Int) {

    /**
     * The placeholder that the slot holds, or null.
     */
    var view: CYLPlaceholderStackView? = null
        private set

    /**
     * Puts `newView` in the host in place of the held one.
     */
    fun adopt(newView: CYLPlaceholderStackView, background: Int? = null) {
        remove()
        view = newView
        background?.let { newView.setBackgroundColor(it) }
        newView.setPadding(0, 0, 0, bottomPadding())
        host.addView(newView, index, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    /**
     * Shows or hides the held placeholder, made by `create` the first time it is shown.
     */
    fun setShowing(showing: Boolean, create: () -> CYLPlaceholderStackView) {
        if (showing && view == null) {
            adopt(create())
        }
        view?.visibility = if (showing) View.VISIBLE else View.GONE
    }

    /**
     * Reads the keyboard's part of the host again.
     */
    fun refreshPadding() {
        view?.setPadding(0, 0, 0, bottomPadding())
    }

    /**
     * Takes the placeholder out of the host.
     */
    fun remove() {
        view?.let { host.removeView(it) }
        view = null
    }
}

/**
 * The match highlight of the results (iOS `CYLSearchResultHighlight`): the first match of the query in a row's text takes
 * a color. The match ignores case and diacritics, like the suggestion filter: "cafe" and "CAFE" match "Caf\u00e9", also
 * written with a combining accent.
 */
internal object CYLSearchResultHighlight {

    /**
     * `text` in lower case and without diacritics (the rule of the suggestion filter and of the highlight).
     */
    fun fold(text: String): String =
        Normalizer.normalize(text, Normalizer.Form.NFD).replace(Regex("\\p{Mn}+"), "").lowercase(Locale.ROOT)

    /**
     * The range of the first match of the trimmed `query` in `text`, in the characters of `text`; null for no match or an
     * empty query.
     */
    fun firstMatch(text: CharSequence, query: String): IntRange? {
        val folded = fold(query.trim())
        if (folded.isEmpty()) {
            return null
        }
        val source = StringBuilder()
        val starts = ArrayList<Int>()
        val ends = ArrayList<Int>()
        var index = 0
        while (index < text.length) {
            val length = Character.charCount(Character.codePointAt(text, index))
            val piece = fold(text.subSequence(index, index + length).toString())
            if (piece.isEmpty() && ends.isNotEmpty()) {
                // A combining mark joins the character before it.
                ends[ends.size - 1] = index + length
            }
            for (character in piece) {
                source.append(character)
                starts.add(index)
                ends.add(index + length)
            }
            index += length
        }
        val found = source.indexOf(folded)
        if (found < 0) {
            return null
        }
        return starts[found] until ends[found + folded.length - 1]
    }

    /**
     * Gives the first match of `query` in the text of `label` `color`, keeping the spans the text already has.
     */
    fun apply(label: TextView, query: String, color: Int) {
        val text = label.text ?: return
        val range = firstMatch(text, query) ?: return
        val highlighted = SpannableString(text)
        highlighted.setSpan(ForegroundColorSpan(color), range.first, range.last + 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        label.text = highlighted
    }
}
