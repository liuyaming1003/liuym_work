//
//  ViewController.m
//  SignNameDemo
//
//  Created by liuym on 4/22/15.
//  Copyright (c) 2015 Liuym. All rights reserved.
//

#import "ViewController.h"
#import "SignNameSDK.h"
@interface ViewController ()

@property (nonatomic, strong) IBOutlet SignNameSDK *snView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.snView setSN:@"" panColor:[UIColor blueColor] panWidth:1];
}

- (IBAction)operationSN:(UIButton *)sender
{
    if(sender.tag == 1000){
        [self.snView saveSN];
    }else if(sender.tag == 1001){
        [self.snView eraseSN];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
