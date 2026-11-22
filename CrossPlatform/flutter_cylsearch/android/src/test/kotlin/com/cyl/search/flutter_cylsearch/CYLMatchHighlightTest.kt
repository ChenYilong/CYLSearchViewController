package com.cyl.search.flutter_cylsearch

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class CYLMatchHighlightTest {

    @Test
    fun matchesIgnoringCase() {
        assertEquals(1..3, CYLMatchHighlight.firstMatch("Health", "EAL"))
    }

    @Test
    fun matchesIgnoringDiacriticsInTheResult() {
        // "é" in the text matches an "e" in the query, and the range covers the original character.
        assertEquals(2..4, CYLMatchHighlight.firstMatch("Cafés", "fes"))
        assertEquals(0..3, CYLMatchHighlight.firstMatch("Éclair", "ecla"))
    }

    @Test
    fun matchesIgnoringDiacriticsInTheQuery() {
        assertEquals(0..3, CYLMatchHighlight.firstMatch("Ecla", "Écla"))
    }

    @Test
    fun theIndexesAreOfTheOriginalTextAfterDecomposition() {
        // "Zoë Éa": the decomposed "ë" and "É" are two UTF-16 characters each in NFD, the original ones are one.
        assertEquals(4..5, CYLMatchHighlight.firstMatch("Zoë Éa", "ea"))
    }

    @Test
    fun firstMatchOnly() {
        assertEquals(0..1, CYLMatchHighlight.firstMatch("abab", "AB"))
    }

    @Test
    fun noMatchForEmptyOrAbsentQuery() {
        assertNull(CYLMatchHighlight.firstMatch("Health", ""))
        assertNull(CYLMatchHighlight.firstMatch("Health", "zz"))
    }
}
