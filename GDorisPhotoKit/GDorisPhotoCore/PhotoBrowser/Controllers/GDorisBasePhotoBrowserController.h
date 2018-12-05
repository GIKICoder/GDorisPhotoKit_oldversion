//
//  GDorisBasePhotoBrowserController.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoKitManager.h"
#import "GDorisAsset.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisBasePhotoBrowserController : UIViewController<GDorisZoomPresentedControllerProtocol>

+ (instancetype)photoBrowserWithDorisAssets:(NSArray<GDorisAsset *> *)dorisAssets beginIndex:(NSInteger)index;
- (instancetype)initWithDorisAssets:(NSArray<GDorisAsset *> *)dorisAssets beginIndex:(NSInteger)index;



@property (nonatomic, strong, readonly) NSArray * PhotoDatas;
@property (nonatomic, strong, readonly) UICollectionView * collectionView;

@end

NS_ASSUME_NONNULL_END
