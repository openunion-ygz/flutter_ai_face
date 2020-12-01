# flutter_ai_face

基于百度人脸ai封装并包含Android及iOS的flutter插件

## Getting Started

1.插件地址：

https://github.com/openunion-ygz/flutter_ai_face.git

2.使用方法：


（1）aiFaceInit

    进行资源的初始化，必要权限的申请，百度人脸ai证书的认证等。该方法必须首先调用并且初始化成功，否则其它功能无法使用。

（2）faceCollect

    人脸信息采集

（3）aiFaceCallBackListener

    人脸采集数据回调监听，用于接收人脸采集完成之后的base64格式的图片数据

（4）aiFaceUnInit

    资源释放方法，在页面销毁或者程序退出时，需要调用以防止内存溢出。

3.注意事项：

需要说明的是：本插件是基于在百度人脸ai开发者平台上完成对应的开发者信息申请认证的前提下进行的，若没有进行申请认证，需要先进行注册认证。

#主工程中添加混淆

#ai_face（Android）

-keep class com.baidu.vis.unified.license.**{*;}

-keep class com.baidu.idl.main.facesdk.**{*;}

#关于idl-license.face-ios idl-key.face-ios证书的使用说明（IOS）：

ios中，idl-license.face-ios及idl-key.face-ios文件必须在xcode中通过 "Add File to Runner"方式添加文件的形式，
将文件放在主工程的 ios/Runner目录下，否则无法找到证书文件


4.其它：

#百度ai(IOS)

https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg


#百度ai(Android)

https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg

