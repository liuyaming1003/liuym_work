//
//  ViewController.m
//  SignatureDemo
//
//  Created by liuym on 15/5/6.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import "ViewController.h"
#import "SignatureImageVC.h"
#import <SignatureSDK/SignatureView.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet SignatureView *signatureView;

@property (nonatomic, strong) NSString *imageFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    self.imageFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.jpg"]];
    
    NSLog(@"imageFilePath = %@", self.imageFilePath);
    
    [self.signatureView setSignature:self.imageFilePath panColor:[UIColor blackColor] panWidth:4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPress:(UIButton *)button
{
    if(button.tag == 1000){
        int result = [self.signatureView saveSignature];
        NSString *string = nil;
        switch (result) {
            case 0:
                string = @"签名成功";
                break;
            case -1:
                string = @"未签名";
                break;
            case -2:
                string = @"文件路径错误";
                break;
            case -3:
                string = @"数据错误";
                break;
            case -4:
                string = @"保存图片错误";
                break;
            default:
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if(button.tag == 1001){
        [self.signatureView eraseSignature];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowSignatureImage"]){
        SignatureImageVC *vc = segue.destinationViewController;
        
        UIImage *image = [UIImage imageWithContentsOfFile:self.imageFilePath];
        [vc setValue:image forKey:@"image"];
    }
}

@end
