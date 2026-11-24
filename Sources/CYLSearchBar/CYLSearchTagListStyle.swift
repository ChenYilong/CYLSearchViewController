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
import CYLAnimatedItem
import UIKit

/**
 * The search bar core's default style of a tag list, the look of the iOS example's recent searches.
 */
@objc(CYLSearchTagListStyle)
public final class CYLSearchTagListStyle: NSObject {

    /**
     * The corner radius of every tag, in points. The default `CYLAnimatedItemCornerRadiusCapsule` (CYLAnimatedItem's one named constant, 1000; pass it, never the literal) is a capsule, as in the iOS example's
     * recent searches; 0 is square corners; another value is a rounded rectangle.
     */
    @objc public static var tagCornerRadius: CGFloat = CYLAnimatedItemCornerRadiusCapsule

    /**
     * The background of every tag, handed to CollectionViewClassifyMenu's `CYLMenuStyle.backgroundStyle`: `.flat` by
     * default (the tag's own colors), `.liquidGlass` for the glass material (flat below iOS 26).
     */
    @objc public static var tagBackgroundStyle: CYLTagBackgroundStyle = .flat

    /**
     * The one tint of every part of a tag list that is not a tag's background: the tags' text, the section header's
     * title, the clear (trash) button, the refresh / More icon and the fold chevron. `.label` by default, a dynamic color
     * (dark in light mode, light in dark mode), so no icon disappears on the glass in dark mode.
     */
    @objc public static var tagListTintColor: UIColor = .label

    /**
     * The clear (trash) icon, the SF Symbol "trash": a vector, sharp at every scale, drawn as a template in the tint.
     */
    @objc public static var clearImage: UIImage? {
        UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .regular))?
            .withRenderingMode(.alwaysTemplate)
    }

    /**
     * Gives the header texts and icons of `style` (title, clear button, refresh / More icon, fold chevron) the tint
     * `tagListTintColor` and the clear button the vector trash icon. A style of an example calls this once, so the
     * icons follow dark mode with the tags.
     */
    @objc(applyTintToStyle:)
    public static func applyTint(to style: CYLMenuStyle) {
        style.headerTextColor = tagListTintColor
        style.clearButtonColor = tagListTintColor
        style.clearButtonImage = clearImage
        style.moreButtonColor = tagListTintColor
        style.foldControlColor = tagListTintColor
    }

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
            // A Liquid Glass tag is a tint on the material, no border; a flat tag is white with a light border.
            if tagBackgroundStyle == .flat {
                appearance.backgroundColor = .systemBackground
                appearance.borderColor = .separator
                appearance.borderWidth = 1
            } else {
                // A clear fill draws the library's default frosted tint; the selected tag keeps its own tint.
                appearance.backgroundColor = state == .selected ? UIColor.tintColor.withAlphaComponent(0.3) : .clear
                appearance.borderWidth = 0
            }
            appearance.cornerRadius = tagCornerRadius
            appearance.margin = 14
            appearance.font = .systemFont(ofSize: 17)
            appearance.textColor = tagListTintColor
        }
        style.backgroundStyle = tagBackgroundStyle
        style.itemHeight = 36
        style.interitemSpacing = 12
        style.lineSpacing = 12
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 24, right: 16)
        style.headerHeight = 44
        style.headerFont = .systemFont(ofSize: 20, weight: .bold)
        applyTint(to: style)
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

    /**
     * Turns `list` into a grid of `columns` plain titles per row (CollectionViewClassifyMenu's `gridStyle(itemsPerRow:)`,
     * 17 pt medium text, 36 pt rows 16 pt apart, a tag's own image at its own size), the look of the iOS example's
     * discover topics, with the section header and the refresh icon as in `applyDefaultStyle(to:)`. Swift-only in
     * CollectionViewClassifyMenu, so the Objective-C++ bridge calls it here; 0 or less leaves the list as it is.
     */
    @objc(applyGridColumns:toList:)
    public static func applyGrid(columns: Int, to list: CYLTagListView) {
        guard columns > 0 else {
            return
        }
        let style = CYLMenuStyle.gridStyle(itemsPerRow: columns)
        for state in [UIControl.State.normal, .selected, .disabled] {
            style.appearance(for: state).font = .systemFont(ofSize: 17, weight: .medium)
        }
        style.imageSize = .zero
        style.itemHeight = 36
        style.lineSpacing = 16
        style.sectionInsets = UIEdgeInsets(top: 4, left: 16, bottom: 16, right: 16)
        style.backgroundColor = .clear
        style.headerHeight = 44
        style.headerFont = .systemFont(ofSize: 20, weight: .bold)
        applyTint(to: style)
        style.headerHorizontalInset = 16
        style.moreButtonImage = CYLSearchTagListHeader.refreshImage
        list.style = style
    }

    /**
     * Sets the background of every tag of `list` by name, the one parameter of a Liquid Glass list: "liquidGlass"
     * (case-insensitive) is the glass material (flat below iOS 26), anything else, "" or "flat" is flat. The list's
     * other style values stay. For the Objective-C++ and Dart bridges, which pass the name from JavaScript or Dart.
     */
    @objc(applyBackgroundStyleNamed:toList:)
    public static func applyBackgroundStyle(named name: String, to list: CYLTagListView) {
        let style = list.style.copy() as! CYLMenuStyle
        let glass = name.lowercased() == "liquidglass"
        style.backgroundStyle = glass ? .liquidGlass : .flat
        if glass {
            // A white fill under the glass hides it: clear the fill and border so the library's default frosted tint
            // draws; a selected tag keeps a visible tint.
            for state in [UIControl.State.normal, .selected, .disabled] {
                let appearance = style.appearance(for: state)
                appearance.backgroundColor = state == .selected ? UIColor.tintColor.withAlphaComponent(0.3) : .clear
                appearance.borderWidth = 0
            }
        }
        list.style = style
        CYLSearchTagListHeader.applyRefreshIcon(to: list)
    }
}
