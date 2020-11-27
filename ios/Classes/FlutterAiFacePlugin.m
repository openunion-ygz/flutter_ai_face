#import "FlutterAiFacePlugin.h"

#import "IDLFaceSDK/IDLFaceSDK.h"
#import "BDFaceLivenessViewController.h"
#import "BDFaceDetectionViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "BDFaceLivingConfigViewController.h"
#import "BDFaceAgreementViewController.h"
#import "BDFaceLogoView.h"
#import "FaceParameterConfig.h"

#define ScreenRect [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface FlutterAiFacePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, retain) FlutterAiFaceStreamHandler *eventStreamHandler;
@end

@implementation FlutterAiFacePlugin{
    FlutterResult _result;
    UIViewController *_viewController;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar,FlutterStreamHandler>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_ai_face"
            binaryMessenger:[registrar messenger]];
  UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"aiFaceCallBackChannel" binaryMessenger:[registrar messenger]];
    
//  [eventChannel setStreamHandler:self];
    
  FlutterAiFacePlugin* instance = [[FlutterAiFacePlugin alloc] initWithViewController:viewController];
  instance.channel = channel;
    
  FlutterAiFaceStreamHandler* eventStreamHandler = [[FlutterAiFaceStreamHandler alloc] init];
    
  [eventChannel setStreamHandler:eventStreamHandler];
  instance.eventStreamHandler = eventStreamHandler;
    
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  if (self) {
    _viewController = viewController;
  }
       
       // 开始采集的Button
       UIButton *startBtn  = [[UIButton alloc] init];
       startBtn.frame = CGRectMake((_viewController.view.frame.size.width)/2, 478, 266.7, 52);
       [startBtn setImage:[UIImage imageNamed:@"btn_main_normal"] forState:UIControlStateNormal];
       [startBtn setImage:[UIImage imageNamed:@"btn_main_p"] forState:UIControlStateSelected];
       UILabel *btnLabel = [[UILabel alloc] init];
       btnLabel.frame = CGRectMake((_viewController.view.frame.size.width)/2, 495, 108, 18);
       btnLabel.text = @"开始人脸采集";
       btnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
       btnLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
       [_viewController.view addSubview:startBtn];
       [_viewController.view addSubview:btnLabel];
       [startBtn addTarget:self action:@selector(startGatherAction:) forControlEvents:UIControlEventTouchUpInside];
       
       UIView * remindView = [[UIView alloc] init];
       remindView.frame = CGRectMake((_viewController.view.frame.size.width-162)/2, 546, ScreenWidth, 14);
       
       // 人脸验证协议的label，提供了点击响应事件
       UILabel *remindLabel = [[UILabel alloc] init];
       remindLabel.frame = CGRectMake(50, 0, 112, 14);
       remindLabel.text = @"《人脸验证协议》";
       remindLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
       remindLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];
       remindLabel.userInteractionEnabled = YES;
       UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementAction:)];
       [remindLabel addGestureRecognizer:labelTapGestureRecognizer];
       [remindView addSubview:remindLabel];
       [_viewController.view addSubview:remindView];
  return self;
}



- (IBAction)checkAgreeClick:(UIButton *)sender {
    sender.selected ^= 1;
    // 如果再次点击选中button，提示窗口消失
//    [_viewController.warningView removeFromSuperview];
//    [_viewController.waringLabel removeFromSuperview];
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"icon_guide_s"] forState:UIControlStateSelected];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"checkAgreeBtn"];
    } else {
        [sender setImage:[UIImage imageNamed:@"icon_guide"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"checkAgreeBtn"];
        
    }
}

- (IBAction)agreementAction:(UILabel *)sender{
    BDFaceAgreementViewController *avc = [[BDFaceAgreementViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:avc];
    navi.navigationBarHidden = true;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [_viewController presentViewController:navi animated:YES completion:nil];
}


#pragma mark - Button Action
- (IBAction)startGatherAction:(UIButton *)sender{
    // 检测是否同意，如果同意"开始人脸采集"可点击
    NSNumber *checkAgree = [[NSUserDefaults standardUserDefaults] objectForKey:@"checkAgreeBtn"];
//    if (!checkAgree.boolValue){
//        [_viewController.view addSubview:self.warningView];
//        [_viewController.view addSubview:self.waringLabel];
//        return;
//    }
    // 读取设置配置，启动活体检测与否
    NSNumber *LiveMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"LiveMode"];
     NSLog(@"faceCollect LiveMode >>>>>>%@",LiveMode.description);
    if (LiveMode.boolValue){
        [self faceLiveness];
    } else {
        [self faceDetect];
    }
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFaceCollectResult:) name:@"notification" object:nil];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _result = result;
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if([@"aiFaceInit" isEqualToString:call.method]){
      [self aiFaceInit];
  }else if([@"faceCollect" isEqualToString:call.method]){
      [self faceCollect];
  }else if([@"aiFaceUnInit" isEqualToString:call.method]){
        [self aiFaceUnInit];
  }else {
      result(FlutterMethodNotImplemented);
  }
}

