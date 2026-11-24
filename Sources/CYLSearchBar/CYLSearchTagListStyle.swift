//
//  CYLSearchTagListStyle.swift
//  CYLSearchViewController
//
//  The default look of the tag lists that sit with a search bar (recent searches, topics): capsule tags with a light
//  border, a bold section header, one 16 pt inset. It is set here, in the search bar core, through the public API of
//  CollectionViewClassifyMenu's CYLMenuStyle; the tag list itself is not changed. The Flutter and React Native bridges
//  call it, so no example writes a tag style of its own (docs/animated-icon-component.md, "Default layout contract").
//

import CollectionViewClassifyMenu
import UIKit

/**
 * The search bar core's default style of a tag list, the look of the iOS example's recent searches.
 */
@objc(CYLSearchTagListStyle)
public final class CYLSearchTagListStyle: NSObject {

    /**
     * The corner radius of every tag. 0 or less (the default) is a capsule, as in the iOS example's recent searches;
     * `CYLTagCornerRadiusSquare` is square; another value in points is a rounded rectangle.
     */
    @objc public static var tagCornerRadius: CGFloat = 0

    /**
     * Called with the style after the defaults are set, to change any value of it. nil by default.
     */
    @objc public static var styleCustomizer: ((CYLMenuStyle) -> Void)?

    /**
     * Sets the defaults on `style`: white tags with a 1 pt separator border and `tagCornerRadius`, 17 pt text, 36 pt
     * high, 12 pt apart, a 16 pt section inset and a bold 20 pt section header, then calls `styleCustomizer`. Values the
     * defaults do not name (for example the clear background) stay as they are.
     */
    @objc(applyDefaultsToStyle:)
    public static func applyDefaults(to style: CYLMenuStyle) {
        for state in [UIControl.State.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = .systemBackground
            appearance.borderColor = .separator
            appearance.borderWidth = 1
            appearance.cornerRadius = tagCornerRadius
            appearance.margin = 14
            appearance.font = .systemFont(ofSize: 17)
            appearance.textColor = .label
        }
        style.itemHeight = 36
        style.interitemSpacing = 12
        style.lineSpacing = 12
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 24, right: 16)
        style.headerHeight = 44
        style.headerFont = .systemFont(ofSize: 20, weight: .bold)
        style.headerTextColor = .label
        style.headerHorizontalInset = 16
        styleCustomizer?(style)
    }

    /**
     * Sets the defaults on `list`'s style (a copy, so the list's other values stay), and the refresh icon of its header
     * (`CYLSearchTagListHeader`).
     */
    @objc(applyDefaultStyleToList:)
    public static func applyDefaultStyle(to list: CYLTagListView) {
        let style = list.style.copy() as! CYLMenuStyle
        applyDefaults(to: style)
        list.style = style
        CYLSearchTagListHeader.applyRefreshIcon(to: list)
    }
}
