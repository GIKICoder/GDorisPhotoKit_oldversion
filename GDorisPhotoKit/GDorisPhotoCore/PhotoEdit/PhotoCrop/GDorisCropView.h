//
//  GDorisCropView.h
//  GDoris
//
//  Created by GIKI on 2018/9/5.
//  Copyright © 2018年 GIKI. All rights reserved.
//
//  Code Reference: https://github.com/TimOliver/TOCropViewController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GDorisCropOverlayView;
@class GDorisCropView;
@protocol GDorisCropViewDelegate<NSObject>

- (void)cropViewDidBecomeResettable:(GDorisCropView *)cropView;
- (void)cropViewDidBecomeNonResettable:(GDorisCropView *)cropView;

@end

@interface GDorisCropView : UIView

/**
 需要裁剪的图片，实例化后不可更改
 */
@property (nonnull, nonatomic, strong, readonly) UIImage *image;

/**
 图片上的网格视图
 */
@property (nonnull, nonatomic, strong, readonly) GDorisCropOverlayView *gridOverlayView;

/**
 裁剪图像的容器视图
 */
@property (nonnull, nonatomic, readonly) UIView *foregroundContainerView;

/**
 A delegate object that receives notifications from the crop view
 */
@property (nullable, nonatomic, weak) id<GDorisCropViewDelegate> delegate;

/**
 启用网格视图手势，如果设置为NO.则不能使用手势调整网格视图
 Default vaue is YES.
 */
@property (nonatomic, assign) BOOL cropBoxResizeEnabled;

/**
 是否可以重置已经调整的视图
 */
@property (nonatomic, readonly) BOOL canBeReset;

/**
 图片裁剪框的Frame
 */
@property (nonatomic, readonly) CGRect cropBoxFrame;

/**
 在scrollView中图片视图的Frame
 */
@property (nonatomic, readonly) CGRect imageViewFrame;

/**
 裁剪区域的内边距
 */
@property (nonatomic, assign) UIEdgeInsets cropRegionInsets;

/**
 是否禁用半透明视图
 */
@property (nonatomic, assign) BOOL simpleRenderMode;

/**
 执行手动内容布局时(例如在屏幕旋转期间)，禁用任何内部布局
 */
@property (nonatomic, assign) BOOL internalLayoutDisabled;

/**
 A width x height ratio that the crop box will be rescaled to (eg 4:3 is {4.0f, 3.0f})
 Setting it to CGSizeZero will reset the aspect ratio to the image's own ratio.
 */
@property (nonatomic, assign) CGSize aspectRatio;

/**
 When the cropping box is locked to its current aspect ratio (But can still be resized)
 当裁剪框锁定到其当前宽高比时(但仍可调整大小)
 */
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;

/**
 If true, a custom aspect ratio is set, and the aspectRatioLockEnabled is set to YES, the crop box will swap it's dimensions depending on portrait or landscape sized images.  This value also controls whether the dimensions can swap when the image is rotated.
 如果为true，则设置自定义宽高比，并且aspectRatioLockEnabled设置为YES，裁剪框将根据纵向或横向大小的图像交换其尺寸。 此值还控制尺寸在旋转图像时是否可以交换。
 Default is NO.
 */
@property (nonatomic, assign) BOOL aspectRatioLockDimensionSwapEnabled;

/**
 When the user taps 'reset', whether the aspect ratio will also be reset as well
 当用户点击“重置”时，宽高比是否也将被重置
 Default is YES
 */
@property (nonatomic, assign) BOOL resetAspectRatioEnabled;

/**
 True when the height of the crop box is bigger than the width
 如果裁剪框的高度大于宽度，则为true
 */
@property (nonatomic, readonly) BOOL cropBoxAspectRatioIsPortrait;

/**
 The rotation angle of the crop view (Will always be negative as it rotates in a counter-clockwise direction)
 裁剪视图的旋转角度（沿逆时针方向旋转时始终为负）
 */
@property (nonatomic, assign) NSInteger angle;

/**
 Hide all of the crop elements for transition animations
 隐藏过渡动画的所有裁剪元素
 */
@property (nonatomic, assign) BOOL croppingViewsHidden;

