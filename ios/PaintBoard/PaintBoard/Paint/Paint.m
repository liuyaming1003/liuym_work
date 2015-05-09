//
//  Paint.m
//
//  Created by liuym on 15-04-28.
//
//

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#import "Paint.h"

#import <QuartzCore/QuartzCore.h>

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

@interface SignatureView()

@property (strong, nonatomic) UIColor        *pathColor;
@property (strong, nonatomic) NSString       *pathFilePath;
@property (nonatomic        ) CGFloat       pathWidth;

@property (strong, nonatomic) UIImage        *signatureImage;

@property (assign, nonatomic) BOOL           hasSignature;
@property (assign, nonatomic) BOOL           hasDot;
@property (assign, nonatomic) BOOL           isRunningPaint;

@property (strong, nonatomic) NSMutableArray *pointArray;

@end

@implementation SignatureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // path = [UIBezierPath bezierPath];
    
    self.hasSignature = NO;
    self.isRunningPaint = NO;
    
    self.pointArray = [NSMutableArray array];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector: @selector(doRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 *    旋转事件, 旋转后重新绘制图片
 *
 *    @param notification <#notification description#>
 */
- (void)doRotate:(NSNotification *)notification{
    if(self.signatureImage != nil){
        self.signatureImage = [self createSignatureImage];
        [self.pointArray removeAllObjects];
    }
}

- (void)setSignature:(NSString *)filePath panColor:(UIColor *)color panWidth:(CGFloat )width
{
    self.pathFilePath = filePath;
    self.pathColor = color;
    self.pathWidth = width;
}

- (void)setImagePath:(NSString *)filePath
{
    self.pathFilePath = filePath;
}

- (void)setPanColor:(UIColor *)color
{
    self.pathColor = color;
}

- (void)setPanWidth:(CGFloat )width
{
    self.pathWidth = width;
}

- (void)eraseSignature
{
    if(self.isRunningPaint){
        return;
    }
    
    self.signatureImage = nil;
    self.hasSignature = NO;
    [self setNeedsDisplay];
}

- (SignatureType )saveSignature
{
    if(self.hasSignature == NO){
        return Signature_No_Sign;
    }
    
    if(self.isRunningPaint){
        return Signature_Running;
    }
    
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
    }
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    /**
     *    开始保存图片
     */
    
    if(self.pathFilePath == nil){
        return Signature_FilePath_Error;
    }
    
    NSArray *array = [self.pathFilePath componentsSeparatedByString:@"."];
    NSData *imageData = nil;
    if(array.count >= 2){
        if([[[array objectAtIndex:array.count - 1] lowercaseString] isEqualToString:@"jpg"]){
            imageData = UIImageJPEGRepresentation(image, 1.0f);
        }else{
            imageData = UIImagePNGRepresentation(image);
        }
    }else{
        return Signature_FilePath_Error;
    }
    
    if(imageData == nil){
        return Signature_Data_Error;
    }
    
    BOOL result = [imageData writeToFile:self.pathFilePath atomically:YES];
    if(result != YES){
        return Signature_Save_Error;
    }
    
    return Signature_OK;
}

- (UIImage *)createSignatureImage
{
    if(self.hasSignature == NO){
        return nil;
    }
    //支持retina高分的关键
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    }
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawRect:(CGRect)rect
{
    if(self.signatureImage != nil){
        //绘制图片
        if(rect.size.width == self.signatureImage.size.width && rect.size.height == self.signatureImage.size.height){
            [self.signatureImage drawInRect:rect];
            NSLog(@"image size = %@", NSStringFromCGSize(self.signatureImage.size));
        }
        
    }
    
    if(self.pointArray.count > 0){
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointFromString(self.pointArray[0])];
        
        if(self.pointArray.count == 1){
            //绘制一个点
            CGPoint startPoint = CGPointFromString(self.pointArray[0]);
            [path addLineToPoint:CGPointMake(startPoint.x + 3, startPoint.y + 3)];
        }else{
            for(int i = 0; i < self.pointArray.count - 1; i++){
                CGPoint startPoint = CGPointFromString(self.pointArray[i]);
                CGPoint endPoint = CGPointFromString(self.pointArray[i + 1]);
                
                CGPoint midPoint = midpoint(startPoint, endPoint);
                
                [path addQuadCurveToPoint:midPoint controlPoint:startPoint];
            }
        }
        
        [self.pathColor setStroke];
        path.lineWidth = self.pathWidth;
        path.lineCapStyle = kCGLineCapRound; //线条拐角
        path.lineJoinStyle = kCGLineCapRound; //终点处理
        [path stroke];
    }
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches Began");
    CGPoint startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    [self.pointArray addObject:NSStringFromCGPoint(startPoint)];
    
    self.hasDot = YES;
    self.isRunningPaint = YES;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.hasDot = NO;
    
    NSInteger touchCount = [[event allTouches] count];
    
    if(touchCount <= 3){
        CGPoint movePoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        if(self.hasSignature == NO){
            self.hasSignature = YES;
        }
        
        if(self.pointArray.count > 50){
            self.signatureImage = [self createSignatureImage];
            CGPoint last = CGPointFromString([self.pointArray lastObject]);
            CGPoint lastProv = CGPointFromString([self.pointArray objectAtIndex:self.pointArray.count - 2]);
            CGPoint firstPoint = midpoint(lastProv, last);
            [self.pointArray removeAllObjects];
            [self.pointArray addObject:NSStringFromCGPoint(firstPoint)];
        }
        
        [self.pointArray addObject:NSStringFromCGPoint(movePoint)];
        [self setNeedsDisplay];
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches Ended");
    
    if(self.hasDot){
        //绘制一个点
      //  CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
      //  [self.pointArray addObject:NSStringFromCGPoint(endPoint)];
        
        if(self.hasSignature == NO){
            self.hasSignature = YES;
        }
    }
    
    self.isRunningPaint = NO;
    
    [self setNeedsDisplay];
    self.signatureImage = [self createSignatureImage];
    [self.pointArray removeAllObjects];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    self.isRunningPaint = NO;
    self.signatureImage = [self createSignatureImage];
    [self.pointArray removeAllObjects];
    [super touchesCancelled:touches withEvent:event];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
