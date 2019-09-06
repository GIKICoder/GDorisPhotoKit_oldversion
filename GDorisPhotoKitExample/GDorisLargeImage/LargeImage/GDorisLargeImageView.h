//
//  GDorisLargeImageView.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/6.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisLargeImageView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL aspectFill;
@property (nonatomic, strong) UIView *imageView;    // in case you want to grab the image for other purposes, and then nil it

- (void)displayObject:(id)obj;
- (void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

@end

NS_ASSUME_NONNULL_END
