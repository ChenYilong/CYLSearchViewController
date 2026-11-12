import UIKit
import CYLSearchViewController

/**
 * Port of yechaoa/MaterialDesign's `SearchViewActivity`: an iconified search view in the toolbar with a submit
 * button, the Search return key, a hint and custom colors; a submitted query shows a snackbar and a search result,
 * and clearing the text hides the result again.
 */
@objc(CYLYechaoaSearchViewController)
final class CYLYechaoaSearchViewController: UIViewController {

    private let searchBar = CYLSearchBarView(frame: CGRect(x: 0, y: 0, width: 280, height: 44))
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SearchView"
        view.backgroundColor = .systemBackground
        edgesForExtendedLayout = []

        // setIconifiedByDefault(true), isSubmitButtonEnabled, imeOptions, isIconified, queryHint, text colors.
        searchBar.backgroundColor = .clear
        searchBar.contentInsets = .zero
        searchBar.iconifiedByDefault = true
        searchBar.showsSubmitButton = true
        searchBar.returnKeyType = .search
        searchBar.placeholder = cylDemoText("demo.port.keyword")
        searchBar.placeholderColor = UIColor(red: 0xdc / 255.0, green: 0xdc / 255.0, blue: 0xdc / 255.0, alpha: 1)
        searchBar.textColor = .label
        searchBar.delegate = self
        searchBar.setIconified(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)

        // The pretend search result, hidden until a query is submitted.
        resultLabel.text = cylDemoText("demo.port.result")
        resultLabel.font = .preferredFont(forTextStyle: .title2)
        resultLabel.adjustsFontForContentSizeCategory = true
        resultLabel.textAlignment = .center
        resultLabel.isHidden = true
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}

extension CYLYechaoaSearchViewController: CYLSearchBarViewDelegate {
    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        CYLSnackbar.show(String.localizedStringWithFormat(cylDemoText("demo.port.searched"), searchBarView.text ?? ""), in: view)
        resultLabel.isHidden = false
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        if text.isEmpty { resultLabel.isHidden = true }
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didChangeIconified iconified: Bool) {
        // The opened field takes the room of the title, like an expanded SearchView in the toolbar.
        let width = iconified ? 44 : max(200, view.bounds.width - 120)
        searchBarView.frame.size.width = width
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBarView)
    }
}
