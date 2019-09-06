//
//  GDorisLargeImageView_old.m
//  GDoris
//
//  Created by GIKI on 2018/9/2.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisLargeImageView_old.h"

@interface GDorisLargeImageView_old ()<UIScrollViewDelegate>
@property (nonatomic, strong) GDorisTiledLayerView * frontTiledLayerView;
@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, assign) float  minimumScale;
@property (nonatomic, assign) CGFloat  imageScale;
@end

@implementation GDorisLargeImageView_old

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set up the UIScrollView
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.maximumZoomScale = 5.0f;
        self.minimumZoomScale = 0.25f;
        self.backgroundColor = [UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:1.0f];
        // determine the size of the image
        self.image = image;
        CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage));
        self.imageScale = self.frame.size.width/imageRect.size.width;
        self.minimumScale = self.imageScale * 0.75f;
        NSLog(@"imageScale: %f",self.imageScale);
        imageRect.size = CGSizeMake(imageRect.size.width*self.imageScale, imageRect.size.height*self.imageScale);
        // Create a low res image representation of the image to display before the TiledImageView
        // renders its content.
        UIGraphicsBeginImageContext(imageRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextDrawImage(context, imageRect, image.CGImage);
        CGContextRestoreGState(context);
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundImageView.frame = imageRect;
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
        // Create the TiledImageView based on the size of the image and scale it to fit the view.
        self.frontTiledLayerView = [[GDorisTiledLayerView alloc] initWithFrame:imageRect image:image scale:self.imageScale];
        [self addSubview:self.frontTiledLayerView];
    }
    return self;
}

// We use layoutSubviews to center the image in the view
- (void)layoutSubviews {
    [super layoutSubviews];
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.frontTiledLayerView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    self.frontTiledLayerView.frame = frameToCenter;
    self.backgroundImageView.frame = frameToCenter;
    // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
    // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
    // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
    self.frontTiledLayerView.contentScaleFactor = 1.0;
}

#pragma mark UIScrollView delegate methods
// A UIScrollView delegate callback, called when the user starts zooming.
// We return our current TiledImageView.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.frontTiledLayerView;
}
// A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
// we create a new TiledImageView based on the new zoom level and draw it on top of the old TiledImageView.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // set the new scale factor for the TiledImageView
    self.imageScale *=scale;
    if( self.imageScale < self.minimumScale ) self.imageScale = self.minimumScale;
    CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(self.image.CGImage) * self.imageScale,CGImageGetHeight(self.image.CGImage) * self.imageScale);
    // Create a new TiledImageView based on new frame and scaling.
     self.frontTiledLayerView = [[GDorisTiledLayerView alloc] initWithFrame:imageRect image:self.image scale:self.imageScale];
    [self addSubview:self.frontTiledLayerView];
}

// A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
// we remove the old TiledImageView and set the current TiledImageView to be the old view so we can create a
// a new TiledImageView when the zooming ends.
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    // Remove back tiled view.
    [self.tiledLayerView removeFromSuperview];
    // Set the current TiledImageView to be the old view.
    self.tiledLayerView = self.frontTiledLayerView;
}

@end
