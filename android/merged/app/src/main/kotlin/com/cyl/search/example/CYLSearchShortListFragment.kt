package com.cyl.search.example

import android.content.Context
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchListView
import com.cyl.search.CYLSearchResources

/**
 * The "Short list" screen (the issue scenario I4, QMUI #1160, iOS `CYLSearchShortListDemoViewController`): three rows
 * under the search bar, which scrolls out at first and settles fully shown or hidden (`snapsHeaderSearchBar`).
 */
class CYLSearchShortListFragment : CYLExamplePage() {

    override fun pageTitle(context: Context) = context.cylDemoText("demo.shortList")

    override fun createContent(context: Context): View {
        val list = CYLSearchListView(context)
        list.hidesSearchBarInitially = true
        list.searchBarView.placeholder = CYLSearchResources.localizedString(context, "search.field")
        list.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount() = 3

            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
                val density = parent.resources.displayMetrics.density
                return object : RecyclerView.ViewHolder(TextView(parent.context).apply {
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
                    gravity = Gravity.CENTER_VERTICAL
                    minHeight = (56 * density).toInt()
                    setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
                    layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT)
                }) {}
            }

            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
                (holder.itemView as TextView).text = holder.itemView.context.cylDemoText("shortList.row").format(position + 1)
            }
        }
        return list
    }
}
