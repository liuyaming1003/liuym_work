//
//  SignView.m
//  imate
//
//  Created by liuym on 13-12-19.
//
//

#import "SignatureView.h"

#import <QuartzCore/QuartzCore.h>

static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}

@interface SignatureView(){
    UIBezierPath *path;
    UIImage *incrImage;
    CGPoint previousPoint;
}

@property (strong, nonatomic) UIColor *pathColor;
@property (strong, nonatomic) NSString *pathFilePath;
@property (nonatomic) int pathWidth;

@property (assign, nonatomic) BOOL hasSignature;

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
    path = [UIBezierPath bezierPath];
    // Capture touches
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = YES;
    tap.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:tap];
    
    self.hasSignature = NO;
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector: @selector(doRotate: ) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    CGPoint l = [t locationInView:self];
    
    NSLog(@"point ＝ %@, %@", NSStringFromCGPoint(l));
    
    if (t.state == UIGestureRecognizerStateRecognized) {
    }
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
    path = [UIBezierPath bezierPath];
    self.hasSignature = NO;
    [self.layer setNeedsDisplay];
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
        return -3;
    }
    
    if(imageData == nil){
        return -4;
    }
    
    BOOL result = [imageData writeToFile:self.pathFilePath atomically:YES];
    if(result != YES){
        return -5;
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
        NSLog(@"image size = %@", NSStringFromCGSize(incrImage.size));
    
        [incrImage drawInRect:rect];
    }
    
    [self.pathColor setStroke];
    path.lineWidth = self.pathWidth;
    
    path.lineCapStyle = kCGLineCapRound; //线条拐角
    path.lineJoinStyle = kCGLineCapRound; //终点处理
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches Began");
    CGPoint startPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    [path moveToPoint:startPoint];
    previousPoint = startPoint;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSInteger touchCount = [[event allTouches] count];
    
    if(touchCount <= 3){
        CGPoint movePoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        CGPoint midPoint = midpoint(previousPoint, movePoint);
        [path addQuadCurveToPoint:midPoint controlPoint:previousPoint];
        if(self.hasSignature == NO){
            self.hasSignature = YES;
        }
        previousPoint = movePoint;
        
        [self setNeedsDisplay];
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    incrImage = [self signatureImage];
    [self setNeedsDisplay];
    [path removeAllPoints];
    
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
