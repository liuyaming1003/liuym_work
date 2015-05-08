package com.samapp.signaturetest;

import java.io.File;

import com.samapp.signaturedemo.R;
import com.samapp.signaturesdk.SignatureView;
import com.samapp.signaturesdk.SignatureView.SignatureType;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Toast;

public class SignatureTest extends Activity {

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
		SignatureType result = signatureView.saveSignature();
		if(result != SignatureType.Signature_OK){
			showMessage("保存失败 " + result);
		}else{
			showMessage("保存成功 ");
		}
	}


	public void eraseSignature(View v){
		signatureView.eraseSignature();
	}
	
	public void previewSignature(View v){
		
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
