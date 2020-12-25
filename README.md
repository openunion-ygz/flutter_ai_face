# flutter_ai_face

基于百度人脸ai封装并包含Android及iOS的flutter插件

## Getting Started

1.插件地址：

https://github.com/openunion-ygz/flutter_ai_face.git

2.使用方法：


（1）aiFaceInit

方法：
  Future<bool> aiFaceInit(String isCustomActionLive,{String isByOrder:'false',String isAddActionTypeEye:'false',String isAddActionTypeMouth:'false',String isAddActionTypeHeadRight:'false',
    String isAddActonTypeHeadLeft:'false',String isAddActionTypeHeadUp:'false',String isAddActionHeadDown:'false',String isAddActionHeadLeftOrRight:'false'})

    进行资源的初始化，必要权限的申请，百度人脸ai证书的认证以及人脸验证动作的定义等。该方法必须首先调用并且初始化成功，否则其它功能无法使用。另外，

    关于自定义人脸验证动作的说明：

    根据用户需求，可以使用默认的人脸验证动作：包含6个动作，同时动作随机，分别为：

    LivenessTypeEnum.Eye
    LivenessTypeEnum.Mouth
    LivenessTypeEnum.HeadRight
    //LivenessTypeEnum.HeadLeft
    LivenessTypeEnum.HeadUp
    LivenessTypeEnum.HeadDown
    LivenessTypeEnum.HeadLeftOrRight

    此时，调用的方式为：aiFaceInit('false');

    若用户需要自定义验证动作，则在对应的动作参数中定义布尔值即可，如：用户需要定义 Eye，HeadLeftOrRight，Mouth三个动作，则

    调用的方法为：

     FlutterAiFace.instance.aiFaceInit('true',isAddActionTypeEye: 'true',isAddActionHeadLeftOrRight: 'true',
                              isAddActionTypeMouth: 'true');

     同时，可以通过“isByOrder”指定是否随机（用户自定义动作情况下，默认为随机动作）


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

#关于需要在主工程中引入资源文件的引入说明（IOS）：

在主工程中，需要将解压的百度官网下载文件“FaceSDKSample_IOS\FaceSDKSample_IOS\Assets.xcassets”文件

除“AppIcon.appiconset”，“AppIcon.appiconset”之外的资源文件添加到主工程“ios/Runner/Assets.xcassets”目录下。


4.其它：

#百度ai(IOS)

https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg


#百度ai(Android)

https://ai.baidu.com/ai-doc/FACE/6kd3yu9vg

