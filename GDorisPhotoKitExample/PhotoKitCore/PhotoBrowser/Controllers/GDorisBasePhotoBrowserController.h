//
//  GDorisBasePhotoBrowserController.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "IGDorisPhotoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisBasePhotoBrowserController : UIViewController <GDorisZoomPresentedControllerProtocol>

- (instancetype)initWithPhotoItems:(NSArray<id<IGDorisPhotoItem>> *)photoItems index:(NSUInteger)index;

@property (nonatomic, strong, readonly) NSArray<id<IGDorisPhotoItem>> * PhotoDatas;
@property (nonatomic, strong, readonly) UICollectionView * collectionView;

@property (nonatomic, assign, readonly) NSInteger  beginIndex;
@property (nonatomic, assign, readonly) NSUInteger currentIndex;

@property (nonatomic, assign) CGFloat  lineSpace;

@end

NS_ASSUME_NONNULL_END
