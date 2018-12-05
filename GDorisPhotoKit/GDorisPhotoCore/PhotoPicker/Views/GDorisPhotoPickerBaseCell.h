//
//  GDorisPhotoPickerBaseCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class GDorisAsset;
@interface GDorisPhotoPickerBaseCell : UICollectionViewCell<GDorisPhotoPickerCellProtocol>

@property (nonatomic, strong, readonly) GDorisAsset * asset;
@property (nonatomic, strong, readonly) UIView * operationCotainer;

@property(nonatomic, copy) BOOL (^shouldSelectHanlder)(GDorisAsset *assetModel);
@property(nonatomic, copy) void (^didSelectHanlder)(GDorisAsset *assetModel);
@property(nonatomic, copy) void (^didDeselectHanlder)(GDorisAsset *assetModel);

- (void)selectClick:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
