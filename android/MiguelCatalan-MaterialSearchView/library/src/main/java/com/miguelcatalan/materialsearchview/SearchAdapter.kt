// Kotlin transcription of MiguelCatalan/MaterialSearchView (commit 53e163c), Apache License 2.0, see ../../../../../../LICENSE.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin.
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
 * Suggestions Adapter: lists the suggestions that start with the query.
 *
 * @author Miguel Catalan Bañuls
 */
class SearchAdapter @JvmOverloads constructor(
    context: Context,
    private val suggestions: Array<String>,
    private val suggestionIcon: Drawable? = null,
    private val ellipsize: Boolean = false,
) : BaseAdapter(), Filterable {

    private var data: List<String> = ArrayList()
    private val inflater: LayoutInflater = LayoutInflater.from(context)

    override fun getFilter(): Filter = object : Filter() {
        override fun performFiltering(constraint: CharSequence?): FilterResults {
            val filterResults = FilterResults()
            if (!TextUtils.isEmpty(constraint)) {
                // Retrieve the autocomplete results.
                val searchData = suggestions.filter { it.lowercase().startsWith(constraint.toString().lowercase()) }
                // Assign the data to the FilterResults
                filterResults.values = searchData
                filterResults.count = searchData.size
            }
            return filterResults
        }

        @Suppress("UNCHECKED_CAST")
        override fun publishResults(constraint: CharSequence?, results: FilterResults) {
            if (results.values != null) {
                data = results.values as List<String>
                notifyDataSetChanged()
            }
        }
    }

    override fun getCount(): Int = data.size

    override fun getItem(position: Int): Any = data[position]

    override fun getItemId(position: Int): Long = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = convertView ?: inflater.inflate(R.layout.suggest_item, parent, false).also { it.tag = SuggestionsViewHolder(it) }
        val viewHolder = view.tag as SuggestionsViewHolder
        viewHolder.textView.text = getItem(position) as String
        if (ellipsize) {
            viewHolder.textView.isSingleLine = true
            viewHolder.textView.ellipsize = TextUtils.TruncateAt.END
        }
        return view
    }

    private inner class SuggestionsViewHolder(convertView: View) {
        val textView: TextView = convertView.findViewById(R.id.suggestion_text)
        val imageView: ImageView? = suggestionIcon?.let { icon ->
            convertView.findViewById<ImageView>(R.id.suggestion_icon).also { it.setImageDrawable(icon) }
        }
    }
}
