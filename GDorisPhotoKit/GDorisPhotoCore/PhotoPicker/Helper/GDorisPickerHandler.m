//
//  GDorisPickerHandler.m
//  GDoris
//
//  Created by GIKI on 2018/9/26.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPickerHandler.h"
#import "GDorisLivePhotoPickerCell.h"
#import "GDorisGifPhotoPickerCell.h"
#import "GDorisPhotoPickerCameraCell.h"

@implementation GDorisRegisterCellClassHandler

- (NSArray *)handlerCellClassWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration
{
    NSMutableArray * registerCellClassM = [NSMutableArray array];
    [registerCellClassM addObject:NSStringFromClass([GDorisPhotoPickerBaseCell class])];
    if (configuration.livePhotoEnabled) {
        [registerCellClassM addObject:NSStringFromClass([GDorisLivePhotoPickerCell class])];
    }
    if (configuration.gifPhotoEnabled) {
        [registerCellClassM addObject:NSStringFromClass([GDorisGifPhotoPickerCell class])];
    }
    if (configuration.showCamera || configuration.showLiveCamera) {
        [registerCellClassM addObject:NSStringFromClass([GDorisPhotoPickerCameraCell class])];
    }
    return registerCellClassM.copy;
}

@end
