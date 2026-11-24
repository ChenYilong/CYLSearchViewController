//
//  CYLSearchTagListHeader.swift
//  CYLSearchViewController
//
//  The section header of a tag list (CollectionViewClassifyMenu's CYLTagListView): its trailing refresh icon. The
//  header's title, the clear (trash) button and the 16 pt inset come from CollectionViewClassifyMenu; the Flutter and
//  React Native bridges call this so that no example draws a header of its own (docs/animated-icon-component.md,
//  "Default layout contract").
//

import CollectionViewClassifyMenu
import UIKit

/**
 * The refresh icon and text of a tag list's section header, one place for every bridge.
 */
@objc(CYLSearchTagListHeader)
public final class CYLSearchTagListHeader: NSObject {

    /**
     * The refresh icon, the SF Symbol "arrow.clockwise": the icon is the default, not a text button.
     */
    @objc public static var refreshImage: UIImage? {
        UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .regular))
    }

    /**
     * The VoiceOver label of the refresh icon, in the language the app shows ("Refresh", 更新, 刷新, 重新整理).
     */
    @objc public static var refreshAccessibilityLabel: String {
        CYLSearchResources.localizedString(forKey: "tagList.refresh")
    }

    /**
     * Sets the refresh icon as the icon of `list`'s header More button (`menuShowsMoreButton(inSection:)`), in place of
     * the three dots.
     */
    @objc(applyRefreshIconToList:)
    public static func applyRefreshIcon(to list: CYLTagListView) {
        let style = list.style.copy() as! CYLMenuStyle
        style.moreButtonImage = refreshImage
        list.style = style
    }
}
