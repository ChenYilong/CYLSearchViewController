// Kotlin transcription of MiguelCatalan/MaterialSearchView (commit 53e163c), Apache License 2.0, see ../../../../../../LICENSE.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX, setCursorDrawable uses
// TextView.setTextCursorDrawable on API 29+ (the private field it set before is not accessible there).
package com.miguelcatalan.materialsearchview

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Parcel
import android.os.Parcelable
import android.speech.RecognizerIntent
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.MenuItem
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.AdapterView
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.Filter
import android.widget.Filterable
import android.widget.ImageButton
import android.widget.ListAdapter
import android.widget.ListView
import android.widget.RelativeLayout
import android.widget.TextView
import com.miguelcatalan.materialsearchview.utils.AnimationUtil

/**
 * A Material Design search view that opens over the toolbar, with voice search and filtered suggestions.
 *
 * @author Miguel Catalan Bañuls
 */
class MaterialSearchView @JvmOverloads constructor(
    private val mContext: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout(mContext, attrs), Filter.FilterListener {

    companion object {
        const val REQUEST_VOICE = 9999
    }

    private var mMenuItem: MenuItem? = null
    private var mIsSearchOpen = false
    private var mAnimationDuration = 0
    private var mClearingFocus = false

    // Views
    private lateinit var mSearchLayout: View
    private lateinit var mTintView: View
    private lateinit var mSuggestionsListView: ListView
    private lateinit var mSearchSrcTextView: EditText
    private lateinit var mBackBtn: ImageButton
    private lateinit var mVoiceBtn: ImageButton
    private lateinit var mEmptyBtn: ImageButton
    private lateinit var mSearchTopBar: RelativeLayout

    private var mOldQueryText: CharSequence? = null
    private var mUserQuery: CharSequence? = null

    private var mOnQueryChangeListener: OnQueryTextListener? = null
    private var mSearchViewListener: SearchViewListener? = null

    private var mAdapter: ListAdapter? = null

    private var mSavedState: SavedState? = null
    private var submit = false

    private var ellipsize = false

    private var allowVoiceSearch = false
    private var suggestionIcon: Drawable? = null

    private val mOnClickListener = OnClickListener { v ->
        when (v) {
            mBackBtn -> closeSearch()
            mVoiceBtn -> onVoiceClicked()
            mEmptyBtn -> mSearchSrcTextView.text = null
            mSearchSrcTextView -> showSuggestions()
            mTintView -> closeSearch()
        }
    }

    init {
        initiateView()
        initStyle(attrs, defStyleAttr)
    }

    private fun initStyle(attrs: AttributeSet?, defStyleAttr: Int) {
        val a = mContext.obtainStyledAttributes(attrs, R.styleable.MaterialSearchView, defStyleAttr, 0)
        if (a.hasValue(R.styleable.MaterialSearchView_searchBackground)) {
            background = a.getDrawable(R.styleable.MaterialSearchView_searchBackground)
        }
        if (a.hasValue(R.styleable.MaterialSearchView_android_textColor)) {
            setTextColor(a.getColor(R.styleable.MaterialSearchView_android_textColor, 0))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_android_textColorHint)) {
            setHintTextColor(a.getColor(R.styleable.MaterialSearchView_android_textColorHint, 0))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_android_hint)) {
            setHint(a.getString(R.styleable.MaterialSearchView_android_hint))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_searchVoiceIcon)) {
            setVoiceIcon(a.getDrawable(R.styleable.MaterialSearchView_searchVoiceIcon))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_searchCloseIcon)) {
            setCloseIcon(a.getDrawable(R.styleable.MaterialSearchView_searchCloseIcon))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_searchBackIcon)) {
            setBackIcon(a.getDrawable(R.styleable.MaterialSearchView_searchBackIcon))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_searchSuggestionBackground)) {
            setSuggestionBackground(a.getDrawable(R.styleable.MaterialSearchView_searchSuggestionBackground))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_searchSuggestionIcon)) {
            setSuggestionIcon(a.getDrawable(R.styleable.MaterialSearchView_searchSuggestionIcon))
        }
        if (a.hasValue(R.styleable.MaterialSearchView_android_inputType)) {
            setInputType(a.getInt(R.styleable.MaterialSearchView_android_inputType, EditorInfo.TYPE_NULL))
        }
        a.recycle()
    }

    private fun initiateView() {
        LayoutInflater.from(mContext).inflate(R.layout.search_view, this, true)
        mSearchLayout = findViewById(R.id.search_layout)
        mSearchTopBar = mSearchLayout.findViewById(R.id.search_top_bar)
        mSuggestionsListView = mSearchLayout.findViewById(R.id.suggestion_list)
        mSearchSrcTextView = mSearchLayout.findViewById(R.id.searchTextView)
        mBackBtn = mSearchLayout.findViewById(R.id.action_up_btn)
        mVoiceBtn = mSearchLayout.findViewById(R.id.action_voice_btn)
        mEmptyBtn = mSearchLayout.findViewById(R.id.action_empty_btn)
        mTintView = mSearchLayout.findViewById(R.id.transparent_view)

        mSearchSrcTextView.setOnClickListener(mOnClickListener)
        mBackBtn.setOnClickListener(mOnClickListener)
        mVoiceBtn.setOnClickListener(mOnClickListener)
        mEmptyBtn.setOnClickListener(mOnClickListener)
        mTintView.setOnClickListener(mOnClickListener)

        allowVoiceSearch = false
        showVoice(true)
        initSearchView()
        mSuggestionsListView.visibility = GONE
        setAnimationDuration(AnimationUtil.ANIMATION_DURATION_MEDIUM)
    }

    private fun initSearchView() {
        mSearchSrcTextView.setOnEditorActionListener { _, _, _ ->
            onSubmitQuery()
            true
        }
        mSearchSrcTextView.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) = Unit

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                mUserQuery = s
                startFilter(s)
                this@MaterialSearchView.onTextChanged(s)
            }

            override fun afterTextChanged(s: Editable) = Unit
        })
        mSearchSrcTextView.setOnFocusChangeListener { _, hasFocus ->
            if (hasFocus) {
                showKeyboard(mSearchSrcTextView)
                showSuggestions()
            }
        }
    }

    private fun startFilter(s: CharSequence?) {
        (mAdapter as? Filterable)?.filter?.filter(s, this)
    }

    private fun onVoiceClicked() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
        // setting recognition model, optimized for short phrases – search queries
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_WEB_SEARCH)
        // quantity of results we want to receive
        intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
        @Suppress("DEPRECATION")
        (mContext as? Activity)?.startActivityForResult(intent, REQUEST_VOICE)
    }

    private fun onTextChanged(newText: CharSequence) {
        val text = mSearchSrcTextView.text
        mUserQuery = text
        val hasText = !TextUtils.isEmpty(text)
        if (hasText) {
            mEmptyBtn.visibility = VISIBLE
            showVoice(false)
        } else {
            mEmptyBtn.visibility = GONE
            showVoice(true)
        }
        if (mOnQueryChangeListener != null && !TextUtils.equals(newText, mOldQueryText)) {
            mOnQueryChangeListener?.onQueryTextChange(newText.toString())
        }
        mOldQueryText = newText.toString()
    }

    private fun onSubmitQuery() {
        val query = mSearchSrcTextView.text
        if (query != null && TextUtils.getTrimmedLength(query) > 0) {
            if (mOnQueryChangeListener == null || mOnQueryChangeListener?.onQueryTextSubmit(query.toString()) == false) {
                closeSearch()
                mSearchSrcTextView.text = null
            }
        }
    }

    // Transcribed as is: upstream reports voice as available when NO activity handles speech recognition.
    private fun isVoiceAvailable(): Boolean {
        if (isInEditMode) {
            return true
        }
        val activities = context.packageManager.queryIntentActivities(Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH), 0)
        return activities.size == 0
    }

    fun hideKeyboard(view: View) {
        val imm = view.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(view.windowToken, 0)
    }

    fun showKeyboard(view: View) {
        view.requestFocus()
        val imm = view.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showSoftInput(view, 0)
    }

    // Public Attributes

    override fun setBackground(background: Drawable?) {
        if (::mSearchTopBar.isInitialized) {
            mSearchTopBar.background = background
        } else {
            super.setBackground(background)
        }
    }

    override fun setBackgroundColor(color: Int) {
        mSearchTopBar.setBackgroundColor(color)
    }

    fun setTextColor(color: Int) {
        mSearchSrcTextView.setTextColor(color)
    }

    fun setHintTextColor(color: Int) {
        mSearchSrcTextView.setHintTextColor(color)
    }

    fun setHint(hint: CharSequence?) {
        mSearchSrcTextView.hint = hint
    }

    fun setVoiceIcon(drawable: Drawable?) {
        mVoiceBtn.setImageDrawable(drawable)
    }

    fun setCloseIcon(drawable: Drawable?) {
        mEmptyBtn.setImageDrawable(drawable)
    }

    fun setBackIcon(drawable: Drawable?) {
        mBackBtn.setImageDrawable(drawable)
    }

    fun setSuggestionIcon(drawable: Drawable?) {
        suggestionIcon = drawable
    }

    fun setInputType(inputType: Int) {
        mSearchSrcTextView.inputType = inputType
    }

    fun setSuggestionBackground(background: Drawable?) {
        mSuggestionsListView.background = background
    }

    fun setCursorDrawable(drawable: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            mSearchSrcTextView.setTextCursorDrawable(drawable)
            return
        }
        try {
            // https://github.com/android/platform_frameworks_base/blob/kitkat-release/core/java/android/widget/TextView.java#L562-564
            val f = TextView::class.java.getDeclaredField("mCursorDrawableRes")
            f.isAccessible = true
            f.set(mSearchSrcTextView, drawable)
        } catch (ignored: Exception) {
            Log.e("MaterialSearchView", ignored.toString())
        }
    }

    fun setVoiceSearch(voiceSearch: Boolean) {
        allowVoiceSearch = voiceSearch
    }

    // Public Methods

    /**
     * Call this method to show suggestions list. This shows up when adapter is set. Call [setAdapter] before calling this.
     */
    fun showSuggestions() {
        val adapter = mAdapter ?: return
        if (adapter.count > 0 && mSuggestionsListView.visibility == GONE) {
            mSuggestionsListView.visibility = VISIBLE
        }
    }

    /**
     * Submit the query as soon as the user clicks the item.
     */
    fun setSubmitOnClick(submit: Boolean) {
        this.submit = submit
    }

    /**
     * Set Suggest List OnItemClickListener
     */
    fun setOnItemClickListener(listener: AdapterView.OnItemClickListener?) {
        mSuggestionsListView.onItemClickListener = listener
    }

    /**
     * Set Adapter for suggestions list. Should implement Filterable.
     */
    fun setAdapter(adapter: ListAdapter?) {
        mAdapter = adapter
        mSuggestionsListView.adapter = adapter
        startFilter(mSearchSrcTextView.text)
    }

    /**
     * Set Adapter for suggestions list with the given suggestion array
     */
    fun setSuggestions(suggestions: Array<String>?) {
        if (!suggestions.isNullOrEmpty()) {
            mTintView.visibility = VISIBLE
            val adapter = SearchAdapter(mContext, suggestions, suggestionIcon, ellipsize)
            setAdapter(adapter)
            setOnItemClickListener { _, _, position, _ -> setQuery(adapter.getItem(position) as String, submit) }
        } else {
            mTintView.visibility = GONE
        }
    }

    /**
     * Dismiss the suggestions list.
     */
    fun dismissSuggestions() {
        if (mSuggestionsListView.visibility == VISIBLE) {
            mSuggestionsListView.visibility = GONE
        }
    }

    /**
     * Calling this will set the query to search text box. if submit is true, it'll submit the query.
     */
    fun setQuery(query: CharSequence?, submit: Boolean) {
        mSearchSrcTextView.setText(query)
        if (query != null) {
            mSearchSrcTextView.setSelection(mSearchSrcTextView.length())
            mUserQuery = query
        }
        if (submit && !TextUtils.isEmpty(query)) {
            onSubmitQuery()
        }
    }

    /**
     * if show is true, this will enable voice search. If voice is not available on the device, this method call has not effect.
     */
    fun showVoice(show: Boolean) {
        mVoiceBtn.visibility = if (show && isVoiceAvailable() && allowVoiceSearch) VISIBLE else GONE
    }

    /**
     * Call this method and pass the menu item so this class can handle click events for the Menu Item.
     */
    fun setMenuItem(menuItem: MenuItem) {
        mMenuItem = menuItem
        menuItem.setOnMenuItemClickListener {
            showSearch()
            true
        }
    }

    /**
     * Return true if search is open
     */
    fun isSearchOpen(): Boolean = mIsSearchOpen

    /**
     * Sets animation duration. ONLY FOR PRE-LOLLIPOP!!
     */
    fun setAnimationDuration(duration: Int) {
        mAnimationDuration = duration
    }

    /**
     * Open Search View. If animate is true, Animate the showing of the view.
     */
    @JvmOverloads
    fun showSearch(animate: Boolean = true) {
        if (isSearchOpen()) {
            return
        }
        // Request Focus
        mSearchSrcTextView.text = null
        mSearchSrcTextView.requestFocus()
        if (animate) {
            setVisibleWithAnimation()
        } else {
            mSearchLayout.visibility = VISIBLE
            mSearchViewListener?.onSearchViewShown()
        }
        mIsSearchOpen = true
    }

    private fun setVisibleWithAnimation() {
        val animationListener = object : AnimationUtil.AnimationListener {
            override fun onAnimationStart(view: View): Boolean = false

            override fun onAnimationEnd(view: View): Boolean {
                mSearchViewListener?.onSearchViewShown()
                return false
            }

            override fun onAnimationCancel(view: View): Boolean = false
        }
        mSearchLayout.visibility = VISIBLE
        AnimationUtil.reveal(mSearchTopBar, animationListener)
    }

    /**
     * Close search view.
     */
    fun closeSearch() {
        if (!isSearchOpen()) {
            return
        }
        mSearchSrcTextView.text = null
        dismissSuggestions()
        clearFocus()
        mSearchLayout.visibility = GONE
        mSearchViewListener?.onSearchViewClosed()
        mIsSearchOpen = false
    }

    /**
     * Set this listener to listen to Query Change events.
     */
    fun setOnQueryTextListener(listener: OnQueryTextListener?) {
        mOnQueryChangeListener = listener
    }

    /**
     * Set this listener to listen to Search View open and close events
     */
    fun setOnSearchViewListener(listener: SearchViewListener?) {
        mSearchViewListener = listener
    }

    /**
     * Ellipsize suggestions longer than one line.
     */
    fun setEllipsize(ellipsize: Boolean) {
        this.ellipsize = ellipsize
    }

    override fun onFilterComplete(count: Int) {
        if (count > 0) showSuggestions() else dismissSuggestions()
    }

    override fun requestFocus(direction: Int, previouslyFocusedRect: Rect?): Boolean {
        // Don't accept focus if in the middle of clearing focus
        if (mClearingFocus) return false
        // Check if SearchView is focusable.
        if (!isFocusable) return false
        return mSearchSrcTextView.requestFocus(direction, previouslyFocusedRect)
    }

    override fun clearFocus() {
        mClearingFocus = true
        hideKeyboard(this)
        super.clearFocus()
        mSearchSrcTextView.clearFocus()
        mClearingFocus = false
    }

    override fun onSaveInstanceState(): Parcelable {
        val state = SavedState(super.onSaveInstanceState())
        state.query = mUserQuery?.toString()
        state.isSearchOpen = mIsSearchOpen
        mSavedState = state
        return state
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        if (state !is SavedState) {
            super.onRestoreInstanceState(state)
            return
        }
        mSavedState = state
        if (state.isSearchOpen) {
            showSearch(false)
            setQuery(state.query, false)
        }
        super.onRestoreInstanceState(state.superState)
    }

    internal class SavedState : BaseSavedState {
        var query: String? = null
        var isSearchOpen = false

        constructor(superState: Parcelable?) : super(superState)

        private constructor(parcel: Parcel) : super(parcel) {
            query = parcel.readString()
            isSearchOpen = parcel.readInt() == 1
        }

        override fun writeToParcel(out: Parcel, flags: Int) {
            super.writeToParcel(out, flags)
            out.writeString(query)
            out.writeInt(if (isSearchOpen) 1 else 0)
        }

        companion object {
            // required field that makes Parcelables from a Parcel
            @JvmField
            val CREATOR: Parcelable.Creator<SavedState> = object : Parcelable.Creator<SavedState> {
                override fun createFromParcel(parcel: Parcel): SavedState = SavedState(parcel)

                override fun newArray(size: Int): Array<SavedState?> = arrayOfNulls(size)
            }
        }
    }

    interface OnQueryTextListener {
        /**
         * Called when the user submits the query. Return true when the listener handled it, false to let the
         * search view close.
         */
        fun onQueryTextSubmit(query: String): Boolean

        /**
         * Called when the query text is changed by the user. Return true when the listener handled it.
         */
        fun onQueryTextChange(newText: String): Boolean
    }

    interface SearchViewListener {
        fun onSearchViewShown()

        fun onSearchViewClosed()
    }
}
