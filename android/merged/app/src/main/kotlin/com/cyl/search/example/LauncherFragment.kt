package com.cyl.search.example

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment

/**
 * A tab that opens the activities of one upstream sample.
 */
class LauncherFragment : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val args = requireArguments()
        val density = resources.displayMetrics.density
        val padding = (16 * density).toInt()
        return LinearLayout(requireContext()).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(padding, padding * 3, padding, padding)
            addView(TextView(context).apply {
                text = args.getString(ARG_TITLE)
                textSize = 20f
                setPadding(0, 0, 0, padding)
            })
            val labels = args.getStringArray(ARG_LABELS).orEmpty()
            val classes = args.getStringArray(ARG_CLASSES).orEmpty()
            labels.zip(classes).forEach { (label, className) ->
                addView(Button(context).apply {
                    text = label
                    isAllCaps = false
                    setOnClickListener { startActivity(Intent().setClassName(requireContext(), className)) }
                }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            }
        }
    }

    companion object {
        private const val ARG_TITLE = "title"
        private const val ARG_LABELS = "labels"
        private const val ARG_CLASSES = "classes"

        fun newInstance(title: String, items: List<Pair<String, Class<out Activity>>>) = LauncherFragment().apply {
            arguments = bundleOf(
                ARG_TITLE to title,
                ARG_LABELS to items.map { it.first }.toTypedArray(),
                ARG_CLASSES to items.map { it.second.name }.toTypedArray(),
            )
        }
    }
}
