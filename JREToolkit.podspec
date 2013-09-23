Pod::Spec.new do |s|
  s.name         = "JREToolkit"
  s.version      = "0.0.1"
  s.summary      = "iOS Utilities by John Rommel Estropia"
  s.homepage     = "https://bitbucket.org/erurainon/jretoolkit/overview"
  s.license      = 'MIT'
  s.author       = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
  s.source       = { :git => "git@bitbucket.org:erurainon/jretoolkit.git",
                     :tag => "#{s.version}" }
  s.platform     = :ios, '7.0'
  s.source_files = '#{s.name}/**/*.{h,m}'
  s.frameworks = 'Foundation', 'UIKit'
  s.requires_arc = true
  s.dependency 'CocoaLumberjack', '~> 1.6.2'
  s.dependency 'AFNetworking', '~> 2.0.0-RC2'
end