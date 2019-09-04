//
//  GDorisPhotoBrowserVideoCell.m
//  GDoris
//
//  Created by GIKI on 2019/4/7.
//  Copyright © 2019年 GIKI. All rights reserved.
//

#import "GDorisPhotoBrowserVideoCell.h"

@interface GDorisPhotoBrowserVideoCell()
@property (nonatomic, strong) UIView * videoContainer;
@property (nonatomic, strong) YYAnimatedImageView * videoImageView;
@property (nonatomic, strong) UIButton * playButtonView;
@end

@implementation GDorisPhotoBrowserVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.scrollView addSubview:({
            _videoContainer = [UIView new];
            _videoContainer.backgroundColor = UIColor.clearColor;
            _videoContainer;
        })];
        [self.videoContainer addSubview:({
            _videoImageView = [[YYAnimatedImageView alloc] init];
            _videoImageView;
        })];
        UIImage * image = [UIImage imageNamed:@"player_control_icon_play_big"];
        UIButton * playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:image forState:UIControlStateNormal];
//        [playButton addTarget:self action:@selector(playButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.videoImageView addSubview:playButton];
        self.playButtonView = playButton;
    
        
        [self fulFillImageView:self.videoImageView];
        [self disabledAllGesture:YES];
//        [self.videoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.contentView);
//        }];
//        [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.videoImageView);
//        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - override Method

- (__kindof UIView *)containerView
{
    return self.videoContainer;
}

- (void)configData:(id)data forItemAtIndexPath:(NSIndexPath*)indexPath
{
    [super configData:data forItemAtIndexPath:indexPath];
    [self disabledSingleGesture:YES];
    id<IGDorisPhotoItem> photo = self.photoItem;
    if (photo && [photo respondsToSelector:@selector(asset)] && photo.asset) {
        [self disabledSingleGesture:NO];
        self.playButtonView.hidden = NO;
    } else {
        self.playButtonView.hidden = YES;
    }
}

- (void)playButtonAction
{
    if (self.SingleTapHandler) {
        self.SingleTapHandler(self.photoItem);
    }
}
@end
