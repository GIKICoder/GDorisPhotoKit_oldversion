//
//  GDorisPhotoPickerCameraCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerCameraCell : UICollectionViewCell<GDorisPhotoPickerCellProtocol>
@property(nonatomic, copy) BOOL (^shouldSelectHanlder)(GDorisAssetItem *assetModel);
@property(nonatomic, copy) void (^didSelectHanlder)(GDorisAssetItem *assetModel);
@property(nonatomic, copy) void (^didDeselectHanlder)(GDorisAssetItem *assetModel);
@end

NS_ASSUME_NONNULL_END