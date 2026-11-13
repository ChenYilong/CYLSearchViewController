import UIKit
import Speech
import CollectionViewClassifyMenu
import CYLSearchViewController

/**
 * Port of MiguelCatalan/MaterialSearchView's sample `MainActivity`: one button per sample screen.
 */
@objc(CYLMaterialSearchMenuViewController)
final class CYLMaterialSearchMenuViewController: UITableViewController {

    /**
     * The suggestion style of every sample opened from this menu (the "Tag style" tab uses `.tags`).
     */
    var suggestionStyle: CYLSearchSuggestionStyle = .list

    /**
     * Passed to every sample's `CYLSearchView.focusesSearchFieldOnShow` (the "Tag style" tab opens with the keyboard
     * down, showing the cached queries or the empty placeholder).
     */
    var focusesSearchFieldOnShow = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MaterialSearchView"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CYLMaterialSearchSample.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = CYLMaterialSearchSample.allCases[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        // A row opens a sample: VoiceOver and UI tests see it as a button.
        cell.accessibilityTraits.insert(.button)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sample = CYLMaterialSearchSample.allCases[indexPath.row]
        navigationController?.pushViewController(CYLMaterialSearchSampleViewController(sample: sample, suggestionStyle: suggestionStyle,
                                                                                         focusesSearchFieldOnShow: focusesSearchFieldOnShow), animated: true)
    }
}

/**
 * The sample screens: `DefaultActivity`, `ColoredActivity`, `VoiceActivity`, `StickyActivity`, `TabActivity` and
 * `InputTypeActivity`.
 */
enum CYLMaterialSearchSample: CaseIterable {
    case standard, themed, voice, sticky, tabs, inputType

    /**
     * The title of the sample's button.
     */
    var title: String {
        switch self {
        case .standard: return cylDemoText("demo.port.default")
        case .themed: return cylDemoText("demo.port.themed")
        case .voice: return cylDemoText("demo.port.voice")
        case .sticky: return cylDemoText("demo.port.sticky")
        case .tabs: return cylDemoText("demo.port.tab")
        case .inputType: return cylDemoText("demo.port.inputType")
        }
    }
}

/**
 * One sample screen: a toolbar with a search item that opens a `CYLSearchView` with the sample's suggestions; a
 * submitted query shows "Query: …" in a snackbar and closes the search, as `onQueryTextSubmit` returning false does.
 */
@objc(CYLMaterialSearchSampleViewController)
final class CYLMaterialSearchSampleViewController: UIViewController {

    /**
     * `R.array.query_suggestions` of the sample.
     */
    static let suggestions = [
        "A very very long suggestion that would span multiple lines.", "Android", "iOS", "SCALA", "Ruby",
        "JavaScript", "C#", "Python", "C", "C++", "PHP", "Go", "Perl", "Bash", "Lua", "R", "TCL", "Haskell",
        "Objective C", "Swift", "Kotlin", "jQuery", "Development", "Web", "Ajax", "Test", "Testing", "CookBook",
        "Beagle", "VMware", "Less.js", "IDE", "Arduino", "Xamarin", "UI", "Microsoft", "Application", "Development",
        "JUnit", "SQL", "Beagle",
    ]

    private let sample: CYLMaterialSearchSample
    private let suggestionStyle: CYLSearchSuggestionStyle
    private let focusesSearchFieldOnShow: Bool
    private let searchView = CYLSearchView(frame: .zero)
    private let speech = CYLSpeechRecognizer()

