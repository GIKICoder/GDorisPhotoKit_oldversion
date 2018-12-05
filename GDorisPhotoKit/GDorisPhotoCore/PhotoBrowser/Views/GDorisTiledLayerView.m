//
//  GDorisTiledLayerView.m
//  GDoris
//
//  Created by GIKI on 2018/9/2.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisTiledLayerView.h"

@interface GDorisTiledLayerView ()
@property (nonatomic, assign) CGFloat  imageScale;
@property (nonatomic, assign) CGRect  imageRect;
@end

@implementation GDorisTiledLayerView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image scale:(CGFloat)scale
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = image;
        self.imageRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
        self.imageScale = scale;
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = 4;
        tiledLayer.levelsOfDetailBias = 4;
        tiledLayer.tileSize = CGSizeMake(512.0, 512.0);
    }
    return self;
}

+ (Class)layerClass {
    return [CATiledLayer class];
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextScaleCTM(context, _imageScale,_imageScale);
    CGContextDrawImage(context, _imageRect, _image.CGImage);
    CGContextRestoreGState(context);
}

@end
