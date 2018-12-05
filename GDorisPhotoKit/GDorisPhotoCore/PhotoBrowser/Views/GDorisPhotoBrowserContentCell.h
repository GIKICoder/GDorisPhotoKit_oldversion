//
//  GDorisPhotoBrowserContentCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisAsset.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoBrowserContentCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView * imageView;
@property (nonatomic, strong, readonly) UIScrollView  *scrollView;
@property (nonatomic, strong, readonly) GDorisAsset * assetModel;

@property(nonatomic, copy) void (^SingleTapHandler)(__kindof id data);

- (void)resetScrollViewZoom;
- (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;
- (__kindof UIView *)containerView;

- (void)configData:(__kindof id)data forItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
