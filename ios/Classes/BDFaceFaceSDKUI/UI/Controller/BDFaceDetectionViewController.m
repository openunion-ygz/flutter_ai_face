//
//  DetectionViewController.m
//  FaceSDKSample_IOS
//
//  Created by 阿凡树 on 2017/5/23.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BDFaceDetectionViewController.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "BDFaceSuccessViewController.h"
#import "BDFaceImageShow.h"

#define ScreenRect [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


@interface BDFaceDetectionViewController ()

@property (nonatomic, readwrite, retain) UIView *animaView;
@end
int remindCode = -1;
@implementation BDFaceDetectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 纯粹为了在照片成功之后，做闪屏幕动画之用
    self.animaView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.animaView.backgroundColor = [UIColor whiteColor];
    self.animaView.alpha = 0.8;
    [self.view addSubview:self.animaView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"进入新的界面");
    [[IDLFaceDetectionManager sharedInstance] startInitial];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IDLFaceDetectionManager sharedInstance] reset];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [IDLFaceDetectionManager.sharedInstance reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)agreementViewLoad{
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否同意《人脸验证协议》？" preferredStyle:UIAlertControllerStyleAlert];
    
      UILabel *agreeLabel = [[UILabel alloc] init];
      agreeLabel.frame = CGRectMake((ScreenWidth-160) / 2, 309.3, 160, 22);
      agreeLabel.text = @"是否同意《人脸验证协议》？";
      agreeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
      agreeLabel.textColor = [UIColor colorWithRed:0 / 0.0 green:0 / 0.0 blue:255 / 255.0 alpha:1 / 1.0];
    
    // 确定注销
    _okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    }];
    _cancelAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        
    }];
    
    [alert addAction:_okAction];
    [alert addAction:_cancelAction];
    // 弹出对话框
    [self presentViewController:alert animated:true completion:nil];
}

- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    
//    [self agreementViewLoad];
    
    __weak typeof(self) weakSelf = self;
    [[IDLFaceDetectionManager sharedInstance] detectStratrgyWithNormalImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(FaceInfo *faceinfo, NSDictionary *images, DetectRemindCode remindCode) {
         switch (remindCode) {
            case DetectRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [self warningStatus:CommonStatus warning:@"非常好"];
                if (images[@"image"] != nil && [images[@"image"] count] != 0) {
                    
                    NSArray *imageArr = images[@"image"];
                    for (FaceCropImageInfo * image in imageArr) {
                        NSLog(@"cropImageWithBlack %f %f", image.cropImageWithBlack.size.height, image.cropImageWithBlack.size.width);
                        NSLog(@"originalImage %f %f", image.originalImage.size.height, image.originalImage.size.width);
                    }

                    FaceCropImageInfo * bestImage = imageArr[0];
                    // UI显示选择原图，避免黑框情况
                    [[BDFaceImageShow sharedInstance] setSuccessImage:bestImage.originalImage];
                    [[BDFaceImageShow sharedInstance] setSilentliveScore:bestImage.silentliveScore];
                    
                    // 公安验证接口测试，网络接口上传选择扣图，避免占用贷款
                    // [self request:bestImage.cropImageWithBlackEncryptStr];
                    
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
            case DetectRemindCodeDataHitOne:
                 [self warningStatus:CommonStatus warning:@"非常好"];
                 break;
            case DetectRemindCodePitchOutofDownRange:
                [self warningStatus:PoseStatus warning:@"请略微抬头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodePitchOutofUpRange:
                [self warningStatus:PoseStatus warning:@"请略微低头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofLeftRange:
                [self warningStatus:PoseStatus warning:@"请略微向右转头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeYawOutofRightRange:
                [self warningStatus:PoseStatus warning:@"请略微向左转头"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodePoorIllumination:
                [self warningStatus:CommonStatus warning:@"请使环境光线再亮些"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeNoFaceDetected:
                [self warningStatus:CommonStatus warning:@"请将脸移入取景框"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeImageBlured:
                [self warningStatus:CommonStatus warning:@"请握稳手机，视线正对屏幕"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftEye:
                [self warningStatus:occlusionStatus warning:@"左眼有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightEye:
                [self warningStatus:occlusionStatus warning:@"右眼有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionNose:
                [self warningStatus:occlusionStatus warning:@"鼻子有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionMouth:
                [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionLeftContour:
                [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionRightContour:
                [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeOcclusionChinCoutour:
                [self warningStatus:occlusionStatus warning:@"下颚有遮挡"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeTooClose:
                [self warningStatus:CommonStatus warning:@"请将脸部离远一点"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeTooFar:
                [self warningStatus:CommonStatus warning:@"请将脸部靠近一点"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeBeyondPreviewFrame:
                [self warningStatus:CommonStatus warning:@"请将脸移入取景框"];
                [self singleActionSuccess:false];
                break;
            case DetectRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyDecryptError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoFormatError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyExpired:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyMissRequiredInfo:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyInfoCheckError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyLocalFileError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeVerifyRemoteDataError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                break;
            case DetectRemindCodeTimeout: {
                // 时间超时，重置之前采集数据
                 [[IDLFaceDetectionManager sharedInstance] reset];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isTimeOut:YES];
                });
                break;
            }
            case DetectRemindCodeConditionMeet: {
            }
                break;
            default:
                break;
        }
    }];
}

-(void) saveImage:(UIImage *) image withFileName:(NSString *) fileName{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 2.创建一个文件路径
    NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
    // 3.创建文件首先需要一个文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 4.创建文件
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    NSError * error = nil;
    
    BOOL written = [UIImageJPEGRepresentation(image,1.0f) writeToFile:filePath options:0 error:&error];
    if(!written){
        NSLog(@"write failed %@", [error localizedDescription]);
    }
}

-(void) saveFile:(NSString *) fileName withContent:(NSString *) content{
    NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *homePath = [paths objectAtIndex:0];
    
    NSString *filePath = [homePath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        NSString *str = @"索引 是否活体 活体分值 活体图片路径\n";
        [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    NSData* stringData  = [content dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData]; //追加写入数据
    [fileHandle closeFile];
}

-(NSString *) getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

- (void) request:(NSString *) imageStr{
    NSError *error;
    NSString *urlString = @"http://10.145.80.201:8316/api/v3/person/verify_sec?appid=9504621";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSMutableDictionary * dictionary =  [[NSMutableDictionary alloc] init];
    dictionary[@"risk_identify"] = @(false);
    
    
    dictionary[@"image_type"] = @"BASE64";
    dictionary[@"image"] = imageStr;
    dictionary[@"id_card_number"] = @"请输入你的身份证";
    dictionary[@"name"] = [@"请输入你的姓名" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dictionary[@"quality_control"] = @"NONE";
    dictionary[@"liveness_control"] = @"NONE";
    dictionary[@"risk_identify"] = @YES;
    dictionary[@"zid"] = [[FaceSDKManager sharedInstance] getZtoken];
    dictionary[@"ip"] = @"172.30.154.173";
    dictionary[@"phone"] = @"18610317119";
    dictionary[@"image_sec"] = @NO;
    dictionary[@"app"] = @"ios";
    dictionary[@"ev"] = @"smrz";
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    
    NSData *finalDataToDisplay = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSMutableDictionary *abc = [NSJSONSerialization JSONObjectWithData: finalDataToDisplay
                                                               options: NSJSONReadingMutableContainers
                                                                error: &error];
    NSLog(@"%@", abc);
}

- (void)selfReplayFunction{
    [[IDLFaceDetectionManager sharedInstance] reset];
}
@end
