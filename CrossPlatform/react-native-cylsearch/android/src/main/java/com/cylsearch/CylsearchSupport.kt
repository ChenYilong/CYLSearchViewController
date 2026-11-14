package com.cylsearch

import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.Event

/**
 * The strings of a JavaScript array.
 */
internal fun ReadableArray?.cylStrings(): List<String> = (0 until (this?.size() ?: 0)).map { this?.getString(it).orEmpty() }

/**
 * The fold control for "none", "inline", "bottom", "topTrailing" or "topLeading" and "icon", "title" or "iconAndTitle";
 * an inline icon by default.
 */
internal fun cylFoldControl(position: String?, content: String?) = CYLMenuFoldControl().apply {
  this.position = when (position) {
    "none" -> CYLMenuFoldControlPosition.CYLMenuFoldControlPositionNone
    "bottom" -> CYLMenuFoldControlPosition.CYLMenuFoldControlPositionBottom
    "topTrailing" -> CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopTrailing
    "topLeading" -> CYLMenuFoldControlPosition.CYLMenuFoldControlPositionTopLeading
    else -> CYLMenuFoldControlPosition.CYLMenuFoldControlPositionInline
  }
  this.content = when (content) {
    "iconAndTitle" -> CYLMenuFoldControlContent.CYLMenuFoldControlContentIconAndTitle
    "title" -> CYLMenuFoldControlContent.CYLMenuFoldControlContentTitle
    else -> CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon
  }
}

/**
 * A direct event with a name ("topTextChange", ...) and its data.
 */
internal class CylsearchEvent(surfaceId: Int, viewId: Int, private val name: String, private val data: WritableMap) :
  Event<CylsearchEvent>(surfaceId, viewId) {
  override fun getEventName() = name
  override fun getEventData(): WritableMap = data
}

/**
 * Builds the data of an event.
 */
internal fun cylEventData(vararg pairs: Pair<String, Any>): WritableMap = Arguments.createMap().apply {
  for ((key, value) in pairs) {
    when (value) {
      is String -> putString(key, value)
      is Int -> putInt(key, value)
      is Double -> putDouble(key, value)
      is Boolean -> putBoolean(key, value)
    }
  }
}
