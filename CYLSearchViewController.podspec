Pod::Spec.new do |s|
  s.name = 'CYLSearchViewController'
  s.version = '0.1.0'
  s.summary = 'A configurable search bar and search view for iOS.'
  s.description = 'CYLSearchBar: a UIKit search bar (one field or several searches), a search page with suggestions, results from an injectable data source and pull-to-refresh, and its resources.'
  s.homepage = 'https://github.com/ChenYilong/CYLSearchViewController'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.source = { :git => 'https://github.com/ChenYilong/CYLSearchViewController.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.requires_arc = true
  s.frameworks = 'UIKit'
  # The suggestion cache's database store (CYLSearchSuggestionCachePolicyDatabase) uses the system SQLite.
  s.libraries = 'sqlite3'
  s.source_files = 'Sources/CYLSearchBar/**/*.swift'
  s.swift_version = '5.0'
  s.resources = 'Resources/CYLSearchViewController.bundle'
  # The tag suggestion style (CYLSearchSuggestionStyle.tags) shows suggestions in CollectionViewClassifyMenu's
  # CYLTagListView. Not on CocoaPods trunk: apps pin it by commit in their Podfile (AGENTS.md, "Sub-repositories").
  s.dependency 'CollectionViewClassifyMenu'
  # The search bar items subclass CollectionViewClassifyMenu's CYLTagButton, a CYLAnimatedItemView from the pod and module
  # CYLAnimatedItem (in CYLTabBarController's repository, with no dependency on CYLTabBarController; guide:
  # https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md). Its
  # Core shows static images and plays nothing; an app that plays animated icons adds the engine subspecs
  # (CYLAnimatedItem/LottieSwift, .../PAG, .../Rive, .../SVGA, .../GIF). The pod is not on the trunk yet: Podfiles name it
  # by :git and :commit.
  s.dependency 'CYLAnimatedItem'
  # The empty search results placeholder (CYLSearchView.emptyResultsScenario) is CYLTableViewPlaceHolder's
  # CYLPlaceholderStackView, and the refresh API of CYLSearchView (refreshHandler, +setRefreshHandler:forScrollView:)
  # wraps its pull-to-refresh (CYLRefreshNormalHeader). Also pinned by commit in the Podfile. No other search library:
  # CYLSearchBar is the only search kernel.
  # CYLTableViewPlaceHolder's placeholders prefer an animated icon (their bundled Lottie files) over the still image
  # (docs/core-todo.md). The core depends on no animation engine (docs/animated-icon-component.md): the placeholder's
  # core only, and the app adds the engine (the example adds CYLTableViewPlaceHolder/Lottie); the still image shows
  # otherwise.
  s.dependency 'CYLTableViewPlaceHolder/Core'
  # CYLSearchBarView.focusesOnAppear (focus the field every time the bar appears on screen) takes its moments from
  # CYLDeallocBlockExecutor's life cycle events (didEnterScreen of a UIView, and the app becoming active while on screen). The pod
  # is pinned by :git and :commit in the Podfile until 1.4 is on the trunk.
  s.dependency 'CYLDeallocBlockExecutor', '~> 1.4'
end
