// Kotlin transcription of MiguelCatalan/MaterialSearchView (commit 53e163c), Apache License 2.0, see ../../../../../../LICENSE.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin. Merged open pull requests (translated):
// #153 SuggestionItem (sticky items, an icon per item), #176 checkWholeString ("contains" instead of "starts with"),
// #127 is covered by #176's flag, #114 default suggestions for an empty query, #220 as a text color setting.
// getItem() still returns the suggestion text, so existing callers keep working; getSuggestionItem() returns the item.
package com.miguelcatalan.materialsearchview

import android.content.Context
import android.graphics.drawable.Drawable
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.Filter
import android.widget.Filterable
import android.widget.ImageView
import android.widget.TextView

/**
 * Suggestions Adapter: lists the suggestions that match the query.
 *
 * @author Miguel Catalan Bañuls
 */
class SearchAdapter(
    context: Context,
    private val items: Array<SuggestionItem>,
    private val suggestionIcon: Drawable?,
    private val ellipsize: Boolean,
    private val checkWholeString: Boolean,
) : BaseAdapter(), Filterable {

    private var data: List<SuggestionItem> = ArrayList()
    private val inflater: LayoutInflater = LayoutInflater.from(context)
    private var defaultSuggestions: Array<String>? = null
    private var searchCovered = false

    /**
     * The color of the suggestion text; null keeps the layout's color (PR #220 made it white).
     */
    var textColor: Int? = null
        set(value) {
            field = value
            notifyDataSetChanged()
        }

    @JvmOverloads
    constructor(context: Context, suggestions: Array<String>, suggestionIcon: Drawable? = null, ellipsize: Boolean = false) :
        this(context, suggestions.toItems(), suggestionIcon, ellipsize, false)

    /**
     * PR #176: `checkWholeString` matches anywhere in the suggestion instead of at its start.
     */
    constructor(context: Context, suggestions: Array<String>, suggestionIcon: Drawable?, ellipsize: Boolean, checkWholeString: Boolean) :
        this(context, suggestions.toItems(), suggestionIcon, ellipsize, checkWholeString)

    /**
     * PR #114: `defaultSuggestions` are listed while the query is empty.
     */
    constructor(context: Context, suggestions: Array<String>, defaultSuggestions: Array<String>?, suggestionIcon: Drawable?, ellipsize: Boolean) :
        this(context, suggestions.toItems(), suggestionIcon, ellipsize, false) {
        this.defaultSuggestions = defaultSuggestions
    }

    /**
     * PR #153: suggestions with their own icons; sticky ones are always listed.
     */
    constructor(context: Context, suggestions: Array<SuggestionItem>, ellipsize: Boolean) :
        this(context, suggestions, null, ellipsize, false)

    /**
     * PR #114: the suggestions to list while the query is empty.
     */
    fun setDefaultSuggestions(suggestions: Array<String>?) {
        defaultSuggestions = suggestions
    }

    /**
     * PR #114: while covered, the default suggestions are not listed.
     */
    fun setSearchCovered(searchCovered: Boolean) {
        this.searchCovered = searchCovered
    }

    override fun getFilter(): Filter = object : Filter() {
        override fun performFiltering(constraint: CharSequence?): FilterResults {
            val filterResults = FilterResults()
            val searchData = ArrayList<SuggestionItem>()
            if (TextUtils.isEmpty(constraint)) {
                items.filterTo(searchData) { it.isSticky }
                if (!searchCovered) {
                    defaultSuggestions?.forEach { searchData.add(SuggestionItem(false, 0, it)) }
                }
            } else {
                // Retrieve the autocomplete results.
                val query = constraint.toString().lowercase()
                items.filterTo(searchData) { item ->
                    val text = item.text.lowercase()
                    item.isSticky || if (checkWholeString) text.contains(query) else text.startsWith(query)
                }
            }
            // Assign the data to the FilterResults (nothing for an empty query without sticky or default items).
            if (searchData.isNotEmpty() || !TextUtils.isEmpty(constraint)) {
                filterResults.values = searchData
                filterResults.count = searchData.size
            }
            return filterResults
        }

        @Suppress("UNCHECKED_CAST")
        override fun publishResults(constraint: CharSequence?, results: FilterResults) {
            if (results.values != null) {
                data = results.values as List<SuggestionItem>
                notifyDataSetChanged()
            }
        }
    }

    override fun getCount(): Int = data.size

    /**
     * The suggestion text at `position`.
     */
    override fun getItem(position: Int): Any = data[position].text

    /**
     * The suggestion item at `position` (PR #153).
     */
    fun getSuggestionItem(position: Int): SuggestionItem = data[position]

    override fun getItemId(position: Int): Long = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = convertView ?: inflater.inflate(R.layout.suggest_item, parent, false).also { it.tag = SuggestionsViewHolder(it) }
        val viewHolder = view.tag as SuggestionsViewHolder
        val item = data[position]
        viewHolder.textView.text = item.text
        textColor?.let { viewHolder.textView.setTextColor(it) }
        when {
            item.iconRes != 0 -> viewHolder.imageView.setImageResource(item.iconRes)
            suggestionIcon != null -> viewHolder.imageView.setImageDrawable(suggestionIcon)
        }
        if (ellipsize) {
            viewHolder.textView.isSingleLine = true
            viewHolder.textView.ellipsize = TextUtils.TruncateAt.END
        }
        return view
    }

    private class SuggestionsViewHolder(convertView: View) {
        val textView: TextView = convertView.findViewById(R.id.suggestion_text)
        val imageView: ImageView = convertView.findViewById(R.id.suggestion_icon)
    }
}

private fun Array<String>.toItems(): Array<SuggestionItem> = Array(size) { SuggestionItem(false, 0, this[it]) }
