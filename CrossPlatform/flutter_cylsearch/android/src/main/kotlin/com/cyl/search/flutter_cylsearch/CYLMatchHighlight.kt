package com.cyl.search.flutter_cylsearch

import java.text.Normalizer
import java.util.Locale

/**
 * Finds the first match of a query in a result text the way the iOS core's `highlightsResultMatches` does: ignoring case
 * and diacritics ("e" matches "É"). The Android core has no highlight option yet, so the plugin keeps this one pure function
 * (TODO in docs/qmui-search-controller.md: move it into the core).
 */
internal object CYLMatchHighlight {

    /**
     * The range of `text` (UTF-16 indexes into the original text) of the first match of `query`, or null when the query is
     * empty or does not occur.
     */
    fun firstMatch(text: String, query: String): IntRange? {
        val needle = fold(query).first
        if (needle.isEmpty()) return null
        val (haystack, origins) = fold(text)
        val start = haystack.indexOf(needle)
        if (start < 0) return null
        // The match ends after the last original character that produced one of the matched folded characters.
        return origins[start]..origins[start + needle.length - 1]
    }

    /**
     * The folded text (no combining marks, lower case) and, for each folded character, the index of the original character
     * it comes from.
     */
    private fun fold(text: String): Pair<String, IntArray> {
        val folded = StringBuilder()
        val origins = ArrayList<Int>()
        text.forEachIndexed { index, char ->
            val decomposed = Normalizer.normalize(char.toString(), Normalizer.Form.NFD)
            for (part in decomposed) {
                if (Character.getType(part) == Character.NON_SPACING_MARK.toInt()) continue
                for (lower in part.toString().lowercase(Locale.ROOT)) {
                    folded.append(lower)
                    origins.add(index)
                }
            }
        }
        return folded.toString() to origins.toIntArray()
    }
}
