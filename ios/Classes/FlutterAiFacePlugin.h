#import <Flutter/Flutter.h>

@interface FlutterAiFacePlugin : NSObject<FlutterPlugin,FlutterBinaryMessenger,FlutterStreamHandler>
//人脸采集成功通道
@property (nonatomic, copy) FlutterEventSink eventSink;

+(void) handleFaceCollectResult:(NSString *)faceStr;

@end
