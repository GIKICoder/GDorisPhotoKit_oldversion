//
//  GDorisPhotoBrowserContentCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserContentCell.h"

@interface GDorisPhotoBrowserContentCell ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, weak  ) UIImageView  * contentImageView;
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
            _scrollView.frame = self.contentView.bounds;
            _scrollView.delaysContentTouches = NO;
            _scrollView.backgroundColor = [UIColor clearColor];
            if (@available(iOS 11, *)) {
                _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            _scrollView;
        })];
    
        self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self loadGestureRecognizer];
        self.zoomEnabled = YES;
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

- (void)disabledAllGesture:(BOOL)disabled
{
    self.singleTapGestureRecognizer.enabled = !disabled;
    self.doubleTapGestureRecognizer.enabled = !disabled;
    self.scrollView.scrollEnabled = !disabled;
    self.zoomEnabled = !disabled;
    if (disabled) {
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.minimumZoomScale = 1;
    } else {
        self.scrollView.maximumZoomScale = 2;
        self.scrollView.minimumZoomScale = 1;
       
    }
}

- (void)disabledSingleGesture:(BOOL)disabled
{
    self.singleTapGestureRecognizer.enabled = !disabled;
}

- (void)fulFillImageView:(UIImageView *)imageView
{
    self.contentImageView = imageView;
}

- (void)configData:(id<IGDorisPhotoItem>)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.photoItem = data;
}

- (void)processSizeWithImage:(UIImage *)image imageContainer:(__kindof UIView *)container
{
    __weak typeof(self) weakSelf = self;
    __weak UIView * containerW = container;
    [self fitImageSize:image.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        weakSelf.scrollView.contentSize = scrollContentSize;
        weakSelf.scrollSize = scrollContentSize;
        // 更新 imageView 的大小时，imageView 可能已经被缩放过，所以要应用当前的缩放
        containerW.frame = CGRectApplyAffineTransform(containerFrame, container.transform);
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

#pragma mark - GestureRecognizer

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
    return self.contentView;
}

#pragma mark - actions

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.SingleTapHandler) {
        self.SingleTapHandler(self.photoItem);
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
