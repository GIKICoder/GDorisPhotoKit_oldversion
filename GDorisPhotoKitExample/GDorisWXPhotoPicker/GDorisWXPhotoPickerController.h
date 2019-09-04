//
//  GDorisWXPhotoPickerController.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisBasePhotoPickerController.h"
#import "XCAssetsManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisWXPhotoPickerController : GDorisBasePhotoPickerController

+ (instancetype)WXPhotoPickerController:(GDorisPhotoPickerConfiguration *)configuration;

+ (instancetype)WXPhotoPickerController:(GDorisPhotoPickerConfiguration *)configuration collection:(XCAssetsGroup *)collection;

- (void)presentPhotoPickerController:(UIViewController *)targetController;

/**
 功能按钮名称
 Example: @"发送",@"确定"...
 Default: @"确定"
 */
@property (nonatomic, copy  ) NSString * functionTitle;

@end

NS_ASSUME_NONNULL_END
