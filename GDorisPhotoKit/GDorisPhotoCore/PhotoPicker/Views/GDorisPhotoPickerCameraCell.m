//
//  GDorisPhotoPickerCameraCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerCameraCell.h"

@interface GDorisPhotoPickerCameraCell ()
@property (nonatomic, strong) UIImageView * cameraView;
@end

@implementation GDorisPhotoPickerCameraCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _cameraView = [UIImageView new];
            _cameraView.image = [UIImage imageNamed:@"GDoris_Camera"];
            _cameraView.contentMode = UIViewContentModeCenter;
            _cameraView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.cameraView.frame = self.contentView.bounds;
}

- (void)configData:(GDorisAsset *)asset withIndex:(NSInteger)index
{
    
}

- (UIImageView *)imageView
{
    return self.cameraView;
}
@end
