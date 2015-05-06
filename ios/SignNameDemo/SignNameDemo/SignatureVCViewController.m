//
//  SignatureVCViewController.m
//  SignNameDemo
//
//  Created by liuym on 4/28/15.
//  Copyright (c) 2015 Liuym. All rights reserved.
//

#import "SignatureVCViewController.h"

#import <SignatureSDK/SignatureView.h>

@interface SignatureVCViewController ()

@property (nonatomic, strong) IBOutlet SignatureView *signView;

@end

@implementation SignatureVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.jpg"]];
    
    NSLog(@"filePaht = %@", filePath);
    
    [self.signView setSignature:filePath panColor:[UIColor whiteColor] panWidth:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)changedWidth:(UISlider *)sender {
    [self.signView setPanWidth:sender.value];
}

- (IBAction)operationSignature:(UIButton *)button
{
    if(button.tag == 1000){
        NSLog(@"result = %d", [self.signView saveSignature]);
    }else if(button.tag == 1001){
        [self.signView eraseSignature];
    }
}

@end
