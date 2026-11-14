// Kotlin transcription of MiguelCatalan/MaterialSearchView's sample (commit 53e163c), Apache License 2.0.
// Original author: Miguel Catalan Bañuls. Changes: Java to Kotlin, android.support to AndroidX.
package com.miguelcatalan.materialsearchview.sample

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment

/**
 * An empty page.
 *
 * @author Miguel Catalan Bañuls
 */
class DummyFragment : Fragment() {
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        // Inflate the layout for this fragment
        inflater.inflate(R.layout.fragment_dummy, container, false)
}
