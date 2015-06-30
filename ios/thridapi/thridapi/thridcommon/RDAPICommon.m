//
//  RDAPICommon.m
//  thridapi
//
//  Created by liuym on 15/6/26.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import "RDAPICommon.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"

#define WXValidSec   30 * 24 * 60 * 60  //一天的秒数

#define LOGON_TYPE   @"logon_type"

#define WX_APPID     @"wxd930ea5d5a258f4f"
#define WX_APPSECRET @"db426a9829e4b49a0dcac7b4162da6b6"
#define WX_LOGON     @"wx_logon"

#define QQ_LOGON     @"qq_logon"
#define QQ_APPID     @"1104738836"


#define LOGON_Fail     -1
#define LOGON_Cancel   -2
#define LOGON_NetError -3
#define LOGON_Reject   -4
#define LOGON_inValid  -5


#define Error_Data    -101

static RDAPICommon *sg_instance = nil;

@interface RDAPICommon()<TencentLoginDelegate, TencentSessionDelegate, WXApiDelegate>

@property (strong, nonatomic) TencentOAuth *qqOAuth;
@property (strong) void (^callBack)(BOOL isSuccess, id object, NSError *error);

@end

@implementation RDAPICommon

- (id)init
{
    self = [super init];
    if(self){
        self.qqOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APPID andDelegate:self];
        
        NSDictionary *dict = [self getDict:QQ_LOGON];
        if(dict){
            [self.qqOAuth setAccessToken:[dict objectForKey:@"access_token"]];
            [self.qqOAuth setOpenId:[dict objectForKey:@"openid"]];
            [self.qqOAuth setExpirationDate:
             [NSDate dateWithTimeIntervalSince1970:
              [[dict objectForKey:@"refresh_token_time"] intValue] ]];
        }
    }
    return self;
}

#pragma mark common api

- (int)getCommonType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:LOGON_TYPE];
}

- (void)setCommonType:(RDAPICommonType)type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:type forKey:LOGON_TYPE];
    [userDefaults synchronize];
}

- (void)clear
{
    [self removeKey:WX_LOGON];
    [self removeKey:QQ_LOGON];
    [self removeKey:LOGON_TYPE];
}

- (void)saveDict:(NSDictionary *)dict key:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    @try {
        [userDefaults setObject:dict forKey:key];
        [userDefaults synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"Save Error");
    }
    @finally {
        
    }
}

- (NSDictionary *)getDict:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults dictionaryForKey:key];
    return dict;
}

- (void)removeKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

//秒
- (int)getCurrentTime
{
    return [[NSDate date] timeIntervalSince1970];
}

/**
 *    时间是否失效, 秒为单位
 *
 *    @param time            记录时间  秒
 *    @param expirationTime  有效期    秒
 *
 *    @return YES 有效
 *            NO  失效
 */
- (BOOL)isValidTime:(double)recoveTime expiration:(double)expirationTime
{
    double now_time = [self getCurrentTime];
    if(now_time - recoveTime > expirationTime){
        return NO;
    }
    return YES;
}

- (void)handleCallBack:(BOOL )isSuccess object:(id)object errorCode:(int)errorCode
{
    if(self.callBack){
        if(isSuccess){
            self.callBack(YES, object, nil);
        }else{
            self.callBack(isSuccess, object, [NSError errorWithDomain:[self error:errorCode] code:errorCode userInfo:nil]);
        }
    }
}

- (void)handleSuccess:(id)object
{
    [self handleCallBack:YES object:object errorCode:0];
}

- (void)handleFail:(int)errorCode
{
    [self handleCallBack:NO object:nil errorCode:errorCode];
}

- (NSString *)error:(int )errorCode
{
    switch (errorCode) {
        case LOGON_Fail:
            return @"用户登陆失败";
        case LOGON_Cancel:
            return @"用户取消";
        case LOGON_NetError:
            return @"网络连接错误";
        case LOGON_Reject:
            return @"用户拒绝";
        case LOGON_inValid:
            return @"登陆失效";
        default:
            return @"其他错误";
    }
}

#pragma mark api open

+ (RDAPICommon *)getInstance
{
    if(sg_instance == nil){
        sg_instance = [[RDAPICommon alloc] init];
    }
    return sg_instance;
}

+ (void)rdapiRegister
{
    [WXApi registerApp:WX_APPID];
}

