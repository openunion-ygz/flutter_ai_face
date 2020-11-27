//
//  DetectionViewController.h
//  FaceSDKSample_IOS
//
//  Created by 阿凡树 on 2017/5/23.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "BDFaceBaseViewController.h"

@interface BDFaceDetectionViewController : BDFaceBaseViewController
//人脸验证协议对话框
@property (strong, nonatomic) UIAlertAction *okAction;
@property (strong, nonatomic) UIAlertAction *cancelAction;

@end
