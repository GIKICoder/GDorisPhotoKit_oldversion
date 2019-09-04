//
//  GDoris3DTouchPreviewController.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisAssetItem.h"
#import "GDorisPhotoPickerConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDoris3DTouchPreviewController : UIViewController

@property (nonatomic, strong,readonly) GDorisAssetItem * assetModel;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (instancetype)initWithDorisAsset:(GDorisAssetItem *)assetModel configuration:(GDorisPhotoPickerConfiguration *)configuration;


@end

NS_ASSUME_NONNULL_END
