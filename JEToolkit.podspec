Pod::Spec.new do |s|
  s.name                    = "JEToolkit"
  s.version                 = "0.0.2"
  s.summary                 = "iOS Utilities by John Rommel Estropia"
  s.homepage                = "https://github.com/JohnEstropia/JEToolkit"
  s.license                 = 'MIT'
  s.author                  = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
  s.source                  = { :git => "https://github.com/JohnEstropia/JEToolkit.git",
                                :tag => "#{s.version}" }
  s.platform                = :ios, '7.0'
  s.source_files            = "#{s.name}/**/*.{h,m,c}"
  s.ios.deployment_target   = '7.0'
  s.ios.frameworks          = 'Foundation', 'MobileCoreServices', 'UIKit'
  s.requires_arc            = true
end