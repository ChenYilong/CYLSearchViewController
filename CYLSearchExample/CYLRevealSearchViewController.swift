import UIKit
import CYLSearchViewController

/**
 * Port of android-cjj/MaterialSearchView's sample: on the primary color, a round search button opens a light search
 * card with a one-second circular reveal; the magnifier in the card closes it again.
 */
@objc(CYLRevealSearchViewController)
final class CYLRevealSearchViewController: UIViewController {

    private let searchBar = CYLSearchBarView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MaterialSearchView (cjj)"
        view.backgroundColor = .systemIndigo
        edgesForExtendedLayout = []

        // CardView: background #f2f2f2, corner radius 2; EditText: hint "search", text color #ffd46c, single line.
        searchBar.backgroundColor = .clear
        searchBar.fieldBackgroundColor = UIColor(white: 0xf2 / 255.0, alpha: 1)
        searchBar.fieldCornerRadius = 2
        searchBar.fieldHeight = 60
        searchBar.fieldShadowOpacity = 0.2
        searchBar.placeholder = "search"
        searchBar.textColor = UIColor(red: 1, green: 0xd4 / 255.0, blue: 0x6c / 255.0, alpha: 1)
        searchBar.searchIcon = nil
        // The magnifier inside the card closes it (mAnimator.reverse()).
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        close.tintColor = .secondaryLabel
        close.accessibilityLabel = cylDemoText("search.field")
        close.addAction(UIAction { [weak self] _ in self?.searchBar.setIconified(true, animated: true) }, for: .touchUpInside)
        searchBar.trailingAccessoryViews = [close]
        // The floating action button and the reveal (ViewAnimationUtils.createCircularReveal, 1000 ms).
        searchBar.expansionAnimation = .circularReveal
        searchBar.animationDuration = 1
        searchBar.iconButton.configuration = .filled()
        searchBar.iconButton.configuration?.cornerStyle = .capsule
        searchBar.iconButton.configuration?.baseBackgroundColor = .white
        searchBar.iconButton.configuration?.baseForegroundColor = .systemIndigo
        searchBar.iconButton.configuration?.image = UIImage(systemName: "magnifyingglass")
        searchBar.iconifiedByDefault = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            searchBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -4),
        ])
    }
}
