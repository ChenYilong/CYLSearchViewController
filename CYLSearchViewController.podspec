Pod::Spec.new do |s|
  s.name = 'CYLSearchViewController'
  s.version = '0.1.0'
  s.summary = 'A configurable search bar and search view for iOS.'
  s.description = 'CYLSearchBar: a UIKit search bar (one field or several searches), a search page with suggestions, results from an injectable data source and pull-to-refresh, and its resources.'
  s.homepage = 'https://github.com/ChenYilong/CYLSearchViewController'
  s.license = { :type => 'Copyright', :text => 'Copyright (c) 2015 ChenYilong. All rights reserved.' }
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
  # The search bar items subclass CollectionViewClassifyMenu's CYLTagButton, a CYLAnimatedItemView: CYLTabBarController's
  # shared animated icon + title component, its core only (static images, no tab bar, no animation engine; guide:
  # https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md). An app
  # that plays animated icons adds the engine subspecs (CYLTabBarController/CYLAnimatedItemLottieSwift, ...PAG, ...Rive,
  # ...SVGA, ...GIF). The subspec is in no CocoaPods release yet: Podfiles pin CYLTabBarController by commit.
  s.dependency 'CYLTabBarController/CYLAnimatedItem'
  # The empty search results placeholder (CYLSearchView.emptyResultsScenario) is CYLTableViewPlaceHolder's
  # CYLPlaceholderStackView, and the refresh API of CYLSearchView (refreshHandler, +setRefreshHandler:forScrollView:)
  # wraps its pull-to-refresh (CYLRefreshNormalHeader). Also pinned by commit in the Podfile. No other search library:
  # CYLSearchBar is the only search kernel.
  # CYLTableViewPlaceHolder's placeholders prefer an animated icon (their bundled Lottie files) over the still image
  # (docs/core-todo.md). The core depends on no animation engine (docs/animated-icon-component.md): the placeholder's
  # core only, and the app adds the engine (the example adds CYLTableViewPlaceHolder/Lottie); the still image shows
  # otherwise.
  s.dependency 'CYLTableViewPlaceHolder/Core'
end
