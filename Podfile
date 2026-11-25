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
  pod 'CYLTableViewPlaceHolder', :subspecs => ['Core', 'Lottie'], :git => 'https://github.com/ChenYilong/CYLTableViewPlaceHolder.git', :commit => 'f4cf978567e43288b44f6ddc266510fa837a0e72'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the tag suggestion style of CYLSearchView. Pinned to its newest
  # commit on any branch (`git log --remotes -1`); never a local path in a commit.
  pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :commit => '0de4546b3413512b1794fc52d62fd10ba73ce106'
  # SVGA: the tab icon animations (docs/CYLTabBarController-Integration.md, SVGA TODO).
  pod 'CYLTabBarController', :subspecs => ['Core', 'SVGA', 'CYLFlatDesignTabBar'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '09bde3ca4a965e19be916f216df99b3d1a8c5d17'
  # CYLAnimatedItem, the shared animated icon + title component the search bar items subclass: its own pod in
  # CYLTabBarController's repository, not on the trunk yet. The core depends on its Core only; the example adds the
  # engines it plays (docs/animated-icon-component.md).
  pod 'CYLAnimatedItem', :subspecs => ['Core', 'SVGA', 'LottieSwift'], :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '09bde3ca4a965e19be916f216df99b3d1a8c5d17'
  # CYLTabBarController's badge needs CYLDeallocBlockExecutor 1.4, not on the trunk yet (as CollectionViewClassifyMenu's Podfile).
  pod 'CYLDeallocBlockExecutor', :git => 'https://github.com/ChenYilong/CYLDeallocBlockExecutor.git', :commit => '4276a6dab5a428ccc3a5f3f347eab991881fb97c'

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
