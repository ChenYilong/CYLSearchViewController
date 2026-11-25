/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchBarAppearance.swift
//  CYLSearchViewController
//
//  The style values QMUI's qmui_styledAsQMUISearchBar took from its configuration table (SearchBarFont,
//  SearchBarTextColor, ...), merged with the defaults of the legacy Objective-C CYLSearchBar.
//

import UIKit

/**
 * The style of a `CYLSearchBar`: the values QMUI reads from its configuration template for `qmui_styledAsQMUISearchBar`
 * (`SearchBarFont`, `SearchBarTextColor`, `SearchBarPlaceholderColor`, `SearchBarTintColor`, the icons, the field
 * background and border, `SearchBarTextFieldCornerRadius`, `SearchBarBackgroundImage`), merged with the defaults of the
 * legacy Objective-C `CYLSearchBar` (field RGB 187, 186, 193, tint RGB 0, 104, 248, no bar background, localized
 * placeholder and Cancel). `CYLSearchBarAppearance.defaultAppearance` is the app-wide default; every bar copies it when
 * it
 * is created.
 */
@objc(CYLSearchBarAppearance)
public final class CYLSearchBarAppearance: NSObject, NSCopying {

    // MARK: - Text

    /**
     * The font of the text and of the placeholder (QMUI `SearchBarFont`); `nil` keeps UIKit's.
     */
    @objc public var font: UIFont?

    /**
     * The color of the typed text (QMUI `SearchBarTextColor`); `nil` keeps UIKit's.
     */
    @objc public var textColor: UIColor?

    /**
     * The color of the placeholder (QMUI `SearchBarPlaceholderColor`, default `UIColor.secondaryLabel`).
     */
    @objc public var placeholderColor: UIColor?

    /**
     * The placeholder (legacy CYLSearchBar: "搜索"), by default the core's localized "Search".
     */
    @objc public var placeholder: String?

    /**
     * The title of the Cancel button (legacy CYLSearchBar: "取消"), by default the core's localized "Cancel". It is the
     * button's accessibility label, and its title where the system draws one (iOS 26 and later draw an xmark).
     */
    @objc public var cancelTitle: String?

    /**
     * The tint of the bar and the controls on it (QMUI `SearchBarTintColor`; legacy CYLSearchBar: RGB 0, 104, 248).
     */
    @objc public var tintColor: UIColor?

    // MARK: - Icons

    /**
     * The magnifier icon (QMUI `SearchBarSearchIconImage`, best 14 x 14); `nil` keeps UIKit's.
     */
    @objc public var searchIconImage: UIImage?

    /**
     * The clear button icon (QMUI `SearchBarClearIconImage`); `nil` keeps UIKit's.
     */
    @objc public var clearIconImage: UIImage?

    // MARK: - Field

    /**
     * The color of the text field (legacy CYLSearchBar: RGB 187, 186, 193 in light mode). It is drawn as the field's
     * background image (`CYLSearchBar.textFieldBackgroundImage(color:)`), which also decides the field height.
     */
    @objc public var textFieldBackgroundColor: UIColor?

    /**
     * The background image of the text field (QMUI `SearchBarTextFieldBackgroundImage`); wins over
     * `textFieldBackgroundColor`.
     */
    @objc public var textFieldBackgroundImage: UIImage?

    /**
     * The border color of the text field (QMUI `SearchBarTextFieldBorderColor`), one pixel wide; `nil` is no border.
     */
    @objc public var textFieldBorderColor: UIColor?

    /**
     * The corner radius of the text field (QMUI `SearchBarTextFieldCornerRadius`): 0 keeps UIKit's, a negative value is
     * half of the field's height. The default is -1, the pill of the legacy CYLSearchBar.
     */
    @objc public var textFieldCornerRadius: CGFloat = -1

    // MARK: - Bar background

    /**
     * The background image of the whole bar (QMUI `SearchBarBackgroundImage`); wins over the color and the border.
     */
    @objc public var barBackgroundImage: UIImage?

    /**
     * The background color of the bar; `barBackgroundImage` is generated from it (a background image rather than
     * `barTintColor`, so that the bottom border's color can change as well).
     */
    @objc public var barBackgroundColor: UIColor?

    /**
     * The color of the bar's bottom border, one pixel wide.
     */
    @objc public var barBorderColor: UIColor?

    /**
     * Whether a bar without any background image, color or border draws no background at all (the legacy CYLSearchBar
     * deleted the system's `UISearchBarBackground`). Default `true`.
     */
    @objc public var hidesBarBackground = true

    // MARK: - Default

    /**
     * The app-wide default style, merged from QMUI's template and the legacy CYLSearchBar. A change affects bars
     * created
     * afterwards.
     */
    @objc(defaultAppearance)
    public static let `default` = CYLSearchBarAppearance()

