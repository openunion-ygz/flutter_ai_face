package com.opun.flutter.flutter_ai_face;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;


import com.baidu.idl.face.platform.FaceConfig;
import com.baidu.idl.face.platform.FaceEnvironment;
import com.baidu.idl.face.platform.FaceSDKManager;
import com.baidu.idl.face.platform.LivenessTypeEnum;
import com.baidu.idl.face.platform.listener.IInitCallback;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * FlutterAiFacePlugin
 */
public class FlutterAiFacePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    public static final String TAG = FlutterAiFacePlugin.class.getSimpleName();
    private MethodChannel channel;
    private static EventChannel.EventSink eventSink;
    private Context mContext;
    private Activity activity;
    public static final int PERMISSION_REQUEST_CODE = 999;
    // 动作活体条目集合
    public static List<LivenessTypeEnum> livenessList = new ArrayList<>();
    // 活体随机开关
    public static boolean isLivenessRandom = false;
    // 语音播报开关
    public static boolean isOpenSound = true;
    // 活体检测开关
    public static boolean isActionLive = true;
    private boolean mIsInitSuccess = false;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_ai_face");
        channel.setMethodCallHandler(this);
        //*****插件的使用场景不一样，入口也对应不一样，因此mContext对象的获取需要在所有入口都获取，才能保证mContext不为null****
        mContext = flutterPluginBinding.getApplicationContext();
        //1.渠道名
        EventChannel eventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "aiFaceCallBackChannel");
        EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
                //2.发射器
                eventSink = sink;
            }

            @Override
            public void onCancel(Object o) {
//                eventSink = null;
            }
        };
        eventChannel.setStreamHandler(streamHandler);
    }

    // flutter sdk >= 1.12.x 执行的插件加载方法
    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }


    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_ai_face");
        FlutterAiFacePlugin aiFacePlugin = new FlutterAiFacePlugin();
        channel.setMethodCallHandler(aiFacePlugin);
        //1.渠道名
        EventChannel eventChannel = new EventChannel(registrar.messenger(), "aiFaceCallBackChannel");
        EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
                //2.发射器
                eventSink = sink;
            }

            @Override
            public void onCancel(Object o) {
//                eventSink = null;
            }
        };
        eventChannel.setStreamHandler(streamHandler);
        //*****插件的使用场景不一样，入口也对应不一样，因此mContext对象的获取需要在所有入口都获取，才能保证mContext不为null****
        if (registrar.activeContext() instanceof Activity) {
            aiFacePlugin.setActivity(registrar);
        }
    }

    private void setActivity(Registrar registrar) {
        this.activity = registrar.activity();
        this.mContext = registrar.context();
        registrar.addRequestPermissionsResultListener(this);
    }

    private Result mResult;
    private MethodCall mCall;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        mResult = result;
        mCall = call;
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("aiFaceInit")) {
            aiFaceInit();
        } else if (call.method.equals("faceCollect")) {
            faceCollect();
        } else if (call.method.equals("aiFaceUnInit")) {
            aiFaceRelease();
        } else {
            result.notImplemented();
        }
    }

    private void aiFaceInit() {
        if (mIsInitSuccess) {
            initLicense();
            addActionLive();
        } else {
            requestPermissions(PERMISSION_REQUEST_CODE);
        }

    }

    //开始采集人脸
    private void faceCollect() {
        if (mIsInitSuccess) {
            if (isActionLive) {
                Intent intent = new Intent(mContext, FaceLivenessExpActivity.class);
                activity.startActivity(intent);
            }
        } else {
            showToast("初始化中，请稍后");
        }

    }

    //释放资源，防止内存溢出
    private void aiFaceRelease() {
        eventSink.endOfStream();
        FaceSDKManager.release();
    }

    protected static void faceLiveSuccess(String faceBitmapStr) {
        eventSink.success(faceBitmapStr);
    }

    private void showToast(String msg) {
        Toast toast = Toast.makeText(mContext, "",
                Toast.LENGTH_SHORT);
        toast.setText(msg);
        toast.show();
    }

    // 请求权限
    public void requestPermissions(int requestCode) {
        try {
            if (Build.VERSION.SDK_INT >= 23) {
                ArrayList<String> requestPerssionArr = new ArrayList<>();
                int hasCamrea = activity.checkSelfPermission(Manifest.permission.CAMERA);
                if (hasCamrea != PackageManager.PERMISSION_GRANTED) {
                    requestPerssionArr.add(Manifest.permission.CAMERA);
                }

                int hasSdcardRead = activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE);
                if (hasSdcardRead != PackageManager.PERMISSION_GRANTED) {
                    requestPerssionArr.add(Manifest.permission.READ_EXTERNAL_STORAGE);
                }

                int hasSdcardWrite = activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE);
                if (hasSdcardWrite != PackageManager.PERMISSION_GRANTED) {
                    requestPerssionArr.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
                }
                // 是否应该显示权限请求
                if (requestPerssionArr.size() >= 1) {
                    mIsInitSuccess = false;
                    String[] requestArray = new String[requestPerssionArr.size()];
                    for (int i = 0; i < requestArray.length; i++) {
                        requestArray[i] = requestPerssionArr.get(i);
                    }
                    activity.requestPermissions(requestArray, requestCode);
                } else {
                    mIsInitSuccess = true;
                    aiFaceInit();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private void initLicense() {
        setFaceConfig();
        // 为了android和ios 区分授权，appId=appname_face_android ,其中appname为申请sdk时的应用名
        // 应用上下文
        // 申请License取得的APPID
        // assets目录下License文件名
        FaceSDKManager.getInstance().initialize(activity, "cafa-face-android",
                "idl-license.face-android", new IInitCallback() {
                    @Override
                    public void initSuccess() {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.e(TAG, "===> 初始化成功");
                                mIsInitSuccess = true;
                                mResult.success(true);
                                showToast("初始化成功");
                            }
                        });
                    }

                    @Override
                    public void initFailure(final int errCode, final String errMsg) {
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.e(TAG, "初始化失败 ===> " + errCode + " " + errMsg);
                                mIsInitSuccess = false;
                                mResult.success(false);
                                showToast("初始化失败");
                            }
                        });
                    }
                });
    }

    /**
     * 参数配置方法
     */
    private void setFaceConfig() {
        FaceConfig config = FaceSDKManager.getInstance().getFaceConfig();
        // SDK初始化已经设置完默认参数（推荐参数），也可以根据实际需求进行数值调整
        // 设置可检测的最小人脸阈值
        config.setMinFaceSize(FaceEnvironment.VALUE_MIN_FACE_SIZE);
        // 设置可检测到人脸的阈值
        config.setNotFaceValue(FaceEnvironment.VALUE_NOT_FACE_THRESHOLD);
        // 设置模糊度阈值
        config.setBlurnessValue(FaceEnvironment.VALUE_BLURNESS);
        // 设置光照阈值（范围0-255）
        config.setBrightnessValue(FaceEnvironment.VALUE_BRIGHTNESS);
        // 设置遮挡阈值
        config.setOcclusionValue(FaceEnvironment.VALUE_OCCLUSION);
        // 设置人脸姿态角阈值
        config.setHeadPitchValue(FaceEnvironment.VALUE_HEAD_PITCH);
        config.setHeadYawValue(FaceEnvironment.VALUE_HEAD_YAW);
        // 设置闭眼阈值
        config.setEyeClosedValue(FaceEnvironment.VALUE_CLOSE_EYES);
        // 设置图片缓存数量
        config.setCacheImageNum(FaceEnvironment.VALUE_CACHE_IMAGE_NUM);
        // 设置口罩判断开关以及口罩阈值
        config.setOpenMask(FaceEnvironment.VALUE_OPEN_MASK);
        config.setMaskValue(FaceEnvironment.VALUE_MASK_THRESHOLD);
        // 设置活体动作，通过设置list，LivenessTypeEunm.Eye, LivenessTypeEunm.Mouth,
        // LivenessTypeEunm.HeadUp, LivenessTypeEunm.HeadDown, LivenessTypeEunm.HeadLeft,
        // LivenessTypeEunm.HeadRight, LivenessTypeEunm.HeadLeftOrRight
        config.setLivenessTypeList(livenessList);
        // 设置动作活体是否随机
        config.setLivenessRandom(isLivenessRandom);
        // 设置开启提示音
        config.setSound(isOpenSound);
        // 原图缩放系数
        config.setScale(FaceEnvironment.VALUE_SCALE);
        // 抠图高的设定，为了保证好的抠图效果，我们要求高宽比是4：3，所以会在内部进行计算，只需要传入高即可
        config.setCropHeight(FaceEnvironment.VALUE_CROP_HEIGHT);
        // 抠图人脸框与背景比例
        config.setEnlargeRatio(FaceEnvironment.VALUE_CROP_ENLARGERATIO);
        // 加密类型，0：Base64加密，上传时image_sec传false；1：百度加密文件加密，上传时image_sec传true
        config.setSecType(FaceEnvironment.VALUE_SEC_TYPE);
        FaceSDKManager.getInstance().setFaceConfig(config);
    }

    private void addActionLive() {
        if (mCall != null) {
            //是否自定义验证动作
            boolean isCustomActionLive = Boolean.parseBoolean((String) mCall.argument("isCustomActionLive"));
            if (isCustomActionLive) {
                boolean isAddActionTypeEye = Boolean.parseBoolean((String) mCall.argument("isAddActionTypeEye"));
                boolean isAddActionTypeMouth = Boolean.parseBoolean((String) mCall.argument("isAddActionTypeMouth"));
                boolean isAddActionTypeHeadRight = Boolean.parseBoolean((String) mCall.argument("isAddActionTypeHeadRight"));
                boolean isAddActonTypeHeadLeft = Boolean.parseBoolean((String) mCall.argument("isAddActonTypeHeadLeft"));
                boolean isAddActionTypeHeadUp = Boolean.parseBoolean((String) mCall.argument("isAddActionTypeHeadUp"));
                boolean isAddActionHeadDown = Boolean.parseBoolean((String) mCall.argument("isAddActionHeadDown"));
                boolean isAddActionHeadLeftOrRight = Boolean.parseBoolean((String) mCall.argument("isAddActionHeadLeftOrRight"));
                livenessList.clear();
                if (isAddActionTypeEye) {
                    livenessList.add(LivenessTypeEnum.Eye);
                }
                if (isAddActionTypeMouth) {
                    livenessList.add(LivenessTypeEnum.Mouth);
                }
                if (isAddActionTypeHeadRight) {
                    livenessList.add(LivenessTypeEnum.HeadRight);
                }
                if (isAddActonTypeHeadLeft) {
                    livenessList.add(LivenessTypeEnum.HeadLeft);
                }
                if (isAddActionTypeHeadUp) {
                    livenessList.add(LivenessTypeEnum.HeadUp);
                }
                if (isAddActionHeadDown) {
                    livenessList.add(LivenessTypeEnum.HeadDown);
                }
                if (isAddActionHeadLeftOrRight) {
                    livenessList.add(LivenessTypeEnum.HeadLeftOrRight);
                }

                boolean isByOrder = Boolean.parseBoolean((String) mCall.argument("isByOrder"));
                if (!isByOrder) {
                    Collections.shuffle(livenessList);
                }

            } else {
                //默认情况下没有"向左转头"动作，同时验证动作随机
                livenessList.clear();
                livenessList.add(LivenessTypeEnum.Eye);
                livenessList.add(LivenessTypeEnum.Mouth);
                livenessList.add(LivenessTypeEnum.HeadRight);
//                livenessList.add(LivenessTypeEnum.HeadLeft);
                livenessList.add(LivenessTypeEnum.HeadUp);
                livenessList.add(LivenessTypeEnum.HeadDown);
                livenessList.add(LivenessTypeEnum.HeadLeftOrRight);
                //随机排列
                Collections.shuffle(livenessList);

            }
        }

    }

    private static Map<String, Activity> destroyMap = new HashMap<>();

    /**
     * 添加到销毁队列
     *
     * @param activity 要销毁的activity
     */
    public static void addDestroyActivity(Activity activity, String activityName) {
        destroyMap.put(activityName, activity);
    }

    /**
     * 销毁指定Activity
     */
    public static void destroyActivity(String activityName) {
        Set<String> keySet = destroyMap.keySet();
        for (String key : keySet) {
            if (key.equals(activityName)) {
                destroyMap.get(key).finish();
            }
        }
    }


    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        boolean flag = false;
        List<Boolean> permissionRefuseFlagList = new ArrayList<>();
        for (int i = 0; i < permissions.length; i++) {
            if (PackageManager.PERMISSION_GRANTED != grantResults[i]) {
                flag = true;
                permissionRefuseFlagList.add(false);
            }
        }
        if (permissionRefuseFlagList.size() > 0) {
            mIsInitSuccess = false;
            aiFaceInit();
        } else {
            mIsInitSuccess = true;
            aiFaceInit();
        }
        return false;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
