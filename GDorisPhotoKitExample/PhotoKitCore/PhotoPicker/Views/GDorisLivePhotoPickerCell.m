//
//  GDorisLivePhotoPickerCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/13.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisLivePhotoPickerCell.h"
#import <PhotosUI/PhotosUI.h>
#import <Photos/Photos.h>
#import "GDorisPhotoHelper.h"
API_AVAILABLE(ios(9.1))
@interface GDorisLivePhotoPickerCell ()
@property (nonatomic, strong) UIImageView * badgeImage;
@property (nonatomic, strong) UIButton * liveBadgeBtn;
@property (nonatomic, strong) UIImage * livephotoTagImage;
@property (nonatomic, strong) PHLivePhotoView * livePhotoView;
@end

@implementation GDorisLivePhotoPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 9.1, *)) {
            [self.operationCotainer addSubview:({
                _badgeImage = [[UIImageView alloc] init];
                self.livephotoTagImage = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
                _badgeImage.image = self.livephotoTagImage;
                _badgeImage;
            })];
            [self.operationCotainer addSubview:({
                _liveBadgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [_liveBadgeBtn setImage:self.livephotoTagImage forState:UIControlStateNormal];
                
                UIImage * closeImage = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsLiveOff];
                [_liveBadgeBtn setImage:closeImage forState:UIControlStateSelected];
                
                [_liveBadgeBtn setTitle:@"LIVE" forState:UIControlStateNormal];
                [_liveBadgeBtn setTitle:@"关闭" forState:UIControlStateSelected];
                _liveBadgeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:9];
                UIColor *textcolor = GDorisColorA(99, 96, 92,0.6);
                [_liveBadgeBtn setTitleColor:textcolor forState:UIControlStateNormal];
                [_liveBadgeBtn setTitleColor:textcolor forState:UIControlStateSelected];
                _liveBadgeBtn.hidden = YES;
                _liveBadgeBtn.backgroundColor = GDorisColorA(182, 184, 180, 0.5);
                _liveBadgeBtn.layer.cornerRadius = 3;
                _liveBadgeBtn.layer.masksToBounds = YES;
                [_liveBadgeBtn addTarget:self action:@selector(liveBadgeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                _liveBadgeBtn;
            })];
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.badgeImage.frame = CGRectMake(0, 0, self.livephotoTagImage.size.width, self.livephotoTagImage.size.height);
    self.liveBadgeBtn.frame = CGRectMake(0, 0, 50, self.livephotoTagImage.size.height);
}

#pragma mark - private Method

- (PHLivePhotoView *)livePhotoView
API_AVAILABLE(ios(9.1)){
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.contentView.bounds];
        _livePhotoView.hidden = YES;
        [self.contentView addSubview:_livePhotoView];
        [self.contentView bringSubviewToFront:self.operationCotainer];
    }
    return _livePhotoView;
}

- (void)selectClick:(UIButton *)button
{
    [super selectClick:button];
   
}

- (void)liveBadgeBtnClick:(UIButton *)btn
{
    if (self.assetItem.isSelected) {
        [self.livePhotoView stopPlayback];
    } else {
        if (@available(iOS 9.1, *)) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        } else {
            // Fallback on earlier versions
        }
    }
}

#pragma mark - public Method

- (void)configData:(GDorisAssetItem *)asset withIndex:(NSInteger)index
{
    [super configData:asset withIndex:index];
    if (@available(iOS 9.1, *)) {
        __weak typeof(self) weakSelf = self;
        if (self.assetItem.isSelected) {
            self.liveBadgeBtn.hidden = NO;
            self.badgeImage.hidden = YES;
            [asset.asset requestLivePhotoWithCompletion:^(PHLivePhoto * _Nonnull livePhoto, NSDictionary<NSString *,id> * _Nonnull info) {
                if (livePhoto && [livePhoto isKindOfClass:[PHLivePhoto class]]) {
                    weakSelf.livePhotoView.livePhoto = livePhoto;
                    weakSelf.livePhotoView.hidden = NO;
                    [weakSelf.livePhotoView startPlaybackWithStyle:(PHLivePhotoViewPlaybackStyleFull)];
                }
            } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                
            }];

        } else {
            self.badgeImage.hidden = NO;
            self.liveBadgeBtn.hidden = YES;
            if (_livePhotoView) {
                self.livePhotoView.hidden = YES;
                [self.livePhotoView stopPlayback];
            }
        }
    } else {
        // Fallback on earlier versions
    }
}
@end
