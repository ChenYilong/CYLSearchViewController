package com.iammert.library.ui.multisearchviewlib

import android.content.Context
import android.util.AttributeSet
import android.widget.RelativeLayout
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import com.iammert.library.ui.multisearchviewlib.databinding.ViewMultiSearchBinding
import com.iammert.library.ui.multisearchviewlib.extensions.inflate

class MultiSearchView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) :
    RelativeLayout(context, attrs, defStyleAttr) {

    interface MultiSearchViewListener {

        fun onTextChanged(index: Int, s: CharSequence)

        fun onSearchComplete(index: Int, s: CharSequence)

        fun onSearchItemRemoved(index: Int)

        fun onItemSelected(index: Int, s: CharSequence)
    }

    private val binding = inflate<ViewMultiSearchBinding>(R.layout.view_multi_search)

    init {
        val typedArray = context.theme.obtainStyledAttributes(attrs, R.styleable.MultiSearchView, defStyleAttr, defStyleAttr)
        val searchTextStyle = typedArray.getResourceId(R.styleable.MultiSearchView_searchTextStyle, 0)
        // Merged from upstream PRs #16 ("Icon feature") and #17 ("selected tab dot style feature"), by kojofosu.
        val imageSource = typedArray.getResourceId(R.styleable.MultiSearchView_searchIcon, R.drawable.ic_round_search_24px)
        val searchIconColor = typedArray.getResourceId(R.styleable.MultiSearchView_searchIconColor, android.R.color.black)
        val selectedTabStyle = typedArray.getInteger(R.styleable.MultiSearchView_selectedTabStyle, 0)
        typedArray.recycle()

        binding.searchViewContainer.apply {
            this.searchTextStyle = searchTextStyle
            this.selectedTabStyle = selectedTabStyle
        }
        setSearchIconDrawable(imageSource)
        setSearchIconColor(searchIconColor)

        binding.imageViewSearch.setOnClickListener {
            if (binding.searchViewContainer.isInSearchMode().not()) {
                binding.searchViewContainer.search()
            } else {
                binding.searchViewContainer.completeSearch()
            }
        }
    }

    /**
     * Replaces the search icon (upstream PR #16).
     */
    fun setSearchIconDrawable(@DrawableRes drawable: Int) {
        binding.imageViewSearch.setImageResource(drawable)
    }

    /**
     * Tints the search icon with a color resource (upstream PR #16).
     */
    fun setSearchIconColor(@ColorRes color: Int) {
        binding.imageViewSearch.imageTintList = AppCompatResources.getColorStateList(context, color)
    }

    fun setSearchViewListener(multiSearchViewListener: MultiSearchViewListener) {
        binding.searchViewContainer.setSearchViewListener(multiSearchViewListener)
    }
}