import SwiftUI
import UIKit
import CYLTabBarController

/// The SwiftUI host of the SVGA tab bar (docs/CYLTabBarController-Integration.md, SVGA TODO, the SwiftUI row), as
/// CYLTabBarController's Example-SwiftUI-Rive hosts its tab bar: a `CYLTabBarController` made from
/// `CYLTabBarConfiguration_svga_swiftui.json` (SVGA icons, `CYLTabBarSVGAFilePath`) inside a SwiftUI view through
/// `UIViewControllerRepresentable`; the pages come from the same page registry as the UIKit tab bar.
struct CYLSVGATabBarRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        (try? CYLTabBarController(configurationFile: "CYLTabBarConfiguration_svga_swiftui.json")) ?? UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

/// A SwiftUI screen: a localized title bar with a close button above the hosted tab bar.
struct CYLSVGASwiftUIDemoView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(CYLSVGASwiftUIDemo.text("svga.swiftui.title"))
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button(CYLSVGASwiftUIDemo.text("svga.swiftui.close"), action: dismiss)
                    .accessibilityIdentifier("CYLSVGASwiftUIClose")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            CYLSVGATabBarRepresentable()
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

@objc(CYLSVGASwiftUIDemo)
final class CYLSVGASwiftUIDemo: NSObject {
    /// A text of the example's own strings (CYLSearchTabs.bundle).
    static func text(_ key: String) -> String {
        let bundle = Bundle.main.path(forResource: "CYLSearchTabs", ofType: "bundle").flatMap(Bundle.init(path:)) ?? .main
        return bundle.localizedString(forKey: key, value: key, table: "CYLSearchTabs")
    }

    /// The SwiftUI screen in a hosting controller, full screen.
    @objc static func viewController() -> UIViewController {
        var host: UIViewController?
        let view = CYLSVGASwiftUIDemoView { host?.dismiss(animated: true) }
        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .fullScreen
        host = controller
        return controller
    }
}
