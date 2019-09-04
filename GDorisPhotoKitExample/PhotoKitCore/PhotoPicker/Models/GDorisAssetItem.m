//
//  GDorisAssetItem.m
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisAssetItem.h"
#import "GDorisLivePhotoPickerCell.h"
#import "GDorisGifPhotoPickerCell.h"
#import <Photos/Photos.h>
@implementation GDorisAssetItem

+ (instancetype)createAssetItem:(XCAsset*)asset index:(NSInteger)index
{
    GDorisAssetItem * dorisAsset = [[GDorisAssetItem alloc] initWithAsset:asset configuration:nil index:index];
    return dorisAsset;
}

+ (instancetype)createAssetItem:(XCAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index
{
    GDorisAssetItem * dorisAsset = [[GDorisAssetItem alloc] initWithAsset:asset configuration:configuration index:index];
    return dorisAsset;
}

- (instancetype)initWithAsset:(XCAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index
{
    NSParameterAssert(asset);
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.index = index;
        self.asset = asset;
        if (configuration.livePhotoEnabled && asset.assetSubType == XCAssetSubTypeLivePhoto) {
            self.cellClass = NSStringFromClass([GDorisLivePhotoPickerCell class]);
        } else if (configuration.gifPhotoEnabled && asset.assetSubType == XCAssetSubTypeGIF) {
            self.cellClass = NSStringFromClass([GDorisGifPhotoPickerCell class]);
        } else {
            self.cellClass = NSStringFromClass([GDorisPhotoPickerBaseCell class]);
        }
    }
    return self;
}

- (CGSize)imageSize
{
    return CGSizeMake(self.asset.phAsset.pixelWidth, self.asset.phAsset.pixelHeight);
}

- (NSInteger)itemIndex
{
    return self.index;
}

- (BOOL)isVideo
{
    return (self.asset.assetType == XCAssetTypeVideo);
}

- (NSArray *)videoURLArray
{
    
    NSString * fileName = nil;
    if (@available(iOS 9.0, *)) {
        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:_asset.phAsset];
        PHAssetResource *resource;
        for (PHAssetResource *assetRes in assetResources) {
            if (assetRes.type == PHAssetResourceTypePairedVideo ||
                assetRes.type == PHAssetResourceTypeVideo) {
                resource = assetRes;
            }
        }
        if (resource.originalFilename) {
            fileName = resource.originalFilename;
        }
    } else {
        // Fallback on earlier versions
    }
    if (fileName.length > 0) {
        NSURL * URL = [NSURL URLWithString:fileName];
        return @[URL];
    }
    return @[];
}
@end
