package com.cyl.search.example

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Test

/**
 * docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract", B: the refresh shows the NEXT PAGE,
 * cyclically; every page has exactly one hot record and its slot differs from the previous page's, the wrap-around included
 * (iOS `testDiscoverRefreshShowsTheNextPageWithTheHotTopicMoving`, Flutter `test/discover_data_test.dart`).
 */
class CYLSearchDiscoverDataTest {

    private val perPage = 6
    private val hotSlots = listOf(0, 3, 5, 1)

    private fun data(): CYLSearchDiscoverData {
        val topics = hotSlots.flatMapIndexed { page, hot ->
            (0 until perPage).map { slot ->
                CYLDiscoverTopic("topic ${page * perPage + slot}", if (slot == hot) "hot" else null)
            }
        }
        return CYLSearchDiscoverData(perPage, emptyList(), topics)
    }

    @Test
    fun theFirstScreenIsThePageZero() {
        val data = data()
        assertEquals(4, data.pages)
        assertEquals(data.topicsOnPage(0), data.initialTopics)
        assertEquals(perPage, data.initialTopics.size)
    }

    @Test
    fun refreshShowsTheNextPageCyclically() {
        val data = data()
        var page = 0
        val visited = ArrayList<Int>()
        repeat(2 * data.pages) {
            page = data.nextPage(page)
            visited.add(page)
        }
        assertEquals(listOf(1, 2, 3, 0, 1, 2, 3, 0), visited)
        assertEquals("the topics of a page are whole records in file order", "topic 6", data.topicsOnPage(1).first().title)
    }

    @Test
    fun everyPageHasOneHotRecordAndItsSlotMovesFromPageToPage() {
        val data = data()
        var page = 0
        var previousSlot = -1
        repeat(2 * data.pages) {
            page = data.nextPage(page)
            val shown = data.topicsOnPage(page)
            val hot = shown.withIndex().filter { it.value.icon == "hot" }.map { it.index }
            assertEquals("page $page has exactly one hot record", 1, hot.size)
            assertNotEquals("the hot slot moves ($page)", previousSlot, hot.single())
            previousSlot = hot.single()
        }
    }

    @Test
    fun anEmptyPoolHasNoPages() {
        val data = CYLSearchDiscoverData(0, emptyList(), emptyList())
        assertEquals(0, data.pages)
        assertEquals(emptyList<CYLDiscoverTopic>(), data.topicsOnPage(3))
        assertEquals(0, data.nextPage(5))
    }
}