-(void)aiFaceInit{
    NSLog(@"aiFaceInit >>>>>>");
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"SoundMode"];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"LiveMode"];
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"ByOrder"];
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"checkAgreeBtn"];
    NSString* licensePath = [NSString stringWithFormat:@"%@.%@",  FACE_LICENSE_NAME, FACE_LICENSE_SUFFIX ];
    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath andRemoteAuthorize:false];
    [self initLivenesswithList];
    if ([[FaceSDKManager sharedInstance] canWork]) {
        [self initSDK];
       _result(@YES);
    }else{
       _result(@NO);
    }
    
}

-(void)aiFaceUnInit{
    // 销毁SDK功能函数
     [[FaceSDKManager sharedInstance] uninitCollect];
    
     [[NSNotificationCenter defaultCenter] removeObserver:@"notificationfun"];
    //或者
    //尽量不要使用，这种移除方式可能会移除系统的通知
//     [[NSNotificationCenter defaultCenter] removeObserver:self];
    _result(nil);
}
-(void)faceCollect{
    // 读取设置配置，启动活体检测与否
    NSNumber *LiveMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"LiveMode"];
      if (LiveMode.boolValue){
          [self faceLiveness];
      } else {
          [self faceDetect];
      }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFaceCollectResult:) name:@"notification" object:nil];
}

-(void)handleFaceCollectResult:(NSNotification *)info {
    NSString *faceStr = info.userInfo[@"faceStr"];
    if (_eventStreamHandler.faceEventSink != nil) {
     self.eventStreamHandler.faceEventSink(faceStr);
    }
    
}

- (void) initSDK {
    if (![[FaceSDKManager sharedInstance] canWork]){
        NSLog(@"授权失败，请检测ID 和 授权文件是否可用");
        return;
    }
    // 初始化SDK配置参数，可使用默认配置
    // 设置最小检测人脸阈值
    [[FaceSDKManager sharedInstance] setMinFaceSize:200];
    // 设置截取人脸图片高
    [[FaceSDKManager sharedInstance] setCropFaceSizeWidth:400];
    // 设置截取人脸图片宽
    [[FaceSDKManager sharedInstance] setCropFaceSizeHeight:640];
    // 设置人脸遮挡阀值
    [[FaceSDKManager sharedInstance] setOccluThreshold:0.5];
    // 设置亮度阀值
    [[FaceSDKManager sharedInstance] setIllumThreshold:40];
    // 设置图像模糊阀值
    [[FaceSDKManager sharedInstance] setBlurThreshold:0.3];
    // 设置头部姿态角度
    [[FaceSDKManager sharedInstance] setEulurAngleThrPitch:10 yaw:10 roll:10];
    // 设置人脸检测精度阀值
    [[FaceSDKManager sharedInstance] setNotFaceThreshold:0.6];
    // 设置抠图的缩放倍数
    [[FaceSDKManager sharedInstance] setCropEnlargeRatio:3.0];
    // 设置照片采集张数
    [[FaceSDKManager sharedInstance] setMaxCropImageNum:6];
    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:15];
    // 设置开启口罩检测，非动作活体检测可以采集戴口罩图片
    [[FaceSDKManager sharedInstance] setIsCheckMouthMask:true];
    // 设置开启口罩检测情况下，非动作活体检测口罩过滤阈值，默认0.8 不需要修改
    [[FaceSDKManager sharedInstance] setMouthMaskThreshold:0.8f];
    // 设置原始图缩放比例
    [[FaceSDKManager sharedInstance] setImageWithScale:0.8f];
    // 设置图片加密类型，type=0 基于base64 加密；type=1 基于百度安全算法加密
    [[FaceSDKManager sharedInstance] setImageEncrypteType:0];
    // 初始化SDK功能函数
    [[FaceSDKManager sharedInstance] initCollect];
}

- (void)initLivenesswithList {
    // 默认活体检测打开，顺序执行
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveEye)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveMouth)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawRight)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawLeft)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchUp)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchDown)];
    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYaw)];
    BDFaceLivingConfigModel.sharedInstance.isByOrder = YES;
    BDFaceLivingConfigModel.sharedInstance.numOfLiveness = 7;
}


- (void)faceDetect {
    BDFaceDetectionViewController* dvc = [[BDFaceDetectionViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:dvc];
    navi.navigationBarHidden = true;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:navi animated:YES completion:nil];
    [_viewController presentViewController:navi animated:YES completion:nil];
}

- (void)faceLiveness {
    BDFaceLivenessViewController* lvc = [[BDFaceLivenessViewController alloc] init];
    BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
    [lvc livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:lvc];
    navi.navigationBarHidden = true;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:navi animated:YES completion:nil];
    [_viewController presentViewController:navi animated:YES completion:nil];



}
- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData * _Nullable)message {
    
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData * _Nullable)message binaryReply:(FlutterBinaryReply _Nullable)callback {
    
}

- (void)setMessageHandlerOnChannel:(nonnull NSString *)channel binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler {
    
}

@end

@implementation FlutterAiFaceStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  self.faceEventSink = eventSink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  self.faceEventSink = nil;
  return nil;
}

@end
