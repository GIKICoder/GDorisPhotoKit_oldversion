//
//  GDorisLargeTiledView.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/6.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisLargeTiledView.h"
#import <QuartzCore/CATiledLayer.h>

@interface GLargeTiledLayer : CATiledLayer
@end

@implementation GLargeTiledLayer

+ (CFTimeInterval)fadeDuration
{
    return 0;
}
@end

@interface GDorisLargeTiledView ()
@property (nonatomic, strong) GDorisTiledImageBuilder * builder;
@end

@implementation GDorisLargeTiledView

+ (Class)layerClass
{
    return [GLargeTiledLayer class];
}

- (instancetype)initWithImageBuilder:(GDorisTiledImageBuilder *)imageBuilder
{
    CGRect rect = { CGPointMake(0, 0), [imageBuilder imageSize] };
    if ((self = [super initWithFrame:rect])) {
        self.builder = imageBuilder;
        
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = imageBuilder.zoomLevels;
        
        self.opaque = YES;
        self.clearsContextBeforeDrawing = NO;
    }
    return self;
}

- (CGSize)imageSize
{
    return [self.builder imageSize];
}


/**
 <#Description#>
 "- (void)drawRect:(CGRect)rect" Out of date - will not handle rotations - you could try to apply the affine transform used above
 @param layer <#layer description#>
 @param context <#context description#>
 */
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    if(self.builder.failed) return;
    NSLog(@"drawLayer -- lll");
    CGFloat scale = CGContextGetCTM(context).a;
    
    // Fetch clip box in *view* space; context's CTM is preconfigured for view space->tile space transform
    CGRect box = CGContextGetClipBoundingBox(context);
    
    // Calculate tile index
    CGSize tileSize = [(CATiledLayer*)layer tileSize];
    CGFloat col = (CGFloat)rint(box.origin.x * scale / tileSize.width);
    CGFloat row = (CGFloat)rint(box.origin.y * scale / tileSize.height);
    
    //LOG(@"scale=%f 1/scale=%f levelsOfDetail=%ld levelsOfDetailBias=%ld row=%f col=%f offsetFromScale=%ld", scale, 1/scale, ((CATiledLayer *)layer).levelsOfDetail, ((CATiledLayer *)layer).levelsOfDetailBias, row, col, offsetFromScale(scale));
    
    
    CGImageRef image = [self.builder newImageForScale:scale location:CGPointMake(col, row) box:box];
    
#if 0 // had this happen, think its fixed
    if(!image) {
        NSLog(@"YIKES! No Image!!! row=%f col=%f", row, col);
        return;
    }
    if(CGImageGetWidth(image) == 0 || CGImageGetHeight(image) == 0) {
        NSLog(@"Yikes! Image has a zero dimension! row=%f col=%f", row, col);
        return;
    }
#endif
    
    assert(image);
    
    CGContextTranslateCTM(context, box.origin.x, box.origin.y + box.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    box.origin.x = 0;
    box.origin.y = 0;
    //LOG(@"Draw: scale=%f row=%d col=%d", scale, (int)row, (int)col);
    
    CGAffineTransform transform = [self.builder transformForRect:box /* scale:scale */];
    CGContextConcatCTM(context, transform);
    
    // Detect Rotation
    if(isnormal(transform.b) && isnormal(transform.c)) {
        CGSize s = box.size;
        box.size = CGSizeMake(s.height, s.width);
    }
    
    // LOG(@"BOX: %@", NSStringFromCGRect(box));
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);    // no blending! from QA 1708
    //if(row==0 && col==0)
    CGContextDrawImage(context, box, image);
    CFRelease(image);
    
    if(self.annotates) {
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextSetLineWidth(context, 6.0f / scale);
        CGContextStrokeRect(context, box);
    }
}

// How to render it http://stackoverflow.com/questions/5526545/render-large-catiledlayer-into-smaller-area
- (UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end
