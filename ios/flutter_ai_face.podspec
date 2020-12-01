#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ai_face.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ai_face'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  #引入系统库
  s.ios.libraries = 'stdc++','z'
  #引入百度ai平台license
  s.source_files = 'Classes/**/*','BDFaceSDK/idl-license.face-ios','BDFaceSDK/idl-key.face-ios','BDFaceSDK/*.bundle'
  #引入头文件
  s.public_header_files = 'Classes/**/*.h','BDFaceSDK/FaceParameterConfig.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

  #引入百度ai framework
    s.ios.vendored_frameworks = 'BDFaceSDK/IDLFaceSDK.framework'
    s.vendored_frameworks = 'IDLFaceSDK.framework'

  # 引入.bundle文件
  s.ios.resources = "BDFaceSDK/*.bundle","BDFaceSDK/com.baidu.idl.face.faceSDK.bundle","BDFaceSDK/com.baidu.idl.face.live.action.image.bundle","BDFaceSDK/com.baidu.idl.face.model.faceSDK.bundle",'BDFaceSDK/idl-license.face-ios','BDFaceSDK/idl-key.face-ios'
  s.resources = 'Assets/**/*','BDFaceSDK/*.bundle'

end
