//
//  GDorisPhotoEditerController.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/12/23.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisAssetItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoEditerController : UIViewController

+ (instancetype)photoEditerWithAsset:(GDorisAssetItem *)assetItem image:(nullable UIImage *)image;
@end

NS_ASSUME_NONNULL_END
