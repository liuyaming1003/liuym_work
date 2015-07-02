//
//  ViewController.m
//  thridapi
//
//  Created by liuym on 15/6/26.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import "ViewController.h"

#import "ShareCommon.h"

@interface ViewController ()<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton    *logonBtn;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel     *nicknameLabel;
@property (strong, nonatomic) IBOutlet UILabel     *openId;
@property (strong, nonatomic) UIActionSheet      *actionSheet;

@property (strong, nonatomic) ShareCommon        *shareCommon;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择登陆方式"
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"QQ登陆", @"微信登陆", nil];
    
    NSDictionary *dict = [ShareCommon getSupportShareApp];
    NSLog(@"dict = %@", dict);
    
    // Show the sheet
    
    self.shareCommon = [ShareCommon getInstance];
    
    if([self.shareCommon isSessionValid]){
        //
        [self.logonBtn setTitle:@"退出" forState:UIControlStateNormal];
        [self getUserInfo];
    }else{
        [self.logonBtn setTitle:@"登陆" forState:UIControlStateNormal];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ShareCommonType type;
    NSArray *array;
    switch (buttonIndex) {
        case 0:
            type = ShareCommonType_QQ;
            array = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, kOPEN_PERMISSION_GET_VIP_INFO, kOPEN_PERMISSION_GET_INFO, nil];
            break;
        case 1:
            type = ShareCommonType_WX;
            array = [NSArray arrayWithObjects:@"snsapi_userinfo", nil];
            break;
        default:
            return;
    }
    
    [self.shareCommon logon:type viewController:self permission:array callBack:^(BOOL isSuccess, id object, NSError *error) {
        if(isSuccess){
            [self.logonBtn setTitle:@"退出" forState:UIControlStateNormal];
            [self getUserInfo];
        }else{
            NSLog(@"error = %@", error);
        }
    }];
}

- (void)getUserInfo
{
    [self.shareCommon getUserInfo:^(BOOL isSuccess, id object, NSError *error) {
        if(isSuccess){
            switch ([self.shareCommon getCommonType]) {
                case ShareCommonType_WX:
                {
                    if([object isKindOfClass:[NSDictionary class]]){
                        NSDictionary *dict = (NSDictionary *)object;
                        NSString *imgUrl = [dict objectForKey:@"headimgurl"];
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                        self.headImageView.image = image;
                        self.nicknameLabel.text = [dict objectForKey:@"nickname"];
                    }
                    NSLog(@"wx object = %@", object);
                }
                    break;
                case ShareCommonType_QQ:
                {
                    if([object isKindOfClass:[NSDictionary class]]){
                        NSDictionary *dict = (NSDictionary *)object;
                        NSString *imgUrl = [dict objectForKey:@"figureurl_qq_2"];
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                        self.headImageView.image = image;
                        self.nicknameLabel.text = [dict objectForKey:@"nickname"];
                    }
                }
                    NSLog(@"qq object = %@", object);
                    break;
                default:
                    break;
            }
            self.openId.text = [self.shareCommon getOpneId];
        }else{
            NSLog(@"error = %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)stringToJsonObject:(NSString *)jsonString{
    NSError *error;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if(error == nil){
        
    }
    return object;
}

- (IBAction)logon:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"登陆"]){
        [self.actionSheet showInView:self.view];
    }else{
        [self.shareCommon logout:^(BOOL isSuccess, id object, NSError *error) {
            if(isSuccess){
                NSLog(@"退出成功");
                [sender setTitle:@"登陆" forState:UIControlStateNormal];
            }else{
                NSLog(@"错误 = %@", error.localizedDescription);
            }
        }];
    }
}

/*- (IBAction)wxLogon:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"微信登录"]){
        [[RDAPICommon getInstance] logon:RDAPICommonType_WX viewController:self permission:[NSArray arrayWithObjects:@"snsapi_userinfo", nil] callBack:^(BOOL isSuccess, id object, NSString *error) {
            if(isSuccess){
                [self.wxLogon setTitle:@"退出" forState:UIControlStateNormal];
            }
        }];
    }else{
        [[RDAPICommon getInstance] logout:RDAPICommonType_WX callBack:^(BOOL isSuccess, id object, NSString *error) {
            if(isSuccess){
                [self.wxLogon setTitle:@"微信登录" forState:UIControlStateNormal];
            }
        }];
    }
}

- (IBAction)qqLogon:(UIButton *)sender
{
    if([sender.titleLabel.text isEqualToString:@"QQ登录"]){
        [[RDAPICommon getInstance] logon:RDAPICommonType_QQ viewController:self permission:[NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil] callBack:^(BOOL isSuccess, id object, NSString *error) {
            if(isSuccess){
                APIResponse *resp = (APIResponse *)object;
                
                id object = [self stringToJsonObject:resp.message];
                if(object && [object isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dict = (NSDictionary *)object;
                    NSString *imgUrl = [dict objectForKey:@"figureurl_qq_2"];
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                    self.qqImg.image = image;
                }
                //[sender setTitle:@"退出" forState:UIControlStateNormal];
            }
        }];
    }else{
        [[RDAPICommon getInstance] logout:RDAPICommonType_QQ callBack:^(BOOL isSuccess, id object, NSString *error) {
            if(isSuccess){
                [sender setTitle:@"QQ登录" forState:UIControlStateNormal];
            }
        }];
    }
}
*/
@end
