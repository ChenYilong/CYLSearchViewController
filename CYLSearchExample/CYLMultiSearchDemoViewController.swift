import UIKit
import CYLSearchViewController

/**
 * Port of iammert/MultiSearchView's sample `MainActivity`: a `CYLSearchBarView` in `CYLSearchBarModeMultiple`, styled
 * like the README's
 * `SearchTextStyle` (hint "Search", 18 pt text, at most 15 characters, sentence capitalization, the Search key,
 * gray hint, black text), 16 pt from the top, with every event logged (the sample's `Log.v`).
 */
@objc(CYLMultiSearchDemoViewController)
final class CYLMultiSearchDemoViewController: UIViewController {

    private let multiSearchView = CYLSearchBarView(frame: .zero)
    private let logView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MultiSearchView"
        view.backgroundColor = .systemBackground
        edgesForExtendedLayout = []

        multiSearchView.mode = .multiple
        multiSearchView.contentInsets = .zero
        multiSearchView.placeholder = cylDemoText("search.field")
        multiSearchView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 18))
        multiSearchView.maximumTextLength = 15
        multiSearchView.autocapitalizationType = .sentences
        multiSearchView.returnKeyType = .search
        multiSearchView.placeholderColor = UIColor(white: 0x99 / 255.0, alpha: 0x80 / 255.0)
        multiSearchView.textColor = .label
        multiSearchView.delegate = self
        multiSearchView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(multiSearchView)

        logView.isEditable = false
        logView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        logView.adjustsFontForContentSizeCategory = true
        logView.accessibilityLabel = cylDemoText("demo.port.events")
        logView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logView)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            multiSearchView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            multiSearchView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8),
            multiSearchView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8),
            logView.topAnchor.constraint(equalTo: multiSearchView.bottomAnchor, constant: 16),
            logView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            logView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            logView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }

    private func log(_ line: String) {
        logView.text = line + "\n" + logView.text
    }
}

extension CYLMultiSearchDemoViewController: CYLSearchBarViewDelegate {
    func searchBarView(_ searchBarView: CYLSearchBarView, didSelectSearch text: String, at index: Int) {
        log("onItemSelected: index: \(index), query: \(text)")
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String, at index: Int) {
        log("changed: index: \(index), query: \(text)")
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didCompleteSearch text: String, at index: Int) {
        log("complete: index: \(index), query: \(text)")
    }

    func searchBarView(_ searchBarView: CYLSearchBarView, didRemoveSearchAt index: Int) {
        log("remove: index: \(index)")
    }
}
