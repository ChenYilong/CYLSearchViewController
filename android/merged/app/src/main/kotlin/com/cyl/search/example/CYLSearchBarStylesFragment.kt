package com.cyl.search.example

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.Switch
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.search.CYLSearchListView
import kotlin.random.Random

/**
 * A 30 x 30 stroked rounded square, the accessory view of QMUI's `QDSearchBarViewController`.
 */
class CYLStrokedSquareView(context: Context, color: Int) : View(context) {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        this.color = color
        style = Paint.Style.STROKE
        strokeWidth = 3 * resources.displayMetrics.density
    }

    init {
        val side = (30 * resources.displayMetrics.density).toInt()
        layoutParams = ViewGroup.LayoutParams(side, side)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        contentDescription = context.cylDemoText("styles.accessory.label")
    }

    override fun onDraw(canvas: Canvas) {
        val inset = paint.strokeWidth / 2
        canvas.drawRoundRect(RectF(inset, inset, width - inset, height - inset), 6 * resources.displayMetrics.density, 6 * resources.displayMetrics.density, paint)
    }
}

/**
 * The "Search bar styles" screen: a replica of QMUI's `QDSearchBarViewController` (QMUIDemo_iOS; iOS
 * `CYLSearchBarStylesViewController`). Sections Placeholder, Layout and AccessoryView drive the bar that is the first item
 * of the list (`CYLSearchListView`, edited in place).
 */
class CYLSearchBarStylesFragment : CYLExamplePage() {

    private enum class Row { CenterPlaceholder, ChangePlaceholder, AdjustField, AdjustCancel, Animated, ToggleCancel, ToggleLeading, ToggleTrailing }

    private sealed class Item {
        class Header(val key: String) : Item()
        class Line(val row: Row) : Item()
    }

    private val items = listOf(
        Item.Header("styles.section.placeholder"), Item.Line(Row.CenterPlaceholder), Item.Line(Row.ChangePlaceholder),
        Item.Header("styles.section.layout"), Item.Line(Row.AdjustField), Item.Line(Row.AdjustCancel),
        Item.Header("styles.section.accessory"), Item.Line(Row.Animated), Item.Line(Row.ToggleCancel), Item.Line(Row.ToggleLeading), Item.Line(Row.ToggleTrailing),
    )
    private var animated = true
    private lateinit var list: CYLSearchListView
    private val adapter = StylesAdapter()

    override fun pageTitle(context: Context) = context.cylDemoText("demo.searchBarStyles")

    override fun createContent(context: Context): View {
        list = CYLSearchListView(context)
        list.opensSearchViewOnTap = false
        list.adapter = adapter
        val colors = intArrayOf(Color.RED, Color.BLUE, Color.rgb(0, 160, 0), Color.rgb(255, 140, 0), Color.rgb(130, 60, 200), Color.rgb(0, 150, 150))
        list.searchBarView.apply {
            // As QMUI's demo: the accessories are hidden first, shown by the person.
            leadingAccessoryView = CYLStrokedSquareView(context, colors[Random.nextInt(colors.size)])
            trailingAccessoryView = CYLStrokedSquareView(context, colors[Random.nextInt(colors.size)])
            leadingAccessoryViewMargins = Rect(8, 0, 0, 0)
            trailingAccessoryViewMargins = Rect(0, 0, 8, 0)
            showsLeadingAccessoryView = false
            showsTrailingAccessoryView = false
        }
        return list
    }

    private fun title(context: Context, row: Row): String {
        val bar = list.searchBarView
        fun toggle(shown: Boolean, key: String) = context.cylDemoText(if (shown) "styles.hide" else "styles.show").format(context.cylDemoText(key))
        return when (row) {
            Row.CenterPlaceholder -> context.cylDemoText("styles.centerPlaceholder")
            Row.ChangePlaceholder -> context.cylDemoText("styles.changePlaceholder")
            Row.AdjustField -> context.cylDemoText("styles.adjustField")
            Row.AdjustCancel -> context.cylDemoText("styles.adjustCancel")
            Row.Animated -> context.cylDemoText("styles.animated")
            Row.ToggleCancel -> toggle(bar.showsCancelButton, "styles.cancel")
            Row.ToggleLeading -> toggle(bar.showsLeadingAccessoryView, "styles.leading")
            Row.ToggleTrailing -> toggle(bar.showsTrailingAccessoryView, "styles.trailing")
        }
    }

