//
//  GDorisPhotoBrowserContentCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserContentCell.h"
#import "GDorisAsset.h"
@interface GDorisPhotoBrowserContentCell ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, assign) CGSize  scrollSize;
@property (nonatomic, strong, readwrite) GDorisAsset * assetModel;
@end

@implementation GDorisPhotoBrowserContentCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:({
            _scrollView = [[UIScrollView alloc] init];
            _scrollView.delegate = self;
            _scrollView.maximumZoomScale = 2;
            _scrollView.minimumZoomScale = 1;
            _scrollView.showsHorizontalScrollIndicator = NO;
            _scrollView.showsVerticalScrollIndicator = NO;
            _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _scrollView.delaysContentTouches = NO;
            _scrollView.backgroundColor = [UIColor clearColor];
            if (@available(iOS 11, *)) {
                _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            _scrollView;
        })];
        [self.scrollView addSubview:({
            _imageView = [UIImageView new];
            _imageView;
        })];
        
        [self loadGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
}

- (void)loadGestureRecognizer
{
    [self.scrollView addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.scrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void)configData:(GDorisAsset *)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.assetModel = data;
    [self resetScrollViewZoom];
    self.imageView.image = data.thumbnailImage;
    __weak typeof(self) weakSelf = self;
    [self fitImageSize:data.thumbnailImage.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        weakSelf.scrollView.contentSize = scrollContentSize;
        weakSelf.scrollSize = scrollContentSize;
        // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
        weakSelf.imageView.frame = CGRectApplyAffineTransform(containerFrame, self.imageView.transform);
    }];
    
    PHAsset * asset = data.asset;
    [asset asyncPreviewImageWithCompletion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
        if (result) {
            weakSelf.imageView.image = result;
            [weakSelf fitImageSize:result.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
                weakSelf.scrollView.contentSize = scrollContentSize;
                weakSelf.scrollSize = scrollContentSize;
                // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
                weakSelf.imageView.frame = CGRectApplyAffineTransform(containerFrame, self.imageView.transform);
            }];
        }
    } progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    }];
    
}

- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self resetScrollViewZoom];
}

- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self resetScrollViewZoom];
    self.scrollView.contentSize = self.scrollSize;
}

#pragma mark - getter Method

- (UITapGestureRecognizer *)singleTapGestureRecognizer
{
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer
{
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

#pragma mark - private Method

- (__kindof UIView *)containerView
{
    return self.imageView;
}

#pragma mark - actions

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.SingleTapHandler) {
        self.SingleTapHandler(self.assetModel);
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (![self zoomEnabled]) return;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        CGPoint touchPoint = [tapGestureRecognizer locationInView:[self containerView]];
        
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = width / newZoomScale;
        CGFloat ysize = height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        [self.scrollView setZoomScale:newZoomScale animated:YES];
    }
}

- (void)resetScrollViewZoom
{
    if (CGRectIsEmpty(self.bounds)) return;
    
    BOOL enabled = [self zoomEnabled];
    self.scrollView.panGestureRecognizer.enabled = enabled;
    self.scrollView.pinchGestureRecognizer.enabled = enabled;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.contentSize = self.scrollView.bounds.size;
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    [self containerViewDidZoom:self.scrollView];
    [self layoutIfNeeded];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (BOOL)zoomEnabled
{
    return YES;
}

#pragma mark - Helper Method

- (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed
{
    CGFloat containerWidth = containerSize.width;
    CGFloat containerHeight = containerSize.height;
    CGFloat containerScale = containerWidth / containerHeight;
    
    CGFloat width = 0, height = 0, x = 0, y = 0 ;
    CGSize contentSize = CGSizeZero;
    width = containerWidth;
    height = containerWidth * (imageSize.height / imageSize.width);
    if (imageSize.width / imageSize.height >= containerScale) {
        x = 0;
        y = (containerHeight - height) / 2.0;
        contentSize = CGSizeMake(containerWidth, containerHeight);
        
    } else {
        x = 0;
        y = 0;
        contentSize = CGSizeMake(containerWidth, height);
    }
    if (completed) completed(CGRectMake(x, y, width, height), contentSize);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self containerView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self containerViewDidZoom:scrollView];
}

- (void)containerViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    UIView * container = [self containerView];
    container.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}
@end
