# flutter_ai_face

A new Flutter plugin.

## Getting Started

#主工程中添加混淆
#ai_face
-keep class com.baidu.vis.unified.license.**{*;}
-keep class com.baidu.idl.main.facesdk.**{*;}

#百度ai(IOS)
https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg
#百度ai(Android)
https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg
#关于idl-license.face-ios idl-key.face-ios证书的使用说明：
ios中，idl-license.face-ios及idl-key.face-ios文件必须在xcode中通过 "Add File to Runner"方式添加文件的形式，
将文件放在主工程的 ios/Runner目录下，否则无法找到证书文件

