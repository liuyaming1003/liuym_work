//
//  SignNameSDK.h
//  SignNameDemo
//
//  Created by liuym on 4/22/15.
//  Copyright (c) 2015 Liuym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface SignNameSDK : GLKView

- (void)setSN:(NSString *)filePath panColor:(UIColor *)color panWidth:(int )panWidth;

- (int) saveSN;

- (void) eraseSN;

@end
