package com.samapp.signaturedemo;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

public class SignatureImageActivity extends Activity {
	private ImageView imageView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);

		setContentView(R.layout.signature_image_activity);

		//	    得到跳转到该Activity的Intent对象
		Intent intent = getIntent();
		String filePath = intent.getStringExtra("FilePath");

		if(filePath != null && filePath.length() != 0){
			Bitmap image = BitmapFactory.decodeFile(filePath);
			if(image != null){
				imageView = (ImageView) findViewById(R.id.imageView);
				imageView.setImageBitmap(image);

				TextView textView = (TextView) findViewById(R.id.textView);
				
				String fileSize = String.format("%.2f kb", getFileSize(filePath) / 1024.0);
				
				String msg = "fileSize = " + fileSize + ", size(" + image.getWidth() + ", " + image.getHeight() + ")";

				textView.setText(msg);
			}
		}
	}

	private double getFileSize(String filePath){
		File file=new File(filePath);
		long blockSize=0;

		if(!file.isDirectory()){
			if(file.exists()){
				try {
					FileInputStream fis = new FileInputStream(file);
					blockSize = fis.available();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		return blockSize;
	}
}