+ (BOOL)handleOpenUrl:(NSURL *)url
{
    NSString *string =[url absoluteString];
    if([string hasPrefix:@"tencent"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:sg_instance];
    }else{
        return YES;
    }
}

- (BOOL)rdapiLogonValid
{
    BOOL isValid = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int type = [userDefaults integerForKey:LOGON_TYPE];
    switch (type) {
        case RDAPICommonType_QQ:
        {
            NSDictionary *dict = [self getDict:QQ_LOGON];
            if(dict){
                int refresh_token_time = [[dict objectForKey:@"refresh_token_time"] intValue];
                if([self isValidTime:refresh_token_time expiration:0.0]){
                    isValid = YES;
                }
            }
        }
            break;
        case RDAPICommonType_WX:
        {
            NSDictionary *dict = [self getDict:WX_LOGON];
            if(dict){
                int refresh_token = [[dict objectForKey:@"refresh_token_time"] intValue];
                //30天的毫秒数
                double refresh_token_expires = WXValidSec;
                if([self isValidTime:refresh_token expiration:refresh_token_expires]){
                    isValid = YES;
                }
            }
        }
            break;
        default:
            break;
    }
    return isValid;
}

- (void)rdapiLogon:(RDAPICommonType)type permission:(NSArray *)array callBack:(void (^)(BOOL, id, NSError *))callBack
{
    [self setCommonType:type];
    self.callBack = callBack;
    switch (type) {
        case RDAPICommonType_QQ:
        {
            if(self.qqOAuth == nil){
                self.qqOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APPID andDelegate:self];
            }
            [self.qqOAuth authorize:array];
        }
            break;
        case RDAPICommonType_WX:
        {
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.scope = [array componentsJoinedByString:@","];
            req.state = @"mtestm";
            [WXApi sendAuthReq:req viewController:nil delegate:self];
        }
            break;
        default:
            break;
    }
    
}

- (void)rdapiLogout:(void (^)(BOOL, id, NSError *))callBack
{
    self.callBack = callBack;
    switch ([self getCommonType]) {
        case RDAPICommonType_QQ:
        {
            if(self.qqOAuth){
                [self.qqOAuth logout:self];
            }
        }
            break;
        case RDAPICommonType_WX:
        {
            [self handleSuccess:nil];
            break;
        }
        default:
            break;
    }
    [self clear];
}

- (void)rdapiGetUserInfo:(void (^)(BOOL, id, NSError *))callBack
{
    self.callBack = callBack;
    switch ([self getCommonType]) {
        case RDAPICommonType_QQ:
        {
            if(self.qqOAuth){
                if(![self.qqOAuth getUserInfo]){
                    //获取失败,需要重新登陆
                    [self clear];
                    [self handleFail:LOGON_inValid];
                }
            }
        }
            break;
        case RDAPICommonType_WX:
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int ret = [self refreshToken];
                if(ret == 0){
                    NSDictionary *dict = [self getDict:WX_LOGON];
                    NSString *urlStr = [NSString stringWithFormat:
                                        @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",
                                        [dict objectForKey:@"access_token"],
                                        [dict objectForKey:@"openid"]];
                    
                    dict = [self syncHttpRequest:urlStr method:@"GET" data:nil];
                    ret = [[dict objectForKey:@"errcode"] intValue];
                    if(ret == 0){
                        [self handleSuccess:dict];
                    }else{
                        //获取错误
                        [self handleFail:ret];
                    }
                }else{
                    [self handleFail:ret];
                }
            });
            break;
        }
        default:
            break;
    }
}

- (NSString *)rdapiGetOpneId
{
    NSString *openId = nil;
    switch ([self getCommonType]) {
        case RDAPICommonType_QQ:
        {
            NSDictionary *dict = [self getDict:QQ_LOGON];
            if(dict){
                openId = [dict objectForKey:@"openid"];
            }
        }
            break;
        case RDAPICommonType_WX:
        {
            NSDictionary *dict = [self getDict:WX_LOGON];
            if(dict){
                openId = [dict objectForKey:@"openid"];
            }
        }
            break;
        default:
            break;
    }
    
    return openId;
}

#pragma mark QQ Delegate

