//
//  ShareCommon.h
//  thridapi
//
//  Created by liuym on 15/6/26.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum{
    ShareCommonType_None = 10000,
    ShareCommonType_QQ,
    ShareCommonType_WX,
}ShareCommonType;

#define WX_INSTALL @"WX"  //微信
#define QQ_INSTALL @"QQ"  //QQ

@interface ShareCommon : NSObject

+ (ShareCommon *)getInstance;

/**
 *    注册第三方sdk
 */
+ (void)shareRegister;

/**
 *    处理第三方sdk回调
 *
 *    @param url
 *
 *    @return
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *    获取app是否安装
 *
 *    @return
 */
+ (NSDictionary *)getSupportShareApp;

/**
 *    获取当前登陆类型
 *
 *    @return @see ShareCommonType
 */
- (int)getCommonType;

/**
 *    判断登陆是否有效, 需要登录的时候调用
 *
 *    @return YES 有效
 *            NO  无效,需要重新登陆
 */
- (BOOL)isSessionValid;

/**
 *    第三方登陆接口
 *
 *    @param type           类型
 *    @param array          授权信息
 *    @param callBack       回调接口
 */
- (void)logon:(ShareCommonType)type viewController:(UIViewController *)viewController permission:(NSArray *)array callBack:(void (^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    第三方登出接口
 *
 *    @param type     类型
 *    @param callBack 回调接口
 */
- (void)logout:(void(^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    获取用户信息
 *
 *    @param callBack 回调
 */
- (void)getUserInfo:(void(^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    获取用户唯一标识
 */
- (NSString *)getOpneId;

@end
