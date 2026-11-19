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
  pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'Lottie'], :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :commit => 'b18b617b4769e30bbabad7640a2d6db26000ca2e'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the tag suggestion style of CYLSearchView. Pinned to its newest
  # commit on any branch (`git log --remotes -1`); never a local path in a commit.
  pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :commit => '272f569a65e71f3792fe140e9ec0078117c7b434'
  # SVGA: the tab icon animations (docs/CYLTabBarController-Integration.md, SVGA TODO).
  pod 'CYLTabBarController', :subspecs => ['Core', 'SVGA', 'CYLFlatDesignTabBar'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '9a4ad95e685de768d2977cdeb0ed1058557e5e88'
  # CYLAnimatedItem, the shared animated icon + title component the search bar items subclass: its own pod in
  # CYLTabBarController's repository, not on the trunk yet. The core depends on its Core only; the example adds the
  # engines it plays (docs/animated-icon-component.md).
  pod 'CYLAnimatedItem', :subspecs => ['Core', 'SVGA', 'LottieSwift'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '9a4ad95e685de768d2977cdeb0ed1058557e5e88'

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