- (void)tencentDidLogin
{
    if(self.qqOAuth.accessToken && 0 != [self.qqOAuth.accessToken length]){
        //登陆完成后需要保存数据
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.qqOAuth.accessToken,
                              @"access_token",
                              self.qqOAuth.openId,
                              @"openid",
                              [NSNumber numberWithInt:[self.qqOAuth.expirationDate timeIntervalSince1970]],
                              @"refresh_token_time", nil];
        
        [self saveDict:dict key:QQ_LOGON];
        [self handleSuccess:dict];
    }else{
        [self handleFail:LOGON_Fail];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if(cancelled){
        [self handleFail:LOGON_Cancel];
    }
}

- (void)tencentDidNotNetWork
{
    [self handleFail:LOGON_NetError];
}

- (void)tencentDidLogout
{
    self.qqOAuth = nil;
    [self handleSuccess:nil];
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == 0) {
        [self handleSuccess:response.jsonResponse];
    }else{
        [self handleFail:response.retCode];
    }
}

#pragma mark WX Delegate
- (void)onReq:(BaseReq *)req
{
    NSLog(@"onReq = %@", req);
}

- (void)onResp:(BaseResp *)resp
{
    NSLog(@"onResp = %@", resp);
    if([resp isKindOfClass:[SendAuthResp class]]){
        //登陆授权
        SendAuthResp *tmp = (SendAuthResp *)resp;
        switch (tmp.errCode) {
            case 0:
            {
                //成功
                NSLog(@"%@, %@, %@, %@", tmp.code, tmp.state, tmp.lang, tmp.country);
                
                //第一次获取token
                NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", WX_APPID, WX_APPSECRET, tmp.code];
                NSDictionary *dict = [self syncHttpRequest:urlStr method:@"GET" data:nil];
                if(dict){
                    NSString *token = [dict objectForKey:@"access_token"];
                    if(token){
                        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        [mutableDict setValue:[NSNumber numberWithInt:[self getCurrentTime]] forKey:@"access_token_time"];
                        [mutableDict setValue:[NSNumber numberWithInt:[self getCurrentTime]] forKey:@"refresh_token_time"];
                        [self saveDict:mutableDict key:WX_LOGON];
                        [self handleSuccess:nil];
                    }else{
                        //获取错误
                        [self handleFail:[[dict objectForKey:@"errcode"] intValue]];
                    }
                }
                break;
            }
            case -2:
                //取消
                [self handleFail:LOGON_Cancel];
                break;
            case -4:
                [self handleFail:LOGON_Reject];
                //用户拒绝授权
                break;
            default:
                break;
        }
    }
}



/**
 *    获取微信accesss_token,第一次获取需要传code进入,刷新可以为nil
 *
 *    @param url   token url
 *    @param token 返回的token
 *
 *    @return 0   成功
 *            其他 失败
 */
- (int )refreshToken
{
    int ret = 0;
    NSDictionary *dict = [self getDict:WX_LOGON];
    if(dict != nil){
        int token_time = [[dict objectForKey:@"access_token_time"] intValue];
        int expires_in = [[dict objectForKey:@"expires_in"] intValue];
        
        if(![self isValidTime:token_time expiration:expires_in]){
            //判断刷新token有效期
            int refresh_token = [[dict objectForKey:@"refresh_token_time"] intValue];
            //30天的毫秒数
            double refresh_token_expires = WXValidSec;
            if(![self isValidTime:refresh_token expiration:refresh_token_expires]){
                //失效
                return LOGON_inValid;
            }
            NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", WX_APPID, [dict objectForKey:@"refresh_token"]];
            dict = [self syncHttpRequest:urlStr method:@"GET" data:nil];
            ret = [[dict objectForKey:@"errcode"] intValue];
            if(ret == 0){
                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [mutableDict setValue:[NSNumber numberWithInt:[self getCurrentTime]] forKey:@"token_time"];
                [self saveDict:mutableDict key:WX_LOGON];
            }
        }
    }
    return ret;
}

//http 请求解析返回json
-(NSDictionary *) syncHttpRequest:(NSString *)url method:(NSString *)method data:(NSString *)data
{
    NSLog(@"wx url = %@", url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //设置提交方式
    [request setHTTPMethod:method];
    //设置数据类型
    [request addValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    //设置编码
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    //如果是POST
    if(data != nil && data.length > 0){
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSError *error;
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    //解析服务端返回json数据
    NSDictionary *dict = nil;
    if(response == nil){
        dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:Error_Data], @"errcode", nil];
    }else{
        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        if(error != nil){
            dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:Error_Data], @"errcode", nil];
        }
    }
    return dict;
}

@end
