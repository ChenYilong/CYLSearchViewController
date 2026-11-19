//
//  CYLSearchExampleSceneDelegate.swift
//  CYLSearchExample
//
//  Creates the example's window in its scene (translated from Objective-C, docs/swift-migration.md).
//

import UIKit

/**
 * Creates the example's window in its scene, with `CYLSearchExampleAppDelegate.rootViewController()` as the root. Apps
 * built with the iOS 27 SDK must adopt the scene life cycle; without it the app does not launch. The Objective-C name is
 * the one Info.plist's `UISceneDelegateClassName` uses.
 */
@objc(CYLSearchExampleSceneDelegate)
final class CYLSearchExampleSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = CYLSearchExampleAppDelegate.rootViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
