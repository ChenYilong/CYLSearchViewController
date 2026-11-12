package com.cyl.search

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager

/**
 * Events of a `CYLSearchController`.
 */
interface CYLSearchControllerDelegate {

    /**
     * Cancel was tapped and the overlay is gone. Optional.
     */
    fun searchControllerDidCancel(controller: CYLSearchController) {}
}

/**
 * An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController` (iOS
 * `CYLSearchController`). The results controller's search bar shows Cancel; Cancel and the back key close the
 * overlay. Keep the controller while it is presented.
 */
class CYLSearchController() : Fragment() {

    /**
     * Creates the overlay with the data source of its results.
     */
    constructor(searchDataSource: CYLSearchResultsDataSource) : this() {
        resultsViewController.searchDataSource = searchDataSource
    }

    /**
     * Receives the cancel event.
     */
    var delegate: CYLSearchControllerDelegate? = null

    /**
     * The results controller shown inside the overlay.
     */
    val resultsViewController: CYLSearchResultsViewController = CYLSearchResultsViewController()

    /**
     * True while the overlay is on screen or animating in.
     */
    var isPresented: Boolean = false
        private set

    private var dismissing = false
    private var hostManager: FragmentManager? = null
    private val dismissCompletions = mutableListOf<() -> Unit>()
    private val backCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() = cancelSearch()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val frame = FrameLayout(requireContext())
        frame.id = View.generateViewId()
        frame.isClickable = true
        frame.setBackgroundColor(requireContext().obtainStyledAttributes(intArrayOf(android.R.attr.colorBackground)).run {
            getColor(0, 0).also { recycle() }
        })
        ViewCompat.setOnApplyWindowInsetsListener(frame) { view, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            view.setPadding(bars.left, bars.top, bars.right, 0)
            insets
        }
        return frame
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        if (!resultsViewController.isAdded) {
            childFragmentManager.beginTransaction().add(view.id, resultsViewController).commitNow()
        }
        resultsViewController.searchController.showsCancelButton = true
        resultsViewController.searchController.delegate = object : CYLSearchBarViewDelegate {
            override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = resultsViewController.updateSearchResults()
            override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView) = searchBarView.hideKeyboard()
            override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = cancelSearch()
        }
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, backCallback)
        val distance = 44 * resources.displayMetrics.density
        view.translationY = distance
        view.alpha = 0f
        view.animate().translationY(0f).alpha(1f).setDuration(ANIMATION_DURATION).start()
        resultsViewController.searchController.showKeyboard()
    }

    /**
     * Adds the overlay over the host activity's content and animates it into view.
     */
    fun showInViewController(controller: FragmentActivity) = show(controller.supportFragmentManager)

    /**
     * Adds the overlay over the host fragment's activity content and animates it into view.
     */
    fun showInViewController(controller: Fragment) = show(controller.requireActivity().supportFragmentManager)

    private fun show(manager: FragmentManager) {
        if (isPresented || dismissing) {
            return
        }
        isPresented = true
        hostManager = manager
        manager.beginTransaction().add(android.R.id.content, this).commitNow()
    }

    /**
     * Completion is called after the overlay is removed, including when not presented.
     */
    fun hide(completion: (() -> Unit)?) {
        completion?.let { dismissCompletions.add(it) }
        if (dismissing) {
            return
        }
        val overlay = view
        val manager = hostManager
        if (!isPresented || overlay == null || manager == null) {
            completeDismissal()
            return
        }
        dismissing = true
        resultsViewController.searchController.hideKeyboard()
        overlay.animate().translationY(44 * resources.displayMetrics.density).alpha(0f).setDuration(ANIMATION_DURATION).withEndAction {
            manager.beginTransaction().remove(this).commitNowAllowingStateLoss()
            hostManager = null
            isPresented = false
            dismissing = false
            completeDismissal()
        }.start()
    }

    private fun completeDismissal() {
        val completions = dismissCompletions.toList()
        dismissCompletions.clear()
        completions.forEach { it() }
    }

    private fun cancelSearch() {
        hide { delegate?.searchControllerDidCancel(this) }
    }

    private companion object {
        const val ANIMATION_DURATION = 250L
    }
}
