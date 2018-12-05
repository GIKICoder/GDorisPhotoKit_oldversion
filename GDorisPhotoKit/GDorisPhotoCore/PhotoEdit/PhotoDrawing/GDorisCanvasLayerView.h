//
//  GDorisCanvasLayerView.h
//  GDoris
//
//  Created by GIKI on 2018/9/7.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisMark.h"
NS_ASSUME_NONNULL_BEGIN
@class GDorisCanvasView;
@interface GDorisCanvasLayerView : UIView

- (instancetype)initWithImage:(UIImage*)image;
- (void)drawLayerWithMark:(id<GDorisMark>)mark;
- (void)drawEndWithMark:(id<GDorisMark>)mark;
- (void)revokeMask:(id<GDorisMark> _Nonnull)mark;

- (void)setMaskImage:(UIImage *)image;
- (void)drawLayerMosaicWithMark:(id<GDorisMark>)mark;

@end

NS_ASSUME_NONNULL_END
