// CYLTagButton's base class, CYLAnimatedItemView, is in the CYLAnimatedItem module: imported here so that the
// generated CYLSearchExample-Swift.h can declare this class, whose method returns a CYLTagButton (CI on bb261ce:
// "use of undeclared identifier 'CYLSVGADemoTagButton'" in CYLSearchDemoMenuViewController.m).
import CYLAnimatedItem
import CollectionViewClassifyMenu
import UIKit

/**
 * The animated icon and title of the SVGA demo above the Examples list: a `CYLTagButton` (CollectionViewClassifyMenu,
 * the one icon + title + animated icon component) whose `animationURL` is an `.svga` file, drawn by
 * CYLTabBarController's animation engine (the `CYLAnimatedItem/SVGA` engine subspec the example's Podfile
 * adds; the core adds none), so the example uses no SVGA player itself.
 */
@objc(CYLSVGADemoTagButton)
final class CYLSVGADemoTagButton: NSObject {

    private static let iconSide: CGFloat = 64
    private static let imageTitleSpacing: CGFloat = 12
    private static let titleFontSize: CGFloat = 13

    /**
     * A tag with the animated icon before the title, at the leading edge, without a border or background; each tap
     * plays the animation again (`playAnimation()`).
     */
    @objc(buttonWithTitle:animationURL:)
    static func button(title: String, animationURL: URL?) -> CYLTagButton {
        let button = CYLTagButton(title: title, image: nil, animationURL: animationURL)
        let style = CYLMenuStyle()
        style.imageSize = CGSize(width: iconSide, height: iconSide)
        style.animationSize = CGSize(width: iconSide, height: iconSide)
        style.imageTitleSpacing = imageTitleSpacing
        style.contentAlignment = .leading
        style.itemHeight = iconSide
        for state: UIControl.State in [.normal, .selected, .disabled] {
            let appearance = style.appearance(for: state)
            appearance.backgroundColor = .clear
            appearance.borderColor = nil
            appearance.borderWidth = 0
            appearance.contentInsets = .zero
            appearance.cornerRadius = 0  // square corners
            appearance.textColor = .secondaryLabel
            appearance.font = .systemFont(ofSize: titleFontSize)
        }
        button.style = style
        button.addAction(UIAction { [weak button] _ in
            button?.playAnimation()
        }, for: .touchUpInside)
        return button
    }
}