    /**
     * A style with the merged defaults.
     */
    @objc public override init() {
        super.init()
        placeholderColor = .secondaryLabel
        placeholder = CYLSearchResources.localizedString(forKey: "search.field")
        cancelTitle = CYLSearchResources.localizedString(forKey: "search.cancel")
        tintColor = UIColor(red: 0 / 255, green: 104 / 255, blue: 248 / 255, alpha: 1)
        textFieldBackgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 58 / 255, green: 58 / 255, blue: 60 / 255, alpha: 1)
                : UIColor(red: 187 / 255, green: 186 / 255, blue: 193 / 255, alpha: 1)
        }
    }

    static func defaultCopy() -> CYLSearchBarAppearance {
        CYLSearchBarAppearance.default.copy() as? CYLSearchBarAppearance ?? CYLSearchBarAppearance()
    }

    // MARK: - Shared by CYLSearchBar and CYLSearchBarView
    //
    // The one place that turns the appearance into values and measures what both bars need; each bar only assigns the
    // results to its own subviews (UISearchBar's field, or the view's fieldView).

    /**
     * What the field draws, resolved for `traits` (docs/qmui-search-controller.md, "Merge design"): the colors are
     * resolved, `cornerRadius` is nil when the style keeps the bar's own corners (0), negative for a capsule.
     */
    struct ResolvedField {
        var fillColor: UIColor?
        var backgroundImage: UIImage?
        var borderColor: UIColor?
        var borderWidth: CGFloat
        var cornerRadius: CGFloat?
    }

    func resolvedField(traits: UITraitCollection) -> ResolvedField {
        ResolvedField(
            fillColor: textFieldBackgroundColor?.resolvedColor(with: traits),
            backgroundImage: textFieldBackgroundImage,
            borderColor: textFieldBorderColor?.resolvedColor(with: traits),
            borderWidth: textFieldBorderColor == nil ? 0 : Self.hairline,
            cornerRadius: textFieldCornerRadius == 0 ? nil : textFieldCornerRadius)
    }

    /**
     * One pixel in points, the width of the borders.
     */
    static var hairline: CGFloat {
        1 / max(UIGraphicsImageRendererFormat.preferred().scale, 1)
    }

    /**
     * The radius to draw: a negative value is half of `height` (a capsule).
     */
    static func cornerRadius(_ radius: CGFloat, height: CGFloat) -> CGFloat {
        radius < 0 ? height / 2 : radius
    }

    /**
     * The margins of a bar in a state: the provider's answer wins over the resting value.
     */
    static func margins<Bar>(of provider: ((Bar, Bool) -> UIEdgeInsets)?, bar: Bar, active: Bool,
                             resting: UIEdgeInsets) -> UIEdgeInsets {
        provider?(bar, active) ?? resting
    }

    /**
     * The width of `text` in `font`, rounded up.
     */
    static func textWidth(_ text: String, font: UIFont) -> CGFloat {
        ceil((text as NSString).size(withAttributes: [.font: font]).width)
    }

    /**
     * How far to move a block of `contentWidth` (the magnifier, its gap and the placeholder), whose left edge rests
     * at `baseline`, to center it in a field of `fieldWidth`; never negative, never more than `room` (the free
     * space right of the block, so accessories and Cancel keep theirs).
     */
    static func centeringOffset(fieldWidth: CGFloat, contentWidth: CGFloat, baseline: CGFloat,
                                room: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        min(max(0, (fieldWidth - contentWidth) / 2 - baseline), max(0, room))
    }

    private static var cachedFieldHeight: CGFloat = 0

    /**
     * UIKit's default field height, measured once from a plain `UISearchBar` (36 before iOS 26, 44 after).
     */
    static func defaultTextFieldHeight() -> CGFloat {
        if cachedFieldHeight == 0 {
            let probe = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 56))
            probe.layoutIfNeeded()
            let height = probe.searchTextField.frame.height
            cachedFieldHeight = height > 0 ? height : 36
        }
        return cachedFieldHeight
    }

    /**
     * A resizable image of a text field in `color`; its height decides the height of a `UISearchBar` field.
     */
    static func textFieldBackgroundImage(color: UIColor?) -> UIImage? {
        guard let color else { return nil }
        let size = CGSize(width: 60, height: defaultTextFieldHeight())
        let image = UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

    /**
     * A resizable image for a bar's background: `color` (white by default) with a one pixel bottom border in
     * `borderColor`, or nil when both are nil.
     */
    static func backgroundImage(color: UIColor?, borderColor: UIColor?) -> UIImage? {
        guard color != nil || borderColor != nil else { return nil }
        let size = CGSize(width: 10, height: 10)
        let format = UIGraphicsImageRendererFormat.preferred()
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            (color ?? .white).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            if let borderColor {
                let line = 1 / max(format.scale, 1)
                borderColor.setFill()
                context.fill(CGRect(x: 0, y: size.height - line, width: size.width, height: line))
            }
        }
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
    }

    /**
     * Returns an independent copy of this style.
     */
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CYLSearchBarAppearance()
        copy.font = font
        copy.textColor = textColor
        copy.placeholderColor = placeholderColor
        copy.placeholder = placeholder
        copy.cancelTitle = cancelTitle
        copy.tintColor = tintColor
        copy.searchIconImage = searchIconImage
        copy.clearIconImage = clearIconImage
        copy.textFieldBackgroundColor = textFieldBackgroundColor
        copy.textFieldBackgroundImage = textFieldBackgroundImage
        copy.textFieldBorderColor = textFieldBorderColor
        copy.textFieldCornerRadius = textFieldCornerRadius
        copy.barBackgroundImage = barBackgroundImage
        copy.barBackgroundColor = barBackgroundColor
        copy.barBorderColor = barBorderColor
        copy.hidesBarBackground = hidesBarBackground
        return copy
    }
}
