//
//  CYLKenBurnsView.swift
//  CYLSearchExample
//
//  The Ken Burns background of the original demo (the Swift replacement of the Objective-C CYLKenBurnsView).
//

import UIKit

/**
 * An image that slowly zooms and drifts inside its bounds, forever: the "Ken Burns" effect behind the original demo's
 * search field. The animation restarts whenever the view is shown (Core Animation drops it when the app goes to the
 * background) and is off while Reduce Motion is on.
 */
final class CYLKenBurnsView: UIView {

    private let imageView = UIImageView()
    private let drift: CGPoint

    /**
     * The image, how long one zoom takes (`duration`, seconds) and where it drifts to (`drift`, as a share of the size).
     */
    init(image: UIImage?, duration: TimeInterval = 14, drift: CGPoint = CGPoint(x: -0.04, y: -0.03)) {
        self.drift = drift
        self.duration = duration
        super.init(frame: .zero)
        clipsToBounds = true
        isAccessibilityElement = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.isAccessibilityElement = false
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private let duration: TimeInterval

    override func layoutSubviews() {
        super.layoutSubviews()
        // The image view keeps the view's frame; its layer is what zooms (scaled up from the center).
        imageView.layer.removeAllAnimations()
        imageView.frame = bounds
        startAnimating()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startAnimating()
        } else {
            imageView.layer.removeAllAnimations()
        }
    }

    private func startAnimating() {
        imageView.layer.removeAllAnimations()
        guard window != nil, !UIAccessibility.isReduceMotionEnabled, bounds.width > 0 else { return }
        let end = CATransform3DConcat(
            CATransform3DMakeScale(1.25, 1.25, 1),
            CATransform3DMakeTranslation(bounds.width * drift.x, bounds.height * drift.y, 0))
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = CATransform3DIdentity
        animation.toValue = end
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageView.layer.add(animation, forKey: "CYLKenBurns")
    }
}
