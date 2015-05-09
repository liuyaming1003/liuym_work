//
//  SignatureView.h
//
//  Created by liuym on 15-04-28.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    Signature_OK,                         // 保存成功
    Signature_No_Sign,                    // 还未签名
    Signature_Running,                    // 正在签名中
    Signature_FilePath_Error,             // 文件路径错误
    Signature_Data_Error,                 // 图片数据错误
    Signature_Save_Error                  // 保存图片错误
}SignatureType;

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
- (void)setSignature:(NSString *)filePath panColor:(UIColor *)color panWidth:(CGFloat )width;

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
- (void)setPanWidth:(CGFloat )width;

/**
 *    保存图片
 *
 *    @return Signature_OK 成功
 *            其他          失败
 *    @see {SignatureType}
 */
- (SignatureType ) saveSignature;

/**
 *    擦除签名
 */
- (void) eraseSignature;

@end
