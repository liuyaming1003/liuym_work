package com.samapp.signaturedemo;

import java.io.File;

import com.samapp.signaturesdk.SignatureView;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Toast;

public class MainActivity extends Activity {

	private SignatureView signatureView;
	private Toast mToast;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		signatureView = (SignatureView) findViewById(R.id.signatureView);

		signatureView.setSignature(Environment.getExternalStorageDirectory() + File.separator + "/sign/signature.png", Color.BLACK, 10);

	}

	public void saveSignature(View v){
		int result = signatureView.saveSignature();
		if(result != 0){
			showMessage("保存失败 " + result);
		}else{
			showMessage("保存成功 ");
		}
	}


	public void eraseSignature(View v){
		signatureView.eraseSignature();
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
