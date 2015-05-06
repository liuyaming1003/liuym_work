//
//  SignatureView.m
//
//  Created by liuym on 15-04-28.
//
//

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#import "SignatureView.h"

#import <QuartzCore/QuartzCore.h>

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

@interface SignatureView(){
    //UIBezierPath *path;
    UIImage *incrImage;
    CGPoint previousPoint;
    
    BOOL isUserTap;
}

@property (strong, nonatomic) UIColor *pathColor;
@property (strong, nonatomic) NSString *pathFilePath;
@property (nonatomic) int pathWidth;

@property (assign, nonatomic) BOOL hasSignature;

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
    
    self.pointArray = [NSMutableArray array];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector: @selector(doRotate: ) name:UIDeviceOrientationDidChangeNotification object:nil];
}

/**
 *    旋转事件, 旋转后重新绘制图片
 *
 *    @param notification <#notification description#>
 */
- (void)doRotate: (NSNotification *)notification{
    if(incrImage != nil){
        incrImage = [self signatureImage];
    }
}

- (void)setSignature:(NSString *)filePath panColor:(UIColor *)color panWidth:(int)panWidth
{
    self.pathFilePath = filePath;
    self.pathColor = color;
    self.pathWidth = panWidth;
}

- (void)setImagePath:(NSString *)filePath
{
    self.pathFilePath = filePath;
}

- (void)setPanColor:(UIColor *)color
{
    self.pathColor = color;
}

- (void)setPanWidth:(int )panWidth
{
    self.pathWidth = panWidth;
}

- (void)eraseSignature
{
    incrImage = nil;
    self.hasSignature = NO;
    [self setNeedsDisplay];
}

- (int)saveSignature
{
    if(self.hasSignature == NO){
        return -1;
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
    NSArray *array = [self.pathFilePath componentsSeparatedByString:@"."];
    NSData *imageData = nil;
    if(array.count == 2){
        if([[[array objectAtIndex:1] lowercaseString] isEqualToString:@"jpg"]){
            imageData = UIImageJPEGRepresentation(image, 1.0f);
        }else{
            imageData = UIImagePNGRepresentation(image);
        }
    }else{
        return -2;
    }
    
    if(imageData == nil){
        return -3;
    }
    
    BOOL result = [imageData writeToFile:self.pathFilePath atomically:YES];
    if(result != YES){
        return -4;
    }
    
    return 0;
}

- (UIImage *)signatureImage
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
    if(incrImage != nil){
        //绘制图片
        if(rect.size.width == incrImage.size.width && rect.size.height == incrImage.size.height){
            [incrImage drawInRect:rect];
            NSLog(@"image size = %@", NSStringFromCGSize(incrImage.size));
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
        [[UIColor clearColor] setFill];
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
    // [path moveToPoint:startPoint];
    previousPoint = startPoint;
    [self.pointArray addObject:NSStringFromCGPoint(previousPoint)];
    isUserTap = YES;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    isUserTap = NO;
    
    NSInteger touchCount = [[event allTouches] count];
    
    if(touchCount <= 3){
        CGPoint movePoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        if(self.hasSignature == NO){
            self.hasSignature = YES;
        }
        
        if(self.pointArray.count > 50){
            incrImage = [self signatureImage];
            CGPoint last = CGPointFromString([self.pointArray lastObject]);
            CGPoint lastProv = CGPointFromString([self.pointArray objectAtIndex:self.pointArray.count - 2]);
            CGPoint firstPoint = midpoint(lastProv, last);
            [self.pointArray removeAllObjects];
            [self.pointArray addObject:NSStringFromCGPoint(firstPoint)];
        }
        
        [self.pointArray addObject:NSStringFromCGPoint(movePoint)];
        
        
        
        [self setNeedsDisplay];
        
        previousPoint = movePoint;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches Ended");
    
    
    
    if(isUserTap){
        //绘制一个点
        CGPoint endPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        [self.pointArray addObject:NSStringFromCGPoint(endPoint)];
        
        if(self.hasSignature == NO){
            self.hasSignature = YES;
        }
    }
    
    [self setNeedsDisplay];
    incrImage = [self signatureImage];
    [self.pointArray removeAllObjects];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