    init(sample: CYLMaterialSearchSample, suggestionStyle: CYLSearchSuggestionStyle = .list, focusesSearchFieldOnShow: Bool = true) {
        self.sample = sample
        self.suggestionStyle = suggestionStyle
        self.focusesSearchFieldOnShow = focusesSearchFieldOnShow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        sample = .standard
        suggestionStyle = .list
        focusesSearchFieldOnShow = true
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = sample.title
        view.backgroundColor = .systemBackground
        edgesForExtendedLayout = []
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearch))
        searchItem.accessibilityLabel = cylDemoText("demo.port.open")
        navigationItem.rightBarButtonItem = searchItem
        addContent()

        // searchView.setVoiceSearch, setCursorDrawable, setEllipsize, setSuggestions and the two listeners.
        searchView.searchBarView.showsVoiceButton = sample == .voice
        searchView.searchBarView.cursorColor = sample == .themed || sample == .voice ? .white : .systemPink
        searchView.suggestionLineBreakMode = sample == .standard || sample == .inputType ? .byTruncatingTail : .byWordWrapping
        searchView.suggestions = sample == .sticky ? [] : Self.suggestions
        searchView.suggestionStyle = suggestionStyle
        // The tags end with the fold chevron, two rows while folded, as on the Discover page.
        searchView.suggestionsFoldControl = CYLMenuFoldControl(position: .inline, content: .icon)
        searchView.suggestionsFoldedRowCount = 2
        // A query that matches nothing shows CYLTableViewPlaceHolder's "no search results" state (docs/sub-repositories.md).
        searchView.showsEmptyResultsPlaceholder = true
        // Submitted queries are cached in the core's local database (docs/core-todo.md), one cache for these samples;
        // an empty query lists them under a header with a delete-all button.
        searchView.suggestionCachePolicy = .database
        searchView.suggestionCacheName = "MaterialSearchView"
        searchView.focusesSearchFieldOnShow = focusesSearchFieldOnShow
        searchView.searchBarView.isSecureTextEntry = sample == .inputType
        if sample == .themed || sample == .voice {
            // The colored theme: white text on the primary color.
            searchView.backgroundColor = .systemIndigo
            searchView.searchBarView.textColor = .white
            searchView.searchBarView.placeholderColor = UIColor(white: 1, alpha: 0.7)
            searchView.searchBarView.searchIconTintColor = .white
            searchView.searchBarView.navigationButton.tintColor = .white
            searchView.suggestionTextColor = .white
            searchView.suggestionImageTintColor = UIColor(white: 1, alpha: 0.8)
            searchView.dividerColor = UIColor(white: 1, alpha: 0.3)
        }
        searchView.delegate = self
        searchView.install(in: view)
    }

    private func addContent() {
        let label = UILabel()
        label.text = sample.title
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        switch sample {
        case .sticky:
            // StickyActivity: a long list scrolls under the sticky toolbar.
            let list = UITextView()
            list.isEditable = false
            list.font = .preferredFont(forTextStyle: .body)
            list.adjustsFontForContentSizeCategory = true
            list.text = (1...60).map { String.localizedStringWithFormat(cylDemoText("demo.port.item"), $0) }.joined(separator: "\n\n")
            pin(list)
        case .tabs:
            // TabActivity: three pages under tabs.
            let tabs = UISegmentedControl(items: (1...3).map { String.localizedStringWithFormat(cylDemoText("demo.port.page"), $0) })
            tabs.selectedSegmentIndex = 0
            tabs.addAction(UIAction { [weak label, weak tabs] _ in
                label?.text = tabs?.titleForSegment(at: tabs?.selectedSegmentIndex ?? 0)
            }, for: .valueChanged)
            label.text = tabs.titleForSegment(at: 0)
            let stack = UIStackView(arrangedSubviews: [tabs, label])
            stack.axis = .vertical
            stack.spacing = 24
            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            let container = UIView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: container.topAnchor),
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
            pin(container)
        default:
            pin(label)
        }
    }

    private func pin(_ content: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: guide.topAnchor),
            content.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }
}

extension CYLMaterialSearchSampleViewController {

    /**
     * The search item: the whole search bar takes the navigation bar's place (as MaterialSearchView opens over the
     * toolbar). The navigation bar hides first, so the search view, which fills this view, puts its bar at the top of
     * the safe area, where the navigation bar was; nothing is covered.
     */
    @objc func openSearch() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchView.showSearch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchView.searchOpen {
            searchView.closeSearch(animated: false)
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension CYLMaterialSearchSampleViewController: CYLSearchViewDelegate {
    /**
     * The navigation bar comes back when the search closes.
     */
    func searchViewDidClose(_ searchView: CYLSearchView) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
        CYLSnackbar.show(String.localizedStringWithFormat(cylDemoText("demo.port.query"), text), in: view)
        return false
    }

    func searchViewVoiceButtonClicked(_ searchView: CYLSearchView) {
        // REQUEST_VOICE + onActivityResult: the first result becomes the query, without submitting it.
        searchView.searchBarView.placeholder = cylDemoText("demo.port.listening")
        speech.recognize { [weak self, weak searchView] text in
            searchView?.searchBarView.placeholder = nil
            guard let self, let searchView else { return }
            if let text, !text.isEmpty {
                searchView.setQuery(text, submit: false)
            } else {
                CYLSnackbar.show(cylDemoText("demo.port.voiceUnavailable"), in: self.view)
            }
        }
    }
}

/**
 * Turns one spoken phrase into text with the Speech framework (the sample's `RecognizerIntent`).
 */
final class CYLSpeechRecognizer {
    private let engine = AVAudioEngine()
    private var task: SFSpeechRecognitionTask?

    /**
     * Listens for up to five seconds and calls `completion` on the main queue with the text, or nil when speech
     * recognition is not available or not allowed.
     */
    func recognize(completion: @escaping (String?) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized, let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
                    completion(nil)
                    return
                }
                self.start(with: recognizer, completion: completion)
            }
        }
    }

    private func start(with recognizer: SFSpeechRecognizer, completion: @escaping (String?) -> Void) {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.channelCount > 0 else {
            completion(nil)
            return
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in request.append(buffer) }
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            engine.prepare()
            try engine.start()
        } catch {
            input.removeTap(onBus: 0)
            completion(nil)
            return
        }
        var finished = false
        let finish: (String?) -> Void = { [weak self] text in
            DispatchQueue.main.async {
                guard !finished else { return }
                finished = true
                self?.engine.stop()
                self?.engine.inputNode.removeTap(onBus: 0)
                self?.task?.cancel()
                completion(text)
            }
        }
        task = recognizer.recognitionTask(with: request) { result, error in
            if let result, result.isFinal { finish(result.bestTranscription.formattedString) }
            if error != nil { finish(nil) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { request.endAudio() }
    }
}
