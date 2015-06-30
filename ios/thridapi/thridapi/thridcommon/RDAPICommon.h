//
//  RDAPICommon.h
//  thridapi
//
//  Created by liuym on 15/6/26.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum{
    RDAPICommonType_QQ = 1000,
    RDAPICommonType_WX,
}RDAPICommonType;

@interface RDAPICommon : NSObject

+ (RDAPICommon *)getInstance;

/**
 *    注册第三方sdk
 */
+ (void)rdapiRegister;

/**
 *    处理第三方sdk回调
 *
 *    @param url
 *
 *    @return
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *    获取当前登陆类型
 *
 *    @return @see RDAPICommonType
 */
- (int)getCommonType;

/**
 *    判断登陆是否有效, 需要登录的时候调用
 *
 *    @return YES 有效
 *            NO  无效,需要重新登陆
 */
- (BOOL)rdapiLogonValid;

/**
 *    第三方登陆接口
 *
 *    @param type           类型
 *    @param array          授权信息
 *    @param callBack       回调接口
 */
- (void)rdapiLogon:(RDAPICommonType)type permission:(NSArray *)array callBack:(void (^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    第三方登出接口
 *
 *    @param type     类型
 *    @param callBack 回调接口
 */
- (void)rdapiLogout:(void(^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    获取用户信息
 *
 *    @param callBack 回调
 */
- (void)rdapiGetUserInfo:(void(^)(BOOL isSuccess, id object, NSError *error))callBack;

/**
 *    获取用户唯一标识
 */
- (NSString *)rdapiGetOpneId;

@end
