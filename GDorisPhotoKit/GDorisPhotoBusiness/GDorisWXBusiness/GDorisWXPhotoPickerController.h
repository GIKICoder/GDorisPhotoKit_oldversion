//
//  GDorisWXPhotoPickerController.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisBasePhotoPickerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisWXPhotoPickerController : GDorisBasePhotoPickerController

+ (instancetype)wxPhotoPickerControllerDelegate:(nullable GDorisPhotoPickerDelegate *)delegate;
+ (instancetype)wxPhotoPickerControllerDelegate:(nullable GDorisPhotoPickerDelegate *)delegate collection:(nullable GDorisCollection *)collection;
- (void)presentWXPhotoPickerController:(UIViewController *)targetController;

@end

NS_ASSUME_NONNULL_END
