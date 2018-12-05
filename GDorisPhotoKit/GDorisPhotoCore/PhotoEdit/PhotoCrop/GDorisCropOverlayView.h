//
//  GDorisCropOverlayView.h
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/TimOliver/TOCropViewController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisCropOverlayView : UIView

/** Hides the interior grid lines, sans animation. */
@property (nonatomic, assign) BOOL gridHidden;

/** Add/Remove the interior horizontal grid lines. */
@property (nonatomic, assign) BOOL displayHorizontalGridLines;

/** Add/Remove the interior vertical grid lines. */
@property (nonatomic, assign) BOOL displayVerticalGridLines;

/** Shows and hides the interior grid lines with an optional crossfade animation. */
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
