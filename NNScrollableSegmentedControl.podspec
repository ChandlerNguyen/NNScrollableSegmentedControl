Pod::Spec.new do |s|
  s.name             = 'NNScrollableSegmentedControl'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NNScrollableSegmentedControl.'
  s.homepage         = 'https://github.com/ChandlerNguyen/NNScrollableSegmentedControl'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nang Nguyen'}
  s.source           = { :git => 'https://github.com/ChandlerNguyen/NNScrollableSegmentedControl.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'NNScrollableSegmentedControl/Classes/**/*'
end
