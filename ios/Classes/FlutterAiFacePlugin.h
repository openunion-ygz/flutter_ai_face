#import <Flutter/Flutter.h>

@interface FlutterAiFacePlugin : NSObject<FlutterPlugin>
@end

@interface FlutterAiFaceStreamHandler : NSObject<FlutterStreamHandler>
//人脸采集成功通道
@property (nonatomic, copy) FlutterEventSink faceEventSink;

/**
 *  协议view
 */
@property (nonatomic, readwrite, retain) UIView *agreementView;

@end
