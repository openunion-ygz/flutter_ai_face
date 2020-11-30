//
//  LivenessViewController.m
//  FaceSDKSample_IOS
//
//  Created by 阿凡树 on 2017/5/23.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BDFaceLivenessViewController.h"
#import "BDFaceSuccessViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "BDFaceImageShow.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import "BDFaceAgreementViewController.h"

#define ScreenRect [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface BDFaceLivenessViewController (){
}
@property (nonatomic, strong) NSArray *livenessArray;
@property (nonatomic, assign) BOOL order;
@property (nonatomic, assign) NSInteger numberOfLiveness;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isStartFaceCollect;

@property (nonatomic, readwrite, retain) UIView *agreementMainView;
@property (nonatomic, readwrite, retain) UILabel *agreementTitle;
@property (nonatomic, readwrite, retain) UILabel *agreementLabel;
@property (nonatomic, readwrite, retain) UIView *agreementLine;
@property (nonatomic, readwrite, retain) UIButton *agreementAgreeButton;
@property (nonatomic, readwrite, retain) UILabel *agreementAgreeLabel;
@property (nonatomic, readwrite, retain) UIView *agreementLine2;
@property (nonatomic, readwrite, retain) UIButton *agreementCancelButton2;
@property (nonatomic, readwrite, retain) UILabel *agreementCancelLabel2;



@end

@implementation BDFaceLivenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 刻度线背颜色
    self.circleProgressView.lineBgColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
    // 刻度线进度颜色
    self.circleProgressView.scaleColor =  [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];
    [self.view addSubview:self.circleProgressView];
    
    // 提示动画设置
    [self.view addSubview:self.remindAnimationView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.remindAnimationView setActionImages];
    });
    
    
    
    // 超时的view初始化，但是不添加到当前view内
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
    
       
       // 超时的label
       _agreementLabel = [[UILabel alloc] init];
       _agreementLabel.frame = CGRectMake((ScreenWidth -220) / 2, (ScreenHeight-180)/2+80, 220, 22);
       _agreementLabel.text = @"是否同意《人脸验证协议》";
       _agreementLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
       _agreementLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:1 / 1.0];
    _agreementLabel.userInteractionEnabled = YES;
    [_agreementLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementInfo:)]];

       
       // 区分线
       _agreementLine = [[UIView alloc] init];
       _agreementLine.frame = CGRectMake((ScreenWidth-320) / 2 +10, (ScreenHeight-180)/2+120, 300, 1);
       _agreementLine.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];

    // 区分线
    _agreementLine2 = [[UIView alloc] init];
    _agreementLine2.frame = CGRectMake(ScreenWidth / 2, (ScreenHeight-180)/2+130, 1, 36);
    _agreementLine2.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];

    
    // 回到首页的button
    _agreementCancelButton2 = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth-320)/4, (ScreenHeight-180)/2+140, 160, 36)];
    [_agreementCancelButton2 addTarget:self action:@selector(agreementCancelClick:) forControlEvents:UIControlEventTouchUpInside];
 
    
    // 回到首页的label
    _agreementCancelLabel2 = [[UILabel alloc] init];
    _agreementCancelLabel2.frame = CGRectMake((ScreenWidth / 2)-72, (ScreenHeight-180)/2+140, 72, 18);
    _agreementCancelLabel2.text = @"取消";
    _agreementCancelLabel2.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    _agreementCancelLabel2.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1 / 1.0];
    
    // 重新开始采集button
        _agreementAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, (ScreenHeight-180)/2+140, 160, 36)];
//         _agreementAgreeButton.backgroundColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];
        [_agreementAgreeButton addTarget:self action:@selector(agreementClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 重新采集的文字label
        _agreementAgreeLabel = [[UILabel alloc] init];
        _agreementAgreeLabel.frame = CGRectMake((ScreenWidth / 2)+54, (ScreenHeight-180)/2+140, 72, 18);
        _agreementAgreeLabel.text = @"同意";
        _agreementAgreeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _agreementAgreeLabel.textColor = [UIColor colorWithRed:0 / 255.0 green:186 / 255.0 blue:242 / 255.0 alpha:1 / 1.0];
    self.isStartFaceCollect = YES;
    
    
}


- (void)agreementViewLoad{
    [self.view addSubview:_agreementMainView];
    [self.view addSubview:_agreementView];
    [self.view addSubview:_agreementTitle];
    [self.view addSubview:_agreementLabel];
    [self.view addSubview:_agreementLine];
    [self.view addSubview:_agreementAgreeButton];
    [self.view addSubview:_agreementAgreeLabel];
    [self.view addSubview:_agreementLine2];
    [self.view addSubview:_agreementCancelLabel2];
    [self.view addSubview:_agreementCancelButton2];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IDLFaceLivenessManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IDLFaceLivenessManager.sharedInstance reset];
}
-(void)agreementInfo:(UITapGestureRecognizer *)tap{

    NSLog(@"agreementInfo ====>");
    BDFaceAgreementViewController *avc = [[BDFaceAgreementViewController alloc] init];
//    UIViewController *currentvc = self.presentingViewController;
     UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:avc];
     navi.navigationBarHidden = true;
     navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAgreeResult:) name:@"notification" object:nil];
}
//-(void)handleAgreeResult:(NSNotification *)info {
//    NSString *backFromAgreement = info.userInfo[@"backFromAgreement"];
//    if ([backFromAgreement isEqualToString:@"YES"]) {
//        
//    }
//    
//}

