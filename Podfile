platform :ios, '15.0'

ENV['SWIFT_VERSION'] = '5'

project 'CYLSearchExample.xcodeproj'
workspace 'CYLSearchExample.xcworkspace'

target 'CYLSearchExample' do
  # Static frameworks: CollectionViewClassifyMenu is a static framework (its podspec), and a dynamic framework (this
  # pod) cannot depend on a static one.
  use_frameworks! :linkage => :static
  pod 'CYLSearchViewController', :path => '.'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the empty search results placeholder of CYLSearchView and the
  # example's empty states. Pinned to its newest commit on any branch; never a local path in a commit.
  pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'Lottie'], :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :commit => '62e40c0530f74e8fe8a8e6d8b98cf42d5ac7ada1'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the tag suggestion style of CYLSearchView. Pinned to its newest
  # commit on any branch (`git log --remotes -1`); never a local path in a commit.
  pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :commit => '3b90b29502d8096f51be9c80d9388be16a744759'
  # SVGA: the tab icon animations (docs/CYLTabBarController-Integration.md, SVGA TODO).
  pod 'CYLTabBarController', :subspecs => ['Core', 'SVGA', 'CYLFlatDesignTabBar'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '6a9ede85ece5671b0391bb6ccad8a24d1d1b500d'
  # CYLAnimatedItem, the shared animated icon + title component the search bar items subclass: its own pod in
  # CYLTabBarController's repository, not on the trunk yet. The core depends on its Core only; the example adds the
  # engines it plays (docs/animated-icon-component.md).
  pod 'CYLAnimatedItem', :subspecs => ['Core', 'SVGA', 'LottieSwift'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '6a9ede85ece5671b0391bb6ccad8a24d1d1b500d'

  target 'CYLSearchExampleTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end
