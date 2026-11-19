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
  pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'Lottie'], :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :commit => 'f1a9052f2cd9a4673b79b73882348b306fb2fe41'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the tag suggestion style of CYLSearchView. Pinned to its newest
  # commit on any branch (`git log --remotes -1`); never a local path in a commit.
  pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :commit => '2ec3d90ebb4b51157cab4289916b3d2ba443f9c4'
  # SVGA: the tab icon animations (docs/CYLTabBarController-Integration.md, SVGA TODO).
  pod 'CYLTabBarController', :subspecs => ['Core', 'SVGA', 'CYLFlatDesignTabBar'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '74f0b4cd8c8e55b8954650b063e2955b9f4e92ef'
  # CYLAnimatedItem, the shared animated icon + title component the search bar items subclass: its own pod in
  # CYLTabBarController's repository, not on the trunk yet. The core depends on its Core only; the example adds the
  # engines it plays (docs/animated-icon-component.md).
  pod 'CYLAnimatedItem', :subspecs => ['Core', 'SVGA', 'LottieSwift'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '74f0b4cd8c8e55b8954650b063e2955b9f4e92ef'

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
