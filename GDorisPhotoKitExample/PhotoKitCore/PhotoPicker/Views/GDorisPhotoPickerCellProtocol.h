//
//  GDorisPhotoPickerCellProtocol.h
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisAssetItem.h"


NS_ASSUME_NONNULL_BEGIN

@protocol GDorisPhotoPickerCellProtocol <NSObject>

- (void)configData:(GDorisAssetItem*)asset withIndex:(NSInteger)index;
- (void)loadLargerAsset:(GDorisAssetItem*)asset;

- (UIImageView *)imageView;

@optional
@property(nonatomic, copy) BOOL (^shouldSelectHanlder)(GDorisAssetItem *assetModel);
@property(nonatomic, copy) void (^didSelectHanlder)(GDorisAssetItem *assetModel);
@property(nonatomic, copy) void (^didDeselectHanlder)(GDorisAssetItem *assetModel);

@end

NS_ASSUME_NONNULL_END
