Pod::Spec.new do |s|
  s.name                    = "JEToolkit"
  s.version                 = "0.1.1"
  s.summary                 = "iOS Utilities"
  s.homepage                = "https://github.com/JohnEstropia/JEToolkit"
  s.license                 = 'MIT'
  s.author                  = { "John Rommel Estropia" => "rommel.estropia@gmail.com" }
  s.source                  = { :git => "https://github.com/JohnEstropia/JEToolkit.git",
                                :tag => "#{s.version}",
                                :submodules => true }
  s.platform                = :ios, '6.0'
  s.public_header_files     = "#{s.name}/*.h"
  s.source_files            = "#{s.name}/JEToolkit.h"
  s.ios.deployment_target   = '6.0'
  s.ios.frameworks          = 'Foundation', 'MobileCoreServices', 'UIKit'
  s.requires_arc            = true

  s.subspec "JEToolkit" do |ss|
    ss.source_files         = "#{s.name}/JEToolkit/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation', 'MobileCoreServices', 'UIKit'
  end

  s.subspec "JEDebugging" do |ss|
    ss.source_files         = "#{s.name}/JEDebugging/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation', 'UIKit'
    ss.dependency "#{s.name}/JEToolkit"
  end
  
  s.subspec "JEDispatch" do |ss|
    ss.source_files         = "#{s.name}/JEDispatch/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
    ss.dependency "#{s.name}/JEToolkit"
    ss.dependency "#{s.name}/JEDebugging"
  end
  
  s.subspec "JEKeychain" do |ss|
    ss.source_files         = "#{s.name}/JEKeychain/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
    ss.dependency "#{s.name}/JEToolkit"
    ss.dependency "#{s.name}/JEDebugging"
  end
  
  s.subspec "JEOrderedDictionary" do |ss|
    ss.source_files         = "#{s.name}/JEOrderedDictionary/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
    ss.dependency "#{s.name}/JEToolkit"
  end
  
  s.subspec "JESynthesize" do |ss|
    ss.source_files         = "#{s.name}/JESynthesize/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
    ss.dependency "#{s.name}/JEToolkit"
  end
  
  s.subspec "JEWeakCache" do |ss|
    ss.source_files         = "#{s.name}/JEWeakCache/**/*.{h,m,c}"
    ss.ios.frameworks       = 'Foundation'
    ss.dependency "#{s.name}/JEToolkit"
  end

end