#
# The Flutter plugin of CYLSearchViewController: the native CYLSearchView and CYLSearchBarView as platform views. In
# this repository the example uses the local pod (example/ios/Podfile: pod 'CYLSearchViewController', :path), and
# pins the core's sub-repositories by commit.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_cylsearch'
  s.version          = '0.1.0'
  s.summary          = 'CYLSearchViewController (iOS) and its Android version as Flutter widgets'
  s.description      = 'The native search page and search bar of CYLSearchViewController as Flutter platform views.'
  s.homepage         = 'https://github.com/ChenYilong/CYLSearchViewController'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ChenYilong' => 'luohanchenyilong@163.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'flutter_cylsearch/Sources/flutter_cylsearch/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'CYLSearchViewController'
  s.dependency 'CollectionViewClassifyMenu'
  s.dependency 'CYLTableViewPlaceHolder/Core'
  s.platform = :ios, '15.0'
  s.static_framework = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
