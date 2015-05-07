package com.samapp.signaturesdk;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.R;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;

public class SignatureView extends LinearLayout{
	private String filePath = null;
	private Bitmap signatureBitmap;
	private Paint signaturePaint;
	private Path signaturePath;  
	private boolean hasSignature;

	private boolean hasDot;

	public SignatureView(Context context) {
		this(context, null);
	}

	public SignatureView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public SignatureView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);

		setMotionEventSplittingEnabled(false);


		init();
	}

	@Override
	protected void onConfigurationChanged(Configuration newConfig) {
		// TODO Auto-generated method stub
		super.onConfigurationChanged(newConfig);

		System.out.println("onConfigurationChanged");

		if(signatureBitmap != null){
			signatureBitmap.setWidth(getWidth());
			signatureBitmap.setHeight(getHeight());
		}
	}

	private void init(){

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
	 *    @return 0  成功 其他失败
	 *            -1 没有签名
	 *            -2 文件路径错误
	 *            -3 数据错误
	 *            -4 保存图片错误
	 */
	public int saveSignature(){
		if(hasSignature == false){
			return -1;
		}

		Bitmap bitmap = createViewBitmap();

		if(filePath == null){
			return -2;
		}
		System.out.println("filePaht = " + filePath);
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
			return -2;
		}

		if (photoBytes == null) {  
			return -3;
		}

		try {
			new FileOutputStream(new File(filePath)).write(photoBytes);
			return 0;
		} catch (FileNotFoundException e) {
			e.printStackTrace();

		} catch (IOException e) {
			e.printStackTrace();
		}

		return -4;
	}

	/**
	 *    擦除签名
	 */
	public void eraseSignature(){
		signatureBitmap = null;
		signaturePath.reset();
		hasSignature = false;
		invalidate();
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

		hasDot = true;
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

		signatureBitmap = createViewBitmap();
		signaturePath.reset();
	}

	public boolean onTouchEvent(MotionEvent  event){
		hasSignature = true;
		float x = event.getX();   
		float y = event.getY();

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
}