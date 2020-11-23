package com.opun.flutter.flutter_ai_face;

import android.os.Bundle;
import android.view.View;

import com.opun.flutter.flutter_ai_face.faceplatform_ui.CollectionSuccessActivity;
import com.opun.flutter.flutter_ai_face.faceplatform_ui.utils.IntentUtils;


/**
 * 采集成功页面
 * Created by v_liujialu01 on 2020/4/1.
 */

public class CollectionSuccessExpActivity extends CollectionSuccessActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    // 回到首页
    public void onReturnHome(View v) {
        super.onReturnHome(v);
        if ("FaceLivenessExpActivity".equals(mDestroyType)) {
            FlutterAiFacePlugin.destroyActivity("FaceLivenessExpActivity");
        }
        if ("FaceDetectExpActivity".equals(mDestroyType)) {
            FlutterAiFacePlugin.destroyActivity("FaceDetectExpActivity");
        }
        String faceBitmapStr = IntentUtils.getInstance().getBitmap();
        FlutterAiFacePlugin.faceLiveSuccess(faceBitmapStr);
        finish();
    }
}
