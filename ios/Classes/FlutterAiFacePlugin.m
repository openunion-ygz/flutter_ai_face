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
//@property(nonatomic, retain) FlutterMethodCall *call;


@property (nonatomic, readwrite, retain) UIView *agreementMainView;
@property (nonatomic, readwrite, retain) UILabel *agreementTitle;
@property (nonatomic, readwrite, retain) UILabel *agreementLabel;
@property (nonatomic, readwrite, retain) UIView *agreementLine;
@property (nonatomic, readwrite, retain) UIButton *agreementAgreeButton;
@property (nonatomic, readwrite, retain) UILabel *agreementAgreeLabel;
@property (nonatomic, readwrite, retain) UIView *agreementLine2;
@property (nonatomic, readwrite, retain) UIButton *agreementCancelButton2;
@property (nonatomic, readwrite, retain) UILabel *agreementCancelLabel2;
@property (nonatomic, readwrite, retain) UIView *agreementView;

@end

@implementation FlutterAiFacePlugin{
    FlutterResult _result;
    UIViewController *_viewController;
    FlutterMethodCall *_call;
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
//       UIButton *startBtn  = [[UIButton alloc] init];
//       startBtn.frame = CGRectMake((_viewController.view.frame.size.width)/2, 478, 266.7, 52);
//       [startBtn setImage:[UIImage imageNamed:@"btn_main_normal"] forState:UIControlStateNormal];
//       [startBtn setImage:[UIImage imageNamed:@"btn_main_p"] forState:UIControlStateSelected];
//       UILabel *btnLabel = [[UILabel alloc] init];
//       btnLabel.frame = CGRectMake((_viewController.view.frame.size.width)/2, 495, 108, 18);
//       btnLabel.text = @"开始人脸采集";
//       btnLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
//       btnLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
//       [_viewController.view addSubview:startBtn];
//       [_viewController.view addSubview:btnLabel];
//       [startBtn addTarget:self action:@selector(startGatherAction:) forControlEvents:UIControlEventTouchUpInside];
       
           // 超时的最底层view，大小和屏幕大小一致，为了突出弹窗的view的效果，背景为灰色，0.7的透视度
        _agreementMainView = [[UIView alloc] init];
        _agreementMainView.frame = ScreenRect;
        _agreementMainView.alpha = 0.7;
        _agreementMainView.backgroundColor = [UIColor grayColor];
           
           // 弹出的主体view
        self.agreementView = [[UIView alloc] init];
        self.agreementView.frame = CGRectMake((ScreenWidth-320) / 2, (ScreenHeight-180)/2, 320, 180);
        self.agreementView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1 / 1.0];
        self.agreementView.layer.cornerRadius = 10;
        self.agreementView.layer.masksToBounds = YES;
        
        
        _agreementTitle = [[UILabel alloc] init];
        _agreementTitle.frame = CGRectMake((ScreenWidth-76) / 2, (ScreenHeight-180)/2, 76, 76);
        _agreementTitle.text = @"温馨提示";
        _agreementTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _agreementTitle.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
        
    
         // 创建Attributed
         NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:@"是否同意《人脸采集协议》"];
        // 需要改变的第一个文字的位置
         NSUInteger firstLoc = [[noteStr string] rangeOfString:@"《"].location;
        // 需要改变的最后一个文字的位置
        NSUInteger secondLoc = [[noteStr string] rangeOfString:@"》"].location+1;
           // 需要改变的区间
           NSRange range = NSMakeRange(firstLoc, secondLoc - firstLoc);
           // 改变颜色
           [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0] range:range];
    
           _agreementLabel = [[UILabel alloc] init];
           _agreementLabel.frame = CGRectMake((ScreenWidth -220) / 2, (ScreenHeight-180)/2+80, 220, 22);
          
           _agreementLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
           _agreementLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
        [_agreementLabel setAttributedText:noteStr];
        _agreementLabel.userInteractionEnabled = YES;
        [_agreementLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementInfo:)]];

           _agreementLine = [[UIView alloc] init];
           _agreementLine.frame = CGRectMake((ScreenWidth-320) / 2 +10, (ScreenHeight-180)/2+120, 300, 1);
           _agreementLine.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];

        _agreementLine2 = [[UIView alloc] init];
        _agreementLine2.frame = CGRectMake(ScreenWidth / 2, (ScreenHeight-180)/2+130, 1, 36);
        _agreementLine2.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];

        _agreementCancelButton2 = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth-320)/4, (ScreenHeight-180)/2+140, 160, 36)];
        [_agreementCancelButton2 addTarget:self action:@selector(agreementCancelClick:) forControlEvents:UIControlEventTouchUpInside];
     
        _agreementCancelLabel2 = [[UILabel alloc] init];
        _agreementCancelLabel2.frame = CGRectMake((ScreenWidth / 2)-72, (ScreenHeight-180)/2+140, 72, 18);
        _agreementCancelLabel2.text = @"取消";
        _agreementCancelLabel2.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _agreementCancelLabel2.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
        
            _agreementAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, (ScreenHeight-180)/2+140, 160, 36)];
            [_agreementAgreeButton addTarget:self action:@selector(agreementClick:) forControlEvents:UIControlEventTouchUpInside];
            
            _agreementAgreeLabel = [[UILabel alloc] init];
            _agreementAgreeLabel.frame = CGRectMake((ScreenWidth / 2)+54, (ScreenHeight-180)/2+140, 72, 18);
            _agreementAgreeLabel.text = @"同意";
            _agreementAgreeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
            _agreementAgreeLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];

       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFaceCollectResult:) name:@"notification" object:nil];
  return self;
}


