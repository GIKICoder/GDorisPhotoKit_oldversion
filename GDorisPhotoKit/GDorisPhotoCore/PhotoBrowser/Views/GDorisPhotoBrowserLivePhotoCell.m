//
//  GDorisPhotoBrowserLivePhotoCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/31.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserLivePhotoCell.h"

API_AVAILABLE(ios(9.1))
@interface GDorisPhotoBrowserLivePhotoCell()
@property (nonatomic, strong) PHLivePhotoView * livePhotoView;
@end

@implementation GDorisPhotoBrowserLivePhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 9.1, *)) {
            [self.scrollView addSubview:({
                _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectZero];
                _livePhotoView;
            })];
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

#pragma mark - override Method

- (__kindof UIView *)containerView
{
    return self.livePhotoView;
}

- (void)configData:(GDorisAsset *)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.imageView.hidden = YES;
    [self resetScrollViewZoom];
    __weak typeof(self) weakSelf = self;
    PHAsset * asset = data.asset;
    if (@available(iOS 9.1, *)) {
        [asset asyncLivePhotoWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) completion:^(PHLivePhoto *result) {
            [weakSelf fitImageSize:result.size containerSize:self.scrollView.bounds.size Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
                weakSelf.scrollView.contentSize = scrollContentSize;
                weakSelf.livePhotoView.frame = containerFrame;
                weakSelf.livePhotoView.livePhoto = result;
            }];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)configDidEndDisplayingCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configDidEndDisplayingCellData:data forItemAtIndexPath:indexPath];
    [self.livePhotoView stopPlayback];
}

- (void)configWillDisplayCellData:(__kindof id)data forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super configWillDisplayCellData:data forItemAtIndexPath:indexPath];
    if (@available(iOS 9.1, *)) {
        [self.livePhotoView startPlaybackWithStyle:(PHLivePhotoViewPlaybackStyleFull)];
    } else {
        // Fallback on earlier versions
    }
}

@end
