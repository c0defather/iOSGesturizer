Pod::Spec.new do |s|

  s.name         = "iOSGesturizer"
  s.version      = "1.0.4"
  s.summary      = "Enables custom gesture based interaction for iOS apps."
  s.description  = "The library adds gesture based interaction for any app just in couple lines of code. The gesture interaction is activated using 3D-touch and gestures can be customized."
  s.homepage     = "https://github.com/c0defather/iOSGesturizer"
  s.license      = "MIT"
  s.author             = { "Kuanysh Zhunussov" => "kuanysh.zhunussov@gmail.com" }
  s.platform     = :ios, "9.0"
  s.swift_version = "4.0"
  s.source       = { :git => "https://github.com/c0defather/iOSGesturizer.git", :tag => "1.0.4" }
  s.source_files  = "iOSGesturizer/**/*"
end
