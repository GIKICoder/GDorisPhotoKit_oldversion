//
//  GDorisBasePhotoPickerBrowserController.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisBasePhotoBrowserController.h"
#import "IGDorisPhotoItem.h"
#import "GDorisPhotoBrowserDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisBasePhotoPickerBrowserController : GDorisBasePhotoBrowserController<GDorisZoomGestureHandlerProtocol>

//+ (instancetype)photoBrowser:(NSArray<id<IGDorisPhotoItem>> *)photos index:(NSUInteger)index;
//
//@property (nonatomic, weak  ) id<GDorisPhotoBrowserDelegate>  delegate;
//
///**
// 是否隐藏工具栏
// Default: NO
// */
//@property (nonatomic, assign) BOOL  hiddenToolBar;
///**
// 功能按钮名称
// Example: @"发送",@"确定"...
// Default: @"确定"
// */
//@property (nonatomic, copy  ) NSString * functionTitle;


@end

NS_ASSUME_NONNULL_END