- (void)agreementViewLoad{
    [_viewController.view addSubview:_agreementMainView];
    [_viewController.view addSubview:_agreementView];
    [_viewController.view addSubview:_agreementTitle];
    [_viewController.view addSubview:_agreementLabel];
    [_viewController.view addSubview:_agreementLine];
    [_viewController.view addSubview:_agreementAgreeButton];
    [_viewController.view addSubview:_agreementAgreeLabel];
    [_viewController.view addSubview:_agreementLine2];
    [_viewController.view addSubview:_agreementCancelLabel2];
    [_viewController.view addSubview:_agreementCancelButton2];
}

- (void)agreementViewUnload{
    [_agreementMainView removeFromSuperview];
    [_agreementView removeFromSuperview];
    [_agreementTitle removeFromSuperview];
    [_agreementLabel removeFromSuperview];
    [_agreementLine removeFromSuperview];
    [_agreementAgreeButton removeFromSuperview];
    [_agreementAgreeLabel removeFromSuperview];
    [_agreementLine2 removeFromSuperview];
    [_agreementCancelLabel2 removeFromSuperview];
    [_agreementCancelButton2 removeFromSuperview];
}

-(void)agreementInfo:(UITapGestureRecognizer *)tap{
    BDFaceAgreementViewController *avc = [[BDFaceAgreementViewController alloc] init];
     UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:avc];
     navi.navigationBarHidden = true;
     navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [_viewController presentViewController:navi animated:YES completion:nil];
}

-(void) agreementClick:(UITapGestureRecognizer *)tap{
    [self agreementViewUnload];
        // 读取设置配置，启动活体检测与否
        NSNumber *LiveMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"LiveMode"];
        if (LiveMode.boolValue){
            [self faceLiveness];
        } else {
            [self faceDetect];
        }
}

-(void) agreementCancelClick:(UITapGestureRecognizer *)tap{
    [self agreementViewUnload];
    [_viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button Action
- (IBAction)startGatherAction:(UIButton *)sender{
    [self agreementViewLoad];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _result = result;
    _call = call;
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
    [self agreementViewLoad];
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


/** isCustomActionLive
    * bool isByOrder:true,bool isAddActionTypeEye:false,bool isAddActionTypeMouth:false,bool isAddActionTypeHeadRight:false,
    * bool isAddActonTypeHeadLeft:false,bool isAddActionTypeHeadUp:false,bool isAddActionHeadDown:false,bool isAddActionHeadLeftOrRight:false}
    */
- (void)initLivenesswithList {
    if (_call != nil) {
        
        BOOL isCustomActionLive = [_call.arguments[@"isCustomActionLive"] boolValue];
        if(isCustomActionLive){
            NSLog(@"自定义验证动作===>");
             BOOL isAddActionTypeEye = [_call.arguments[@"isAddActionTypeEye"] boolValue];
             BOOL isAddActionTypeMouth = [_call.arguments[@"isAddActionTypeMouth"] boolValue];
             BOOL isAddActionTypeHeadRight = [_call.arguments[@"isAddActionTypeHeadRight"] boolValue];
             BOOL isAddActonTypeHeadLeft = [_call.arguments[@"isAddActonTypeHeadLeft"] boolValue];
             BOOL isAddActionTypeHeadUp = [_call.arguments[@"isAddActionTypeHeadUp"] boolValue];
             BOOL isAddActionHeadDown = [_call.arguments[@"isAddActionHeadDown"] boolValue];
            BOOL isAddActionHeadLeftOrRight = [_call.arguments[@"isAddActionHeadLeftOrRight"] boolValue];
            if (isAddActionTypeEye) {
                NSLog(@"眨眼动作===>");
                 [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveEye)];
            }
            if (isAddActionTypeMouth) {
                NSLog(@"张嘴动作===>");
                 [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveMouth)];
                      }
            if (isAddActionTypeHeadRight) {
                   NSLog(@"右转动作===>");
                 [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawRight)];
                      }
            if (isAddActonTypeHeadLeft) {
                   NSLog(@"左转动作===>");
                 [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawLeft)];
                      }
            if (isAddActionTypeHeadUp) {
                   NSLog(@"抬头动作===>");
                   [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchUp)];
                      }
            if (isAddActionHeadDown) {
                   NSLog(@"低头动作===>");
                    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchDown)];
                      }
            if (isAddActionHeadLeftOrRight) {
                   NSLog(@"左右摇头动作===>");
                  [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYaw)];
                      }

            BOOL isByOrder = [_call.arguments[@"isByOrder"] boolValue];
            if (isByOrder) {
                BDFaceLivingConfigModel.sharedInstance.isByOrder = YES;
            }else{
                BDFaceLivingConfigModel.sharedInstance.isByOrder = NO;
            }
              NSInteger numOfLiveness = [BDFaceLivingConfigModel.sharedInstance.liveActionArray count];
              BDFaceLivingConfigModel.sharedInstance.numOfLiveness = numOfLiveness;
               NSLog(@"张嘴numOfLiveness===>%ld",numOfLiveness);
            
        }else{
             NSLog(@"默认验证动作 ===>");
               // 默认活体检测打开，顺序执行
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveEye)];
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveMouth)];
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawRight)];
            //    [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYawLeft)];
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchUp)];
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLivePitchDown)];
                [BDFaceLivingConfigModel.sharedInstance.liveActionArray addObject:@(FaceLivenessActionTypeLiveYaw)];
                BDFaceLivingConfigModel.sharedInstance.isByOrder = NO;
                BDFaceLivingConfigModel.sharedInstance.numOfLiveness = 6;
        }
    }
 
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
