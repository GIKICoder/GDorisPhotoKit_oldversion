//
//  GDorisPhotoBrowserContentCell.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IGDorisPhotoItem.h"
#import "YYWebImage.h"
NS_ASSUME_NONNULL_BEGIN

#define Doris_NOEmpty(str) (str!=nil&&[str isKindOfClass:[NSString class]]&&[(NSString *)str length]>0)
#define Doris_Select(obj,sel) (obj && [obj respondsToSelector:sel])

@interface GDorisPhotoBrowserContentCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIScrollView  *scrollView;
@property (nonatomic, weak  ,readonly) YYAnimatedImageView  * contentImageView;
@property (nonatomic, strong, readonly) id<IGDorisPhotoItem>  photoItem;
@property(nonatomic, copy) void (^SingleTapHandler)(__kindof id data);
@property (nonatomic, assign) BOOL  zoomEnabled;


- (void)resetScrollViewZoom;
- (void)disabledAllGesture:(BOOL)disabled;
- (void)disabledSingleGesture:(BOOL)disabled;

- (void)fulFillImageView:(YYAnimatedImageView *)imageView;

- (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;

- (void)processSizeWithImage:(UIImage *)image imageContainer:(__kindof UIView *)container;

#pragma mark - Override
//@required
- (void)loadLocalImage:(UIImage *)image;
- (void)loadLocalImageName:(NSString *)imageName;
- (void)loadThumbImage:(NSURL *)thumbURL;
- (void)loadPlaceHolderImage:(UIImage *)placeHolder;
- (void)loadPreviewImage:(NSURL *)thumbURL;

//@optional
- (__kindof UIView *)containerView;

- (void)configData:(__kindof id)data forItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
