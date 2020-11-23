package com.opun.flutter.flutter_ai_face;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;

import com.baidu.idl.face.platform.FaceStatusNewEnum;
import com.baidu.idl.face.platform.model.ImageInfo;
import com.opun.flutter.flutter_ai_face.faceplatform_ui.FaceLivenessActivity;
import com.opun.flutter.flutter_ai_face.faceplatform_ui.utils.IntentUtils;
import com.opun.flutter.flutter_ai_face.faceplatform_ui.widget.TimeoutDialog;

import java.util.HashMap;

public class FaceLivenessExpActivity extends FaceLivenessActivity implements
        TimeoutDialog.OnTimeoutDialogClickListener {

    private TimeoutDialog mTimeoutDialog;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 添加至销毁列表
        FlutterAiFacePlugin.addDestroyActivity(FaceLivenessExpActivity.this,
                "FaceLivenessExpActivity");
    }

    @Override
    public void onLivenessCompletion(FaceStatusNewEnum status, String message,
                                     HashMap<String, ImageInfo> base64ImageCropMap,
                                     HashMap<String, ImageInfo> base64ImageSrcMap, int currentLivenessCount) {
        super.onLivenessCompletion(status, message, base64ImageCropMap, base64ImageSrcMap, currentLivenessCount);
        if (status == FaceStatusNewEnum.OK && mIsCompletion) {
            // showMessageDialog("活体检测", "检测成功");
            IntentUtils.getInstance().setBitmap(mBmpStr);
            Intent intent = new Intent(FaceLivenessExpActivity.this,
                    CollectionSuccessExpActivity.class);
            intent.putExtra("destroyType", "FaceLivenessExpActivity");
            startActivity(intent);
        } else if (status == FaceStatusNewEnum.DetectRemindCodeTimeout) {
            if (mViewBg != null) {
                mViewBg.setVisibility(View.VISIBLE);
            }
            showMessageDialog();
        }
    }

    private void showMessageDialog() {
        mTimeoutDialog = new TimeoutDialog(this);
        mTimeoutDialog.setDialogListener(this);
        mTimeoutDialog.setCanceledOnTouchOutside(false);
        mTimeoutDialog.setCancelable(false);
        mTimeoutDialog.show();
        onPause();
    }

    @Override
    public void finish() {
        super.finish();
    }

    @Override
    public void onRecollect() {
        if (mTimeoutDialog != null) {
            mTimeoutDialog.dismiss();
        }
        if (mViewBg != null) {
            mViewBg.setVisibility(View.GONE);
        }
        onResume();
    }

    @Override
    public void onReturn() {
        if (mTimeoutDialog != null) {
            mTimeoutDialog.dismiss();
        }
        finish();
    }
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK){
            return true;
        }
        if (keyCode == KeyEvent.KEYCODE_HOME){
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
