
Pod::Spec.new do |s|
  s.name         = "CustomCamera"
  s.version      = "0.0.2"
  s.summary      = "简单的自定义相机,包括拍照，闪光灯，切换前后摄像头，图片浏览"
  s.description  = <<-DESC
简单的自定义相机,包括拍照，闪光灯，切换前后摄像头，图片浏览
                   DESC
  s.homepage     = "https://github.com/firenessZX/CustomCamera.git"
  s.license      = "MIT"
  s.author             = { "firenessZX" => "fireness@163.com" }
   s.platform     = :ios
   s.platform     = :ios, "8.0"
   s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/firenessZX/CustomCamera.git", :tag =>0.0.2}
  s.source_files  = "Classes", "CustomCamera/Classes/**/*.{h,m}"
  s.resources = 'CustomCamera/Classes/Resource/Asset/*.{png,xib}'
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true

end
