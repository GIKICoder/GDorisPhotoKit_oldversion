//
//  GDorisCanvasView.h
//  GDoris
//
//  Created by GIKI on 2018/8/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisCanvasMaskType) {
    DorisCanvasMaskLine,
    DorisCanvasMaskCurve,
    DorisCanvasMaskOval,
    DorisCanvasMaskRect,
    DorisCanvasMaskArrow,
    DorisCanvasMaskMosaic,
};

typedef NS_ENUM(NSUInteger, DorisCanvasDrawState) {
    DorisCanvasDrawStateBegin,
    DorisCanvasDrawStateEnd,
    DorisCanvasDrawStateMove,
    DorisCanvasDrawStateCancel,
    DorisCanvasDrawStateClick,
};

@interface GDorisCanvasView : UIView

@property (nonatomic, strong) UIColor * paintColor;
@property (nonatomic, assign) CGFloat  lineWidth;
@property (nonatomic, assign) DorisCanvasMaskType  maskType;
@property(nonatomic, copy) void (^dorisDrawActionBlock)(DorisCanvasDrawState state);

- (instancetype)initWithImage:(UIImage*)image;

- (void)setMaskImage:(UIImage *)maskImage;
- (void)revokeLastMask;
- (void)resetAllMask;
- (BOOL)canRevoke;

@end

NS_ASSUME_NONNULL_END