    private fun selected(row: Row, position: Int) {
        val bar = list.searchBarView
        when (row) {
            Row.ChangePlaceholder -> bar.placeholder = requireContext().cylDemoText("styles.longPlaceholder")
            Row.AdjustField -> bar.textFieldMarginsProvider = { _, active -> if (active) Rect() else Rect(32, 0, 32, 0) }
            Row.AdjustCancel -> {
                bar.cancelButtonMarginsProvider = { _, active -> if (active) Rect(-16, 0, 0, 0) else Rect() }
                // Starts the search: the bar must be in sight and the field gets the focus.
                list.recyclerView.scrollToPosition(0)
                list.recyclerView.post { if (!bar.isActive) bar.showKeyboard() }
            }
            Row.ToggleCancel -> { bar.setShowsCancelButton(!bar.showsCancelButton, animated); adapter.notifyItemChanged(position) }
            Row.ToggleLeading -> { bar.setShowsLeadingAccessoryView(!bar.showsLeadingAccessoryView, animated); adapter.notifyItemChanged(position) }
            Row.ToggleTrailing -> { bar.setShowsTrailingAccessoryView(!bar.showsTrailingAccessoryView, animated); adapter.notifyItemChanged(position) }
            Row.CenterPlaceholder, Row.Animated -> Unit
        }
    }

    private inner class StylesAdapter : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = items.size

        override fun getItemViewType(position: Int) = if (items[position] is Item.Header) 0 else 1

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val context = parent.context
            val density = context.resources.displayMetrics.density
            val row = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT)
            }
            val text = TextView(context)
            if (viewType == 0) {
                text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                text.setTextColor(Color.GRAY)
                text.setPadding((16 * density).toInt(), (20 * density).toInt(), (16 * density).toInt(), (6 * density).toInt())
                androidx.core.view.ViewCompat.setAccessibilityHeading(text, true)
                row.addView(text, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            } else {
                text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
                row.minimumHeight = (56 * density).toInt()
                row.setPadding((16 * density).toInt(), (8 * density).toInt(), (16 * density).toInt(), (8 * density).toInt())
                row.isClickable = true
                row.isFocusable = true
                row.foreground = androidx.core.content.ContextCompat.getDrawable(context, TypedValue().also {
                    context.theme.resolveAttribute(android.R.attr.selectableItemBackground, it, true)
                }.resourceId)
                row.addView(text, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            }
            return object : RecyclerView.ViewHolder(row) {}
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val context = holder.itemView.context
            val rowView = holder.itemView as LinearLayout
            val text = rowView.getChildAt(0) as TextView
            while (rowView.childCount > 1) rowView.removeViewAt(1)
            when (val item = items[position]) {
                is Item.Header -> text.text = context.cylDemoText(item.key)
                is Item.Line -> {
                    text.text = title(context, item.row)
                    rowView.contentDescription = text.text
                    rowView.tag = "CYLSearchBarStylesRow${item.row.ordinal}"
                    ViewCompatHint.set(rowView, context.cylDemoText("styles.row.hint"))
                    if (item.row == Row.CenterPlaceholder || item.row == Row.Animated) {
                        val toggle = Switch(context)
                        toggle.isChecked = if (item.row == Row.Animated) animated else list.searchBarView.centersPlaceholder
                        toggle.contentDescription = text.text
                        toggle.setOnCheckedChangeListener { _, checked ->
                            if (item.row == Row.Animated) animated = checked else list.searchBarView.centersPlaceholder = checked
                        }
                        rowView.addView(toggle)
                        rowView.setOnClickListener { toggle.toggle() }
                    } else {
                        rowView.setOnClickListener { selected(item.row, holder.bindingAdapterPosition) }
                    }
                }
            }
        }
    }

    private object ViewCompatHint {
        fun set(view: View, hint: String) {
            view.accessibilityDelegate = object : View.AccessibilityDelegate() {
                override fun onInitializeAccessibilityNodeInfo(host: View, info: android.view.accessibility.AccessibilityNodeInfo) {
                    super.onInitializeAccessibilityNodeInfo(host, info)
                    info.hintText = hint
                }
            }
        }
    }
}
