//
//  GDorisPhotoPickerConfiguration.m
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerConfiguration.h"

@implementation GDorisPhotoPickerConfiguration

+ (GDorisPhotoPickerConfiguration *)defaultConfiguration
{
    GDorisPhotoPickerConfiguration * config = [[self class] configWithAlbumType:XCAlbumContentTypeAll];
    config.FirstNeedsLoadCount = 12;
    return config;
}

+ (GDorisPhotoPickerConfiguration *)configWithAlbumType:(XCAlbumContentType)type
{
    GDorisPhotoPickerConfiguration * config = [GDorisPhotoPickerConfiguration new];
    config.emptyAlbumEnabled = NO;
    config.samrtAlbumEnabled = YES;
    config.isReveres = YES;
    config.selectAnimated = YES;
    config.selectCountEnabled = YES;
    config.pickerPadding = 4;
    config.showCamera = YES;
    config.gestureSelectEnabled = NO;
    config.can3DTouchPreview = YES;
    config.albumType = type ;
    config.FirstNeedsLoadCount = 40;
    return config;
}
@end

@implementation GDorisPhotoPickerAppearance



@end
