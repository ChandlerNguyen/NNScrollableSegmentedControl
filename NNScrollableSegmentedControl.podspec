Pod::Spec.new do |s|
  s.name             = 'NNScrollableSegmentedControl'
  s.version          = '1.0.2'
  s.summary          = 'A short description of NNScrollableSegmentedControl.'
  s.homepage         = 'https://github.com/ChandlerNguyen/NNScrollableSegmentedControl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Nang Nguyen'
  s.source           = { :git => 'https://github.com/ChandlerNguyen/NNScrollableSegmentedControl.git', :tag => s.version.to_s }
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'NNScrollableSegmentedControl/**/*'
  s.frameworks = 'Foundation','UIKit'
end
