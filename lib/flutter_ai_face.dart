import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ai_face/constants.dart';

class FlutterAiFace {
  static const MethodChannel _channel =
      const MethodChannel('${Constants.NAMESPACE}');

  static EventChannel _aiFaceCallBackChannel =
      const EventChannel('${Constants.aiFaceCallBackChannel}');

  final StreamController<MethodCall> _methodStreamController =
  new StreamController.broadcast(); // ignore: close_sinks
  Stream<MethodCall> get _methodStream => _methodStreamController
      .stream;

  FlutterAiFace._() {
    //在原生中注册的事件通知通道也必须要在flutter注册，否则会通道对象无法实例化。
    _aiFaceCallBackChannel.receiveBroadcastStream();
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
      return;
    });

  }

  static FlutterAiFace _instance = new FlutterAiFace._();

  static FlutterAiFace get instance => _instance;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  ///百度ai初始化
  Future<bool> aiFaceInit() {
    return _channel
        .invokeMethod('aiFaceInit')
        .then<bool>((isUnInitialize) => isUnInitialize);
  }

  ///释放资源，防止内存溢出
  Future<bool> aiFaceUnInit() {
    return _channel
        .invokeMethod('aiFaceUnInit')
        .then<bool>((isUnInitialize) => isUnInitialize);
  }

  ///人脸识别并采集
  void faceCollect() {
    _channel.invokeMethod('faceCollect');
  }

  ///人脸识别结果监听
  static void aiFaceCallBackListener(void onData(T),
      {bool cancelOnError, void onDone(), Function onError}) {
    _aiFaceCallBackChannel.receiveBroadcastStream().listen(
        (data) {
          if (onData != null) {
            onData(data);
          }
        },
        cancelOnError: cancelOnError,
        onDone: () {
          if (onDone != null) {
            onDone();
          }
        },
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        });
  }
}
