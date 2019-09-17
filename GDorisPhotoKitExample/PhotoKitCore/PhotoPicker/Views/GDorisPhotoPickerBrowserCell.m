//
//  GDorisPhotoPickerBrowserCell.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBrowserCell.h"
#import "YYImage.h"
#import "XCAsset.h"
@interface GDorisPhotoPickerBrowserCell()
@property (nonatomic, strong) YYAnimatedImageView * animateImageView;
@property (nonatomic, strong) UIActivityIndicatorView * photoIndicatorView;
@property (nonatomic, copy  ) NSString * currentImageId;
@property (nonatomic, assign) PHImageRequestID  imageRequestID;
@end

@implementation GDorisPhotoPickerBrowserCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.scrollView addSubview:({
            _animateImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
            _animateImageView.runloopMode = NSDefaultRunLoopMode;
            _animateImageView;
        })];
        [self fulFillImageView:self.animateImageView];
    }
    return self;
}

#pragma mark - getter Method

- (UIActivityIndicatorView *)photoIndicatorView
{
    if (!_photoIndicatorView) {
        _photoIndicatorView = [[UIActivityIndicatorView alloc] init];
        CGFloat width = 50;
        _photoIndicatorView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-width)*0.5, ([UIScreen mainScreen].bounds.size.height-width)*0.5, width,width);
        [self.scrollView addSubview:_photoIndicatorView];
    }
    return _photoIndicatorView;
}

#pragma mark - override Method

- (__kindof UIView *)containerView
{
    return self.animateImageView;
}

- (void)configData:(id)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    [super configData:data forItemAtIndexPath:indexPath];
    self.photoItem = data;
    [self resetScrollViewZoom];
    [self.photoIndicatorView startAnimating];
    self.contentImageView.image = nil;
    id<IGDorisPhotoItem> photo = self.photoItem;
    /// photokit asset
    if (Doris_Select(photo, @selector(asset))) {
        if (photo.asset && [photo.asset isKindOfClass:XCAsset.class]) {
            [self loadAssetItem:photo];
        }
    }
}

- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configDidEndDisplayingCellData:data forItemAtIndexPath:indexPath];
    [self.animateImageView stopAnimating];
}

- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configWillDisplayCellData:data forItemAtIndexPath:indexPath];
    [self.animateImageView startAnimating];
}

#pragma mark - Private Method

- (void)loadAssetItem:(id<IGDorisPhotoItem>)photo
{
    XCAsset * asset = photo.asset;
    BOOL isGif = (asset.assetSubType == XCAssetSubTypeGIF);
    __weak __typeof(self) weakSelf = self;
    CGSize size = asset.imageSize;
    [self fitImageSize:size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        weakSelf.scrollView.contentSize = scrollContentSize;
        weakSelf.scrollSize = scrollContentSize;
        // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
        weakSelf.contentImageView.frame = CGRectApplyAffineTransform(containerFrame, weakSelf.contentImageView.transform);
    }];
    
    if (Doris_Select(photo, @selector(thumbImage))) {
        UIImage * image = photo.thumbImage;
        if (image) {
            self.contentImageView.image = image;
        }
    }
    self.currentImageId = asset.identifier;
    if (isGif) {
        [asset requestImageData:^(NSData * _Nonnull imageData, NSDictionary<NSString *,id> * _Nonnull info, BOOL isGIF, BOOL isHEIC) {
            if (imageData) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    YYImage * image = [YYImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.contentImageView.image = image;
                        [weakSelf.photoIndicatorView stopAnimating];
                    });
                });
            }
        }];
    } else {
        NSInteger imageRequestID =  [asset requestThumbnailImageWithSize:asset.imageSize completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
            
            if ([asset.identifier isEqualToString:self.currentImageId] && result) {
                weakSelf.contentImageView.image = result;
            } else {
                NSLog(@"cancelImageRequest");
                [[PHImageManager defaultManager] cancelImageRequest:weakSelf.imageRequestID];
            }
            [weakSelf.photoIndicatorView stopAnimating];
        }];
        if (imageRequestID > 0 && self.imageRequestID > 0 && imageRequestID != self.imageRequestID) {
            NSLog(@"cancelImageRequest2222222222");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        self.imageRequestID = imageRequestID;
    }
}
@end
