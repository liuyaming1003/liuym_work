package com.samapp.signaturesdk;

import java.io.ByteArrayOutputStream;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import com.samapp.signaturedemo.BuildConfig;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.widget.LinearLayout;

public class SignatureView extends LinearLayout{
	private String filePath = null;            // 签名文件保存路径
	private Bitmap signatureBitmap;            // 签名图片
	private Paint signaturePaint;              // 签名画笔
	private Path signaturePath;                // 签名路径
	private boolean hasSignature;              // 签名是否有效
	private boolean hasDot;                    // 签名是否是点
	private boolean isRunningPaint;            // 是否正在进行签名
	
	public enum SignatureType{
		Signature_OK,                         // 保存成功
		Signature_No_Sign,                    // 还未签名
		Signature_Running,                    // 正在签名中
		Signature_FilePath_Error,             // 文件路径错误
		Signature_Data_Error,                 // 图片数据错误
		Signature_Save_Error                  // 保存图片错误
	}
	
	public SignatureView(Context context) {
		super(context, null);
		
		init();
	}

	public SignatureView(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		init();
	}

	public SignatureView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		
		init();
	}

	@Override
	protected void onConfigurationChanged(Configuration newConfig) {
		// TODO Auto-generated method stub
		super.onConfigurationChanged(newConfig);
	}

	private void init(){

		if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.HONEYCOMB){
			setMotionEventSplittingEnabled(false);
		}else{
			
		}
		
		
		signaturePaint = new Paint();  
		signaturePaint.setStyle(Paint.Style.STROKE);  
		signaturePaint.setAntiAlias(true);//抗锯齿
		signaturePaint.setDither(true);
		signaturePaint.setFilterBitmap(true);
		signaturePaint.setSubpixelText(true);
		signaturePaint.setStrokeJoin(Paint.Join.ROUND);
		signaturePaint.setStrokeCap(Paint.Cap.ROUND);
		signaturePath = new Path();

		//没有绘制签名
		hasSignature = false;

		isRunningPaint = false;
	}

	/**
	 *    设置签名参数
	 *
	 *    @param filePath 签名图片保存的完整路径
	 *    @param panColor 签名笔颜色
	 *    @param panWidth 签名笔宽度
	 */
	public void setSignature(String filePath, int panColor, int panWidth){
		this.filePath = filePath;
		signaturePaint.setStrokeWidth(panWidth);
		signaturePaint.setColor(panColor);
	}

	/**
	 *    设置签名图片保存路径
	 *
	 *    @param filePath 图片路径
	 */
	public void setImagePath(String filePath){
		this.filePath = filePath;
	}

	/**
	 *    设置签名颜色
	 *
	 *    @param color 颜色
	 */
	public void setPanColor(int panColor){
		signaturePaint.setColor(panColor);
	}

	/**
	 *    设置签名宽度
	 *
	 *    @param panWidth 宽度
	 */
	public void setPanWidth(int panWidth){
		signaturePaint.setStrokeWidth(panWidth);
	}

	/**
	 *    保存图片
	 *
	 *    @return Signature_OK 保存成功
	 *            其他          错误
	 *    {@link #SignatureType}
	 */
	public SignatureType saveSignature(){
		if(hasSignature == false){
			return SignatureType.Signature_No_Sign;
		}

		if(isRunningPaint){
			return SignatureType.Signature_Running;
		}

		Bitmap bitmap = createViewBitmap();

		if(filePath == null){
			return SignatureType.Signature_FilePath_Error;
		}
		DLog("filePaht = " + filePath);
		byte[] photoBytes = null;
		String fileStr[] = filePath.split("\\.");
		if(fileStr.length >= 2){
			if(fileStr[fileStr.length - 1].equalsIgnoreCase("jpg")){
				ByteArrayOutputStream baos = new ByteArrayOutputStream();  
				bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos); 
				photoBytes = baos.toByteArray();  
			}else{
				ByteArrayOutputStream baos = new ByteArrayOutputStream();  
				bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos); 
				photoBytes = baos.toByteArray();  
			}
		}else{
			return SignatureType.Signature_FilePath_Error;
		}

		if (photoBytes == null) {  
			return SignatureType.Signature_Data_Error;
		}

		try {
			new FileOutputStream(new File(filePath)).write(photoBytes);
			return SignatureType.Signature_OK;
		} catch (FileNotFoundException e) {
			e.printStackTrace();

		} catch (IOException e) {
			e.printStackTrace();
		}

		return SignatureType.Signature_Save_Error;
	}

	/**
	 *    擦除签名
	 */
	public void eraseSignature(){
		if(isRunningPaint == false){
			signatureBitmap = null;
			signaturePath.reset();
			hasSignature = false;
			invalidate();
		}
	}

	@Override
	protected void onDraw(Canvas canvas) { 
		super.onDraw(canvas); 
		if(signatureBitmap != null){
			canvas.drawBitmap(signatureBitmap, 0, 0, null); 
		}
		canvas.drawPath(signaturePath, signaturePaint); 
	} 

	//mX,mY为绘图的起始坐标
	private float  mX,mY;
	private static final  float TOUCH_TOLERANCE = 4;
	private void touch_start(float x,float y){	
		signaturePath.moveTo(x, y);
		mX = x;
		mY = y;

		DLog("touch_start ......");	

		hasDot = true;
		
		isRunningPaint = true;
	}

	private void touch_move(float x,float y){
		float dx = Math.abs(x - mX);
		float dy = Math.abs(y - mY);
		if(dx >= TOUCH_TOLERANCE || dy >= TOUCH_TOLERANCE){
			signaturePath.quadTo(mX, mY, (x+mX)/2, (y+mY)/2);
			mX = x;
			mY= y;
		}

		hasDot = false;
	}

	private  void touch_up(){
		//signaturePath.lineTo(mX, mY);

		if(hasDot){
			signaturePath.lineTo(mX + 10, mY + 10);
		}

		DLog("touch_up ......", Log.DEBUG);	

		isRunningPaint = false;
		
		signatureBitmap = createViewBitmap();
		signaturePath.reset();
	}

	
	
	public boolean onTouchEvent(MotionEvent  event){
		hasSignature = true;
		float x = event.getX(0);   
		float y = event.getY(0);

		switch(event.getAction()){
		case MotionEvent.ACTION_DOWN:
			touch_start(x, y);
			invalidate();   //刷新ui界面
			break;
		case MotionEvent.ACTION_MOVE:
			touch_move(x, y);
			invalidate();
			break;
		case MotionEvent.ACTION_UP:
			touch_up();
			invalidate();
			break;
		case MotionEvent.ACTION_CANCEL:
			touch_up();
			invalidate();
			break;
		}

		return true;
	}

	private Bitmap createViewBitmap() {
		Bitmap bitmap = Bitmap.createBitmap(getWidth(), getHeight(),
				Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);
		draw(canvas);
		return bitmap;
	}

	private void DLog(String log){
		DLog(log, Log.VERBOSE);
	}

	private void DLog(String log, int logTag){
		if(BuildConfig.DEBUG){
			String tag = "SignatureView";
			switch (logTag) {
			case Log.VERBOSE:
				Log.v(tag, log);
				break;
			case Log.ERROR:
				Log.e(tag, log);
				break;
			case Log.WARN:
				Log.w(tag, log);
				break;
			case Log.DEBUG:
				Log.d(tag, log);
				break;
			case Log.INFO:
				Log.i(tag, log);
				break;
			default:
				Log.v(tag, log);
				break;
			}
		}
	}
}