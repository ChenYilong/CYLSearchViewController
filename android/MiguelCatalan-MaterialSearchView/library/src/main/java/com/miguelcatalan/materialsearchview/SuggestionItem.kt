// Merged from MiguelCatalan/MaterialSearchView PR #153 ("Customize suggestions", by timob), translated to Kotlin.
// Apache License 2.0, see ../../../../../../LICENSE.
package com.miguelcatalan.materialsearchview

import androidx.annotation.DrawableRes

/**
 * A suggestion with its own icon; a sticky suggestion is always listed, even for an empty query.
 */
class SuggestionItem(
    val isSticky: Boolean,
    @DrawableRes val iconRes: Int,
    val text: String,
)
