#import "FlutterAiFacePlugin.h"

#import "IDLFaceSDK/IDLFaceSDK.h"
#import "BDFaceLivenessViewController.h"
#import "BDFaceDetectionViewController.h"
#import "BDFaceLivingConfigModel.h"
#import "BDFaceLivingConfigViewController.h"
#import "BDFaceAgreementViewController.h"
#import "BDFaceLogoView.h"
#import "FaceParameterConfig.h"

@implementation FlutterAiFacePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_ai_face"
            binaryMessenger:[registrar messenger]];
  FlutterAiFacePlugin* instance = [[FlutterAiFacePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
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
    
//    NSString *licensePath = [[NSBundle mainBundle] pathForResource:FACE_LICENSE_NAME ofType:FACE_LICENSE_SUFFIX];

    NSLog(@"aiFaceUnInit >>>>>> %@",[NSString stringWithFormat:@"%@",licensePath]);
    [[FaceSDKManager sharedInstance] setLicenseID:FACE_LICENSE_ID andLocalLicenceFile:licensePath andRemoteAuthorize:false];
    NSLog(@"canWork = %d",[[FaceSDKManager sharedInstance] canWork]);
    NSLog(@"version = %@",[[FaceSDKManager sharedInstance] getVersion]);
}
-(void)aiFaceUnInit{
     NSLog(@"aiFaceUnInit >>>>>>");
}
-(void)faceCollect{
    NSLog(@"faceCollect >>>>>>");
}

@end
