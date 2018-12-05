//
//  GDorisWXThumbnailContainer.h
//  GDoris
//
//  Created by GIKI on 2018/9/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisWXThumbnailContainer : UIView

@property(nonatomic, copy) void (^thumbnailCellDidSelect)(GDorisAsset * asset);

- (void)configDorisAssets:(NSArray<GDorisAsset *>*)assets;
- (void)scrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
