//
//  SignatureImageVC.m
//  SignatureDemo
//
//  Created by liuym on 15/5/6.
//  Copyright (c) 2015年 Liuym. All rights reserved.
//

#import "SignatureImageVC.h"

@interface SignatureImageVC ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation SignatureImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.image){
        self.imageView.image = self.image;
    }
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

@end
