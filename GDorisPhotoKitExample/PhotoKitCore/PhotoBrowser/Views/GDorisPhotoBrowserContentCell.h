//
//  GDorisPhotoBrowserContentCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGDorisPhotoItem.h"

NS_ASSUME_NONNULL_BEGIN

#define Doris_NOEmpty(str) (str!=nil&&[str isKindOfClass:[NSString class]]&&[(NSString *)str length]>0)
#define Doris_Select(obj,sel) (obj && [obj respondsToSelector:sel])

@interface GDorisPhotoBrowserContentCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIScrollView  *scrollView;
@property (nonatomic, weak  ,readonly) UIImageView  * contentImageView;

@property (nonatomic, strong) id<IGDorisPhotoItem>  photoItem;
@property (nonatomic, assign) CGSize  scrollSize;
@property (nonatomic, copy  ) void (^SingleTapHandler)(__kindof id data);
@property (nonatomic, assign) BOOL  zoomEnabled;


- (void)resetScrollViewZoom;
- (void)disabledAllGesture:(BOOL)disabled;
- (void)disabledSingleGesture:(BOOL)disabled;

- (void)fulFillImageView:(UIImageView *)imageView;

- (void)processSizeWithImage:(UIImage *)image imageContainer:(__kindof UIView *)container;
- (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;

#pragma mark - Override

//@optional
- (__kindof UIView *)containerView;

- (void)configData:(__kindof id)data forItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
