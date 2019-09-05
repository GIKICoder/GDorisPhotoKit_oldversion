//
//  GDorisPhotoPickerController.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisBasePhotoPickerController.h"
#import "GScrollerGestureTransition.h"
#import "GDoirsPhotoPickerToolbar.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerController : GDorisBasePhotoPickerController

/**
 功能按钮名称
 Example: @"发送",@"确定"...
 Default: @"确定"
 */
@property (nonatomic, copy  ) NSString * functionTitle;

#pragma mark - 下滑手势相关
/// 是否开启下滑手势.Default: YES
@property (nonatomic, assign) BOOL  scrollerGestureEnabled;
/// 是否是作为subView 添加到superView中. 不是系统转场的形式 Default: NO
@property (nonatomic, assign) BOOL  addBySubViews;
/// 下滑手势开启的偏移量. 默认距离顶部120
@property (nonatomic, assign) CGFloat  transitionBeginOffset;
/// 下滑手势滑动到底部的偏移量 默认ScreenHeight
@property (nonatomic, assign) CGFloat  transitionBottomOffset;
/// 手势下滑回调
@property(nonatomic, copy) void (^TransitionChangedState)(CGFloat offsetY,BOOL showNavBar);
/// 手动改变下滑状态的函数
- (void)transitionMove:(ScrollerTransitionState)state;
- (void)photoToolbarClick:(DorisPhotoPickerToolbarType)itemType;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
