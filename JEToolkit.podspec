Pod::Spec.new do |s|
  s.name                    = "JEToolkit"
  s.version                 = "3.0.4"
  s.summary                 = "iOS Utilities"
  s.homepage                = "https://github.com/JohnEstropia/JEToolkit"
  s.license                 = 'MIT'
  s.author                  = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
  s.source                  = { :git => "https://github.com/JohnEstropia/JEToolkit.git",
                                :tag => "#{s.version}",
                                :submodules => true }
  s.platform                = :ios, '8.0'
  s.public_header_files     = "#{s.name}/*.h"
  s.source_files            = "#{s.name}/JEToolkit.h"
  s.ios.deployment_target   = '8.0'
  s.ios.frameworks          = 'Foundation', 'MobileCoreServices', 'UIKit'
  s.requires_arc            = true

  s.subspec "JEToolkit" do |ss|
    ss.source_files         = "#{s.name}/JEToolkit/**/*.{h,m,c,swift}"
    ss.ios.frameworks       = 'Foundation', 'MobileCoreServices', 'UIKit'
  end

  s.subspec "JEDebugging" do |ss|
    ss.source_files         = "#{s.name}/JEDebugging/**/*.{h,m,c,swift}"
    ss.ios.frameworks       = 'Foundation', 'UIKit', 'MessageUI'
    ss.dependency "#{s.name}/JEToolkit"
    end

  s.subspec "JESettings" do |ss|
    ss.source_files         = "#{s.name}/JESettings/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
  end
  
  s.subspec "JEOrderedDictionary" do |ss|
    ss.source_files         = "#{s.name}/JEOrderedDictionary/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
  end
  
  s.subspec "JEWeakCache" do |ss|
    ss.source_files         = "#{s.name}/JEWeakCache/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
  end

end
