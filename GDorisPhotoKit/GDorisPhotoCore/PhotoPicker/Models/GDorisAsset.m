//
//  GDorisAsset.m
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisAsset.h"
#import "GDorisLivePhotoPickerCell.h"
#import "GDorisGifPhotoPickerCell.h"
@implementation GDorisAsset

+ (instancetype)createAsset:(PHAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index
{
    GDorisAsset * dorisAsset = [[GDorisAsset alloc] initWithAsset:asset configuration:configuration index:index];
    return dorisAsset;
}

+ (instancetype)createAsset:(PHAsset*)asset
{
    GDorisAsset * dorisAsset = [[GDorisAsset alloc] initWithAsset:asset configuration:nil index:0];
    return dorisAsset;
}

- (instancetype)initWithAsset:(PHAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index
{
    NSParameterAssert(asset);
    self = [super init];
    if (self) {
        self.asset = asset;
        self.meidaType = asset.photoType;
        self.subType = asset.mediaSubType;
        if (self.subType == GDorisImageSubTypeLivePhoto) {
            self.cellClass = NSStringFromClass([GDorisLivePhotoPickerCell class]);
        } else if (self.subType == GDorisImageSubTypeGIF) {
            self.cellClass = NSStringFromClass([GDorisGifPhotoPickerCell class]);
        } else {
            self.cellClass = NSStringFromClass([GDorisPhotoPickerBaseCell class]);
        }
    }
    return self;
}

- (CGSize)imageSize
{
    if (self.asset.pixelWidth != 0 && self.asset.pixelHeight != 0) {
        return CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
    } else {
        return CGSizeMake(200, 350);
    }
}

@end
