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
  # The empty search results placeholder (CYLSearchView.emptyResultsScenario) is CYLTableViewPlaceHolder's
  # CYLPlaceholderStackView, and the refresh API of CYLSearchView (refreshHandler, +setRefreshHandler:forScrollView:)
  # wraps its pull-to-refresh (CYLRefreshNormalHeader). Also pinned by commit in the Podfile. No other search library:
  # CYLSearchBar is the only search kernel.
  # CYLTableViewPlaceHolder's placeholders prefer an animated icon (their bundled Lottie files) over the still image
  # (docs/core-todo.md): the Lottie engine is part of the core, the still image stays the fallback.
  s.dependency 'CYLTableViewPlaceHolder/Lottie'
end
