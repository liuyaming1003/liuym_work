//
//  SignView.h
//  imate
//
//  Created by liuym on 13-12-19.
//
//

#import <UIKit/UIKit.h>

/**
 *    签名
 * @note 图片保存大小与 View的size一致
 */
@interface SignatureView : UIView

/**
 *    设置签名参数
 *
 *    @param filePath 签名图片保存的完整路径
 *    @param color    签名笔颜色
 *    @param panWidth 签名笔宽度
 */
- (void)setSignature:(NSString *)filePath panColor:(UIColor *)color panWidth:(int )panWidth;

/**
 *    设置签名图片保存路径
 *
 *    @param filePath 图片路径
 */
- (void)setImagePath:(NSString *)filePath;

/**
 *    设置签名颜色
 *
 *    @param color 颜色
 */
- (void)setPanColor:(UIColor *)color;

/**
 *    设置签名宽度
 *
 *    @param panWidth 宽度
 */
- (void)setPanWidth:(int )panWidth;

/**
 *    保存图片
 *
 *    @return 0 成功 其他失败
 */
- (int) saveSignature;

/**
 *    擦出签名
 */
- (void) eraseSignature;

@end
