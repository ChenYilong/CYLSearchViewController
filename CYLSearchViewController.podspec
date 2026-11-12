Pod::Spec.new do |s|
  s.name = 'CYLSearchViewController'
  s.version = '0.1.0'
  s.summary = 'A configurable search results controller for iOS.'
  s.description = 'A UIKit search results controller with an injectable data source and customizable cells.'
  s.homepage = 'https://github.com/ChenYilong/CYLSearchViewController'
  s.license = { :type => 'Copyright', :text => 'Copyright (c) 2015 ChenYilong. All rights reserved.' }
  s.author = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.source = { :git => 'https://github.com/ChenYilong/CYLSearchViewController.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.requires_arc = true
  s.frameworks = 'UIKit'
  s.source_files = 'Sources/CYLSearchViewController/**/*.swift'
  s.swift_version = '5.0'
  s.resources = 'Resources/CYLSearchViewController.bundle'
  # The tag suggestion style (CYLSearchSuggestionStyle.tags) shows suggestions in CollectionViewClassifyMenu's
  # CYLTagListView. Not on CocoaPods trunk: apps pin it by commit in their Podfile (AGENTS.md, "Sub-repositories").
  s.dependency 'CollectionViewClassifyMenu'
  # The empty search results placeholder (CYLSearchView.emptyResultsScenario) is CYLTableViewPlaceHolder's
  # CYLPlaceholderStackView. Also pinned by commit in the Podfile.
  s.dependency 'CYLTableViewPlaceHolder/Core'
end
