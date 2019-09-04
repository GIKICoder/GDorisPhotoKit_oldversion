//
//  GDorisCanvasLayerView.m
//  GDoris
//
//  Created by GIKI on 2018/9/7.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCanvasLayerView.h"
#import "UIImage+GDorisDraw.h"
#import "GDorisCanvasView.h"
#import "GDorisLine.h"
@interface GDorisCanvasLayerView ()
@property (nonatomic, strong) UIImage * originImage;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) CALayer * maskLayer;
@property (nonatomic, strong) CAShapeLayer * shapeLayer;
@property (nonatomic, strong) CAShapeLayer * mosaicLayer;
@end

@implementation GDorisCanvasLayerView


- (instancetype)initWithImage:(UIImage*)image
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        if (image) {
            self.originImage = image;
            self.imageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:self.imageView];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.originImage) {
        self.imageView.frame = self.bounds;
        self.shapeLayer.frame = self.bounds;
        self.maskLayer.frame = self.bounds;
    }
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:self.shapeLayer];
    }
    return _shapeLayer;
}

- (CALayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [[CALayer alloc] init];
        _maskLayer.hidden = YES;
        _maskLayer.frame = self.bounds;
        [self.layer addSublayer:_maskLayer];
        _maskLayer.mask = self.mosaicLayer;
    }
    return _maskLayer;
}

- (CAShapeLayer *)mosaicLayer
{
    if (!_mosaicLayer) {
        _mosaicLayer = [[CAShapeLayer alloc] init];
        _mosaicLayer.lineJoin = kCALineJoinRound;
        _mosaicLayer.lineCap = kCALineCapRound;
        _mosaicLayer.frame = self.bounds;
        [self.layer addSublayer:_mosaicLayer];
        _mosaicLayer.fillColor = nil;
        _mosaicLayer.strokeColor = [UIColor redColor].CGColor;
    }
    return _mosaicLayer;
}

- (void)setMaskImage:(UIImage *)image
{
    if (image) {
        self.maskLayer.hidden = NO;
        self.maskLayer.contents = (__bridge id _Nullable)(image.CGImage);
    } else {
        self.maskLayer.hidden = YES;
    }
}

- (void)drawLayerMosaicWithMark:(id<GDorisMark>)mark
{
     self.mosaicLayer.lineWidth = mark.lineWidth;
     self.mosaicLayer.path = mark.bezierPath.CGPath;
}

- (void)drawLayerWithMark:(id<GDorisMark>)mark
{
        if (mark.shapeLayer) {
            [mark drawShapeLayer];
        } else {
            [mark drawShapeLayer];
            mark.shapeLayer.frame = self.bounds;
            [self.layer addSublayer:mark.shapeLayer];
        }
//    self.shapeLayer.lineWidth = mark.lineWidth;
//    self.shapeLayer.fillColor = mark.fillColor.CGColor;
//    self.shapeLayer.strokeColor = mark.strokeColor.CGColor;
//    self.shapeLayer.path = mark.bezierPath.CGPath;
}

- (void)drawEndWithMark:(id<GDorisMark>)mark
{
    UIImage *image = [self composeDrawImage];
    self.imageView.image = image;
    [self saveDrawImage:image mark:mark];
    self.shapeLayer.path  = nil;
    self.mosaicLayer.path = nil;
}

- (UIImage *)composeDrawImage
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *composeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return composeImage;
}

- (void)saveDrawImage:(UIImage *)image mark:(id<GDorisMark>)mark
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *temPath = [self composeImageTmpPath:mark.MarkID];
        NSData *imgData = UIImagePNGRepresentation(image);
        if (imgData) {
            [imgData writeToFile:temPath atomically:YES];
        }
    });
    
}

- (NSString*)composeImageTmpPath:(NSString*)markID
{
   NSString *tempPath = [NSString stringWithFormat:@"%@%@",[NSHomeDirectory() stringByAppendingFormat:@"/tmp/"], markID];
    return tempPath;
}

- (void)revokeMask:(id<GDorisMark>)mark
{
    if (!mark) {
        self.imageView.image = self.originImage;
        return;
    }
    if ([mark isKindOfClass:[GDorisMosaic class]]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString * path = [self composeImageTmpPath:mark.MarkID];
                NSData *imgData = [NSData dataWithContentsOfFile:path];
                if (imgData){
                    UIImage * image = [UIImage imageWithData:imgData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = image;
                    });
                }
            });
    } else {
        if (mark.shapeLayer) {
            [mark.shapeLayer removeFromSuperlayer];
        }
    }
  
   
}
@end