- (void)selfReplayFunction{
     [[IDLFaceLivenessManager sharedInstance] reset];
     BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
     [[IDLFaceLivenessManager sharedInstance] livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
}

- (void)onAppBecomeActive {
    [super onAppBecomeActive];
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:_livenessArray order:_order numberOfLiveness:_numberOfLiveness];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [IDLFaceLivenessManager.sharedInstance reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)livenesswithList:(NSArray *)livenessArray order:(BOOL)order numberOfLiveness:(NSInteger)numberOfLiveness {
    _livenessArray = [NSArray arrayWithArray:livenessArray];
    _order = order;
    _numberOfLiveness = numberOfLiveness;
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:livenessArray order:order numberOfLiveness:numberOfLiveness];
}

-(void) agreementClick:(UITapGestureRecognizer *)tap{
    self.isStartFaceCollect = YES;
    [self agreementViewUnload];
    
//    self.videoCapture.runningStatus = YES;
//    [self.videoCapture startSession];
}

-(void) agreementCancelClick:(UITapGestureRecognizer *)tap{
    self.isStartFaceCollect = NO;
    [self agreementViewUnload];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)startFaceCollect:(UIImage *)image{
     if (self.hasFinished) {
            return;
        }
//    if (!self.isStartFaceCollect) {
//               return;
//           }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isAnimating = [self.remindAnimationView isActionAnimating];
        });
        
        if (self.isAnimating){
            return;
        }

        __weak typeof(self) weakSelf = self;
        [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
            
            switch (remindCode) {
                case LivenessRemindCodeOK: {
    //                人脸采集成功
                    weakSelf.hasFinished = YES;
                    [self warningStatus:CommonStatus warning:@"非常好"];
                    if (images[@"image"] != nil && [images[@"image"] count] != 0) {
                        
                        NSArray *imageArr = images[@"image"];
                        for (FaceCropImageInfo * image in imageArr) {
                            NSLog(@"cropImageWithBlack %f %f", image.cropImageWithBlack.size.height, image.cropImageWithBlack.size.width);
                            NSLog(@"originalImage %f %f", image.originalImage.size.height, image.originalImage.size.width);
                        }

                        FaceCropImageInfo * bestImage = imageArr[0];
                        
                        NSLog(@"originalImage String ===>%@", bestImage.originalImageEncryptStr);
                        
                        [[BDFaceImageShow sharedInstance] setSuccessImage:bestImage.originalImage];
                        [[BDFaceImageShow sharedInstance] setSilentliveScore:bestImage.silentliveScore];
                        [[BDFaceImageShow sharedInstance] setOriginalImageEncryptStr:bestImage.originalImageEncryptStr];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIViewController* fatherViewController = weakSelf.presentingViewController;
                            [weakSelf dismissViewControllerAnimated:YES completion:^{
                                BDFaceSuccessViewController *avc = [[BDFaceSuccessViewController alloc] init];
                                avc.modalPresentationStyle = UIModalPresentationFullScreen;
                                [fatherViewController presentViewController:avc animated:YES completion:nil];
                                [self closeAction];
                            }];
                        });
                    }
                    [self singleActionSuccess:true];
                    break;
                }
                case LivenessRemindCodePitchOutofDownRange:
                    [self warningStatus:PoseStatus warning:@"请略微抬头" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodePitchOutofUpRange:
                    [self warningStatus:PoseStatus warning:@"请略微低头" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeYawOutofRightRange:
                    [self warningStatus:PoseStatus warning:@"请略微向右转头" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeYawOutofLeftRange:
                    [self warningStatus:PoseStatus warning:@"请略微向左转头" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodePoorIllumination:
                    [self warningStatus:CommonStatus warning:@"请使环境光线再亮些" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeNoFaceDetected:
                    [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeImageBlured:
                    [self warningStatus:CommonStatus warning:@"请握稳手机，视线正对屏幕" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionLeftEye:
                    [self warningStatus:occlusionStatus warning:@"左眼有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionRightEye:
                    [self warningStatus:occlusionStatus warning:@"右眼有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionNose:
                    [self warningStatus:occlusionStatus warning:@"鼻子有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionMouth:
                    [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionLeftContour:
                    [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionRightContour:
                    [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeOcclusionChinCoutour:
                    [self warningStatus:occlusionStatus warning:@"下颚有遮挡" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeTooClose:
                    [self warningStatus:CommonStatus warning:@"请将脸部离远一点" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeTooFar:
                    [self warningStatus:CommonStatus warning:@"请将脸部靠近一点" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeBeyondPreviewFrame:
                    [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:false];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLiveEye:
                    [self warningStatus:CommonStatus warning:@"眨眨眼" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLiveMouth:
                    [self warningStatus:CommonStatus warning:@"张张嘴" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLiveYawRight:
                    [self warningStatus:CommonStatus warning:@"向右缓慢转头" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLiveYawLeft:
                    [self warningStatus:CommonStatus warning:@"向左缓慢转头" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLivePitchUp:
                    [self warningStatus:CommonStatus warning:@"缓慢抬头" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLivePitchDown:
                    [self warningStatus:CommonStatus warning:@"缓慢低头" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeLiveYaw:
                    [self warningStatus:CommonStatus warning:@"左右摇头" conditionMeet:true];
                    [self singleActionSuccess:false];
                    break;
                case LivenessRemindCodeSingleLivenessFinished:
                {
                    [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                        NSLog(@"Finished 非常好 %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.circleProgressView setPercent:(CGFloat)(numberOfSuccess / numberOfLiveness)];
                       });
                    }];
                    [self warningStatus:CommonStatus warning:@"非常好" conditionMeet:true];
                    [self singleActionSuccess:true];
                }
                    break;
                case LivenessRemindCodeFaceIdChanged:
                {
                    [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                        NSLog(@"face id changed %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.circleProgressView setPercent:0];
                       });
                    }];
                    [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:true];
                }
                    break;
                case LivenessRemindCodeVerifyInitError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyDecryptError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyInfoFormatError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyExpired:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyMissRequiredInfo:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyInfoCheckError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyLocalFileError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeVerifyRemoteDataError:
                    [self warningStatus:CommonStatus warning:@"验证失败"];
                    break;
                case LivenessRemindCodeTimeout: {
                    // 时间超时，重置之前采集数据
                     [[IDLFaceLivenessManager sharedInstance] reset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 时间超时，ui进度重置0
                        [self.circleProgressView setPercent:0];
                        [self isTimeOut:YES];
                    });
                    break;
                }
                case LivenessRemindActionCodeTimeout:{
                    [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                        NSLog(@"动作超时 %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.remindAnimationView startActionAnimating:(int)currenActionType];
                        });
                    }];
                }
                case LivenessRemindCodeConditionMeet: {
                }
                    break;
                default:
                    break;
            }
        }];
    
}
- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    if (!self.isStartFaceCollect) {
           return;
       }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isAnimating = [self.remindAnimationView isActionAnimating];
    });
    
    if (self.isAnimating){
        return;
    }

    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessNormalWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, FaceInfo *faceInfo, LivenessRemindCode remindCode) {
        
        switch (remindCode) {
            case LivenessRemindCodeOK: {
//                人脸采集成功
                weakSelf.hasFinished = YES;
                [self warningStatus:CommonStatus warning:@"非常好"];
                if (images[@"image"] != nil && [images[@"image"] count] != 0) {
                    
                    NSArray *imageArr = images[@"image"];
                    for (FaceCropImageInfo * image in imageArr) {
                        NSLog(@"cropImageWithBlack %f %f", image.cropImageWithBlack.size.height, image.cropImageWithBlack.size.width);
                        NSLog(@"originalImage %f %f", image.originalImage.size.height, image.originalImage.size.width);
                    }

                    FaceCropImageInfo * bestImage = imageArr[0];
                    
                    NSLog(@"originalImage String ===>%@", bestImage.originalImageEncryptStr);
                    
                    [[BDFaceImageShow sharedInstance] setSuccessImage:bestImage.originalImage];
                    [[BDFaceImageShow sharedInstance] setSilentliveScore:bestImage.silentliveScore];
                    [[BDFaceImageShow sharedInstance] setOriginalImageEncryptStr:bestImage.originalImageEncryptStr];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIViewController* fatherViewController = weakSelf.presentingViewController;
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            BDFaceSuccessViewController *avc = [[BDFaceSuccessViewController alloc] init];
                            avc.modalPresentationStyle = UIModalPresentationFullScreen;
                            [fatherViewController presentViewController:avc animated:YES completion:nil];
                            [self closeAction];
                        }];
                    });
                }
                [self singleActionSuccess:true];
                break;
            }
            case LivenessRemindCodePitchOutofDownRange:
                [self warningStatus:PoseStatus warning:@"请略微抬头" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodePitchOutofUpRange:
                [self warningStatus:PoseStatus warning:@"请略微低头" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeYawOutofRightRange:
                [self warningStatus:PoseStatus warning:@"请略微向右转头" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeYawOutofLeftRange:
                [self warningStatus:PoseStatus warning:@"请略微向左转头" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodePoorIllumination:
                [self warningStatus:CommonStatus warning:@"请使环境光线再亮些" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeNoFaceDetected:
                [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeImageBlured:
                [self warningStatus:CommonStatus warning:@"请握稳手机，视线正对屏幕" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionLeftEye:
                [self warningStatus:occlusionStatus warning:@"左眼有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionRightEye:
                [self warningStatus:occlusionStatus warning:@"右眼有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionNose:
                [self warningStatus:occlusionStatus warning:@"鼻子有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionMouth:
                [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionLeftContour:
                [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionRightContour:
                [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeOcclusionChinCoutour:
                [self warningStatus:occlusionStatus warning:@"下颚有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeTooClose:
                [self warningStatus:CommonStatus warning:@"请将脸部离远一点" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeTooFar:
                [self warningStatus:CommonStatus warning:@"请将脸部靠近一点" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeBeyondPreviewFrame:
                [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:false];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveEye:
                [self warningStatus:CommonStatus warning:@"眨眨眼" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveMouth:
                [self warningStatus:CommonStatus warning:@"张张嘴" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYawRight:
                [self warningStatus:CommonStatus warning:@"向右缓慢转头" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYawLeft:
                [self warningStatus:CommonStatus warning:@"向左缓慢转头" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLivePitchUp:
                [self warningStatus:CommonStatus warning:@"缓慢抬头" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLivePitchDown:
                [self warningStatus:CommonStatus warning:@"缓慢低头" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeLiveYaw:
                [self warningStatus:CommonStatus warning:@"左右摇头" conditionMeet:true];
                [self singleActionSuccess:false];
                break;
            case LivenessRemindCodeSingleLivenessFinished:
            {
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    NSLog(@"Finished 非常好 %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self.circleProgressView setPercent:(CGFloat)(numberOfSuccess / numberOfLiveness)];
                   });
                }];
                [self warningStatus:CommonStatus warning:@"非常好" conditionMeet:true];
                [self singleActionSuccess:true];
            }
                break;
            case LivenessRemindCodeFaceIdChanged:
            {
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    NSLog(@"face id changed %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self.circleProgressView setPercent:0];
                   });
                }];
                [self warningStatus:CommonStatus warning:@"请将脸移入取景框" conditionMeet:true];
            }
                break;
            case LivenessRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyDecryptError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyInfoFormatError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyExpired:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyMissRequiredInfo:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyInfoCheckError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyLocalFileError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeVerifyRemoteDataError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case LivenessRemindCodeTimeout: {
                // 时间超时，重置之前采集数据
                 [[IDLFaceLivenessManager sharedInstance] reset];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 时间超时，ui进度重置0
                    [self.circleProgressView setPercent:0];
                    [self isTimeOut:YES];
                });
                break;
            }
            case LivenessRemindActionCodeTimeout:{
                [[IDLFaceLivenessManager sharedInstance] livenessProcessHandler:^(float numberOfLiveness, float numberOfSuccess, LivenessActionType currenActionType) {
                    NSLog(@"动作超时 %d %d %d", (int)numberOfLiveness, (int)numberOfSuccess, (int)currenActionType);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.remindAnimationView startActionAnimating:(int)currenActionType];
                    });
                }];
            }
            case LivenessRemindCodeConditionMeet: {
            }
                break;
            default:
                break;
        }
    }];
}

//- (void)selfReplayFunction{
//     [[IDLFaceLivenessManager sharedInstance] reset];
//     BDFaceLivingConfigModel* model = [BDFaceLivingConfigModel sharedInstance];
//     [[IDLFaceLivenessManager sharedInstance] livenesswithList:model.liveActionArray order:model.isByOrder numberOfLiveness:model.numOfLiveness];
//}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning conditionMeet:(BOOL)meet{
    [self warningStatus:status warning:warning];
}
@end
