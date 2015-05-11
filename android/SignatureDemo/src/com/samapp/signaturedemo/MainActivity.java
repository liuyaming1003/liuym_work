package com.samapp.signaturedemo;

import com.samapp.signaturesdk.SignatureView;
import com.samapp.signaturesdk.SignatureView.SignatureType;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.Toast;

public class MainActivity extends Activity {
	private SignatureView signatureView;
	private String filePath = null;
	private Toast mToast;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		signatureView = (SignatureView) findViewById(R.id.signatureView);

		//内置卡路径
		//filePath = getCacheDir() + "/signature.png";

		//外置卡路径
		filePath = getExternalCacheDir() + "/signature.jpg";

		DisplayMetrics metric = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(metric);
		int width = metric.widthPixels;  // 屏幕宽度（像素）
		int height = metric.heightPixels;  // 屏幕高度（像素）
		float density = metric.density;  // 屏幕密度（0.75 / 1.0 / 1.5）
		int densityDpi = metric.densityDpi;  // 屏幕密度DPI（120 / 160 / 240）

		System.out.println("(" + width + ", " + height + ") " + "密度 = " + density + " dpi = " + densityDpi);

		showMessage("(" + width + ", " + height + ") " + "密度 = " + density + " dpi = " + densityDpi);
		//参数说明
		/**
		 *    设置签名参数
		 *
		 *    @param filePath 签名图片保存的完整路径
		 *    @param panColor 签名笔颜色
		 *    @param panWidth 签名笔宽度
		 *    @param imageScale 图片缩放 0 < imageScale <= 1.0
		 *    @param imageCompressionQuality jpg压缩比例  0 < imageCompressionQuality <= 1.0f
		 */
		signatureView.setSignature(filePath, Color.BLACK, 4, 0.5f, 0.5f);
	}

	public void saveSignature(View v){
		SignatureType result = signatureView.saveSignature();

		String message = "";
		switch (result) {
		case Signature_OK:
			message = "保存成功";
			break;
		case Signature_No_Sign:
			message = "未签名";
			break;
		case Signature_Running:
			message = "正在签名";
			break;
		case Signature_FilePath_Error:
			message = "路径错误";
			break;
		case Signature_Data_Error:
			message = "数据错误";
			break;
		case Signature_Save_Error:
			message = "保存文件错误";
			break;
		default:
			break;
		}
		showMessage(message);
	}

	public void eraseSignature(View v){
		signatureView.eraseSignature();
	}

	public void previewSignature(View v){
		Intent intent = new Intent();
		intent.setClass(this, SignatureImageActivity.class);

		intent.putExtra("FilePath", filePath);

		startActivity(intent);
	}

	protected void showMessage(String msg){
		if(mToast != null){
			mToast.setText(msg);
		}else{
			mToast = Toast.makeText(this, msg, Toast.LENGTH_SHORT);
		}
		mToast.show();
	}
}
