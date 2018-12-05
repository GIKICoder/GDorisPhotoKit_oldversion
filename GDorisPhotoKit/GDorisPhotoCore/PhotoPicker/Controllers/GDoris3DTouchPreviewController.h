//
//  GDoris3DTouchPreviewController.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisAsset.h"
#import "GDorisPhotoPickerConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDoris3DTouchPreviewController : UIViewController

@property (nonatomic, strong,readonly) GDorisAsset * assetModel;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (instancetype)initWithDorisAsset:(GDorisAsset *)assetModel configuration:(GDorisPhotoPickerConfiguration *)configuration;


@end

NS_ASSUME_NONNULL_END