/**
 In relation to the coordinate space of the image, the frame that the crop view is focusing on
 对于图像的坐标空间，裁剪视图聚焦的Frame
 */
@property (nonatomic, assign) CGRect imageCropFrame;

/**
 Set the grid overlay graphic to be hidden
 网格视图隐藏属性
 */
@property (nonatomic, assign) BOOL gridOverlayHidden;

///**
// Paddings of the crop rectangle. Default to 14.0
// */
@property (nonatomic) CGFloat cropViewPadding;

/**
 Delay before crop frame is adjusted according new crop area. Default to 0.8
 裁剪后的区域调整时间
 */
@property (nonatomic) NSTimeInterval cropAdjustingDelay;

/**
 The minimum croping aspect ratio. If set, user is prevented from setting cropping rectangle to lower aspect ratio than defined by the parameter.
 最小裁剪宽高比。
 */
@property (nonatomic, assign) CGFloat minimumAspectRatio;

/**
 The maximum scale that user can apply to image by pinching to zoom. Small values are only recomended with aspectRatioLockEnabled set to true. Default to 15.0
 图像缩放的最大比例。 仅在aspectRatioLockEnabled设置为true时生效。 默认为15.0
 */
@property (nonatomic, assign) CGFloat maximumZoomScale;

/**
 Create a default instance of the crop view with the supplied image
 */
- (nonnull instancetype)initWithImage:(nonnull UIImage *)image;


/**
 Performs the initial set up, including laying out the image and applying any restore properties.
 This should be called once the crop view has been added to a parent that is in its final layout frame.
 初始化布局设置或者重置初始化属性设置。
 添加父视图之后，应该调用这个函数。
 */
- (void)performInitialSetup;

/**
 When performing large size transitions (eg, orientation rotation),
 set simple mode to YES to temporarily graphically heavy effects like translucency.
 
 @param simpleMode Whether simple mode is enabled or not
 执行大尺寸转换（例如，方向旋转）时，
 暂时显示图形效果，如半透明效果。

 @param simpleMode 是否启用简单模式
 */
- (void)setSimpleRenderMode:(BOOL)simpleMode animated:(BOOL)animated;

/**
 When performing a screen rotation that will change the size of the scroll view, this takes
 a snapshot of all of the scroll view data before it gets manipulated by iOS.
 Please call this in your view controller, before the rotation animation block is committed.
 当屏幕旋转的时候，调用该方法
 */
- (void)prepareforRotation;

/**
 Performs the realignment of the crop view while the screen is rotating.
 Please call this inside your view controller's screen rotation animation block.
 在屏幕旋转时执行裁剪视图的重新对齐。
 */
- (void)performRelayoutForRotation;

/**
 Reset the crop box and zoom scale back to the initial layout
 重置裁剪框和缩放比例
 @param animated The reset is animated
 */
- (void)resetLayoutToDefaultAnimated:(BOOL)animated;

/**
 Changes the aspect ratio of the crop box to match the one specified
 更改裁剪框的宽高比
 @param aspectRatio The aspect ratio (For example 16:9 is 16.0f/9.0f). 'CGSizeZero' will reset it to the image's own ratio
 @param animated Whether the locking effect is animated
 */
- (void)setAspectRatio:(CGSize)aspectRatio animated:(BOOL)animated;

/**
 Rotates the entire canvas to a 90-degree angle. The default rotation is counterclockwise.
 逆时针选择90度
 @param animated Whether the transition is animated
 */
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated;

/**
 Rotates the entire canvas to a 90-degree angle
 选择90度
 @param animated Whether the transition is animated
 @param clockwise Whether the rotation is clockwise. Passing 'NO' means counterclockwise
 */
- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated clockwise:(BOOL)clockwise;

/**
 Animate the grid overlay graphic to be visible
 */
- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated;

/**
 Animate the cropping component views to become visible
 设置裁剪视图显示动画
 */
- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 Animate the background image view to become visible
 设置背景视图显示动画
 */
- (void)setBackgroundImageViewHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 When triggered, the crop view will perform a relayout to ensure the crop box
 fills the entire crop view region
 */
- (void)moveCroppedContentToCenterAnimated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
