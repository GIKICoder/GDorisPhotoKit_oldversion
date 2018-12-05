//
//  GDorisPhotoPickerConfiguration.m
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerConfiguration.h"

@implementation GDorisPhotoPickerConfiguration

+ (GDorisPhotoPickerConfiguration *)defaultWXConfiguration
{
    GDorisPhotoPickerConfiguration * config = [GDorisPhotoPickerConfiguration new];
    config.isReveres = NO;
    config.selectAnimated = YES;
    config.selectCountEnabled = YES;
    config.pickerPadding = 4;
    return config;
}
@end
