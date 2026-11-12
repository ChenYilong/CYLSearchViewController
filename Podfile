platform :ios, '15.0'

ENV['SWIFT_VERSION'] = '5'

project 'CYLSearchExample.xcodeproj'
workspace 'CYLSearchExample.xcworkspace'

target 'CYLSearchExample' do
  # Static frameworks: CollectionViewClassifyMenu is a static framework (its podspec), and a dynamic framework (this
  # pod) cannot depend on a static one.
  use_frameworks! :linkage => :static
  pod 'CYLSearchViewController', :path => '.'
  pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'
  # Sub-repository (AGENTS.md, "Sub-repositories"): the tag suggestion style of CYLSearchView. Pinned to its newest
  # commit on any branch (`git log --remotes -1`); never a local path in a commit.
  pod 'CollectionViewClassifyMenu', :git => 'https://github.com/ChenYilong/CollectionViewClassifyMenu.git', :commit => 'e550a0181ea1bc98cf473e777cb1015c2bc564a6'
  pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => 'd36c7080157c49c552a3a352d72a9d00a2be11a9'

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
