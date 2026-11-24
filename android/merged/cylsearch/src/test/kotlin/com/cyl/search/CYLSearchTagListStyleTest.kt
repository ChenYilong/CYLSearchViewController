package com.cyl.search

import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLMenuStyle
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * docs/animated-icon-component.md, "Default layout contract", item 6: the core's default tag look is the iOS example's
 * (capsule tags, light border, bold header, 16 dp inset) and can be customized (iOS
 * `testDefaultTagStyleMatchesTheExampleRecentSearchesAndCanBeCustomized`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLSearchTagListStyleTest {

    @After
    fun resetDefaults() {
        CYLSearchTagListStyle.tagCornerRadius = CYLSearchTagListStyle.CAPSULE_CORNER_RADIUS
        CYLSearchTagListStyle.styleCustomizer = null
    }

    @Test
    fun defaultsAreTheIosRecentSearchesLook() {
        val style = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(style)
        val tag = style.appearanceForState(CYLControlState.NORMAL)
        assertEquals("a capsule", CYLSearchTagListStyle.CAPSULE_CORNER_RADIUS, tag.cornerRadius, 0f)
        assertEquals(1f, tag.borderWidth, 0f)
        assertEquals(14f, tag.margin, 0f)
        assertEquals(36f, style.itemHeight, 0f)
        assertEquals(12f, style.interitemSpacing, 0f)
        assertEquals(12f, style.lineSpacing, 0f)
        assertEquals(44f, style.headerHeight, 0f)
        assertEquals(16f, style.headerHorizontalInset, 0f)
        assertEquals(16f, style.sectionInsets.left, 0f)
        assertEquals(16f, style.sectionInsets.right, 0f)
    }

    @Test
    fun theRadiusAndAnyOtherValueCanBeCustomized() {
        CYLSearchTagListStyle.tagCornerRadius = 8f
        CYLSearchTagListStyle.styleCustomizer = { it.itemHeight = 44f }
        val style = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(style)
        assertEquals(8f, style.appearanceForState(CYLControlState.SELECTED).cornerRadius, 0f)
        assertEquals(44f, style.itemHeight, 0f)
    }

    @Test
    fun flatTagsAreWhiteWithTheIosSeparatorBorder() {
        val style = CYLMenuStyle()
        CYLSearchTagListStyle.applyDefaults(style)
        for (state in listOf(CYLControlState.NORMAL, CYLControlState.SELECTED, CYLControlState.DISABLED)) {
            val tag = style.appearanceForState(state)
            assertEquals(android.graphics.Color.WHITE, tag.backgroundColor)
            assertEquals(android.graphics.Color.argb(74, 60, 60, 67), tag.borderColor)
        }
    }

    @Test
    fun theGridIsBorderlessLikeTheIosDiscoverTopicsAndShowsImagesAtTheirOwnSize() {
        val style = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2)
        CYLSearchTagListStyle.applyGrid(style)
        val tag = style.appearanceForState(CYLControlState.NORMAL)
        assertEquals(0f, tag.borderWidth, 0f)
        assertEquals(com.cyl.classifymenu.CYLSize(0f, 0f), style.imageSize)
    }

    @Test
    fun theGridKeepsTheHeaderLookAndOneRowPerThirtySixDp() {
        val style = CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(2)
        CYLSearchTagListStyle.applyGrid(style)
        assertEquals(36f, style.itemHeight, 0f)
        assertEquals(16f, style.lineSpacing, 0f)
        assertEquals(16f, style.sectionInsets.left, 0f)
        assertEquals(44f, style.headerHeight, 0f)
    }
}
