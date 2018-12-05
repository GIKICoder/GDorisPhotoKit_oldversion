//
//  GDorisPhotoPickerBaseCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBaseCell.h"
#import "UIButton+GDoris.h"
#import "GDorisAnimatedButton.h"
@interface GDorisPhotoPickerBaseCell ()
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UIView * operationCotainer;
@property (nonatomic, strong) GDorisAnimatedButton  *selectButton;
@property (nonatomic, strong) UILabel * videoTagLabel;
@property (nonatomic, strong) UILabel * GIFTagLabel;
@property (nonatomic, strong) GDorisAsset * asset;
@property (nonatomic, assign) BOOL  isAnimated;
@end

@implementation GDorisPhotoPickerBaseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _imageView = [UIImageView new];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.layer.masksToBounds = YES;
            _imageView;
        })];
        [self.contentView addSubview:({
            _operationCotainer = [UIView new];
            _operationCotainer;
        })];
        
        [self.operationCotainer addSubview:({
            _selectButton = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
            [_selectButton addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
            [_selectButton setImage:[UIImage imageNamed:@"GDoris_picker_select_normal2-1"] forState:UIControlStateNormal];
            [_selectButton setImage:[UIImage imageNamed:@"GDoris_picker_select_selected"] forState:UIControlStateSelected];
            _selectButton.selectType = GDorisPickerSelectCount;
            [_selectButton enlargeHitWithEdges: UIEdgeInsetsMake(4, 10, 10, 10)];
            _selectButton;
        })];
        
        [self.operationCotainer addSubview:({
            _videoTagLabel = [UILabel new];
            _videoTagLabel.textColor = [UIColor whiteColor];
            _videoTagLabel.font = [UIFont systemFontOfSize:13];
            _videoTagLabel.textAlignment = NSTextAlignmentRight;
            _videoTagLabel.hidden = YES;
            _videoTagLabel;
        })];
        [self.operationCotainer addSubview:({
            _GIFTagLabel = [UILabel new];
            _GIFTagLabel.textColor = [UIColor whiteColor];
            _GIFTagLabel.font = [UIFont systemFontOfSize:12];
            _GIFTagLabel.textAlignment = NSTextAlignmentCenter;
            _GIFTagLabel.layer.cornerRadius = 4;
            _GIFTagLabel.layer.masksToBounds = YES;
            _GIFTagLabel.backgroundColor = GDorisColor(91, 121, 164);
            _GIFTagLabel.text = @"动图";
            _GIFTagLabel.hidden = YES;
            _GIFTagLabel;
        })];
        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.operationCotainer.frame = self.contentView.bounds;
    
    CGSize bsize = {22.5,22.5};
    CGFloat btop = 3;
    CGFloat bleft = self.contentView.frame.size.width - bsize.width - 3;
    CGRect brect = {{bleft,btop},bsize};
    self.selectButton.frame = brect;
    
    CGSize vsize = {self.bounds.size.width-5,22};
    CGPoint vpoint = {0,self.bounds.size.height - vsize.height};
    CGRect vrect = {vpoint,vsize};
    self.videoTagLabel.frame = vrect;
    
    CGSize gsize = {30,20};
    CGPoint gpoint = {self.bounds.size.width - gsize.width,self.bounds.size.height - gsize.height};
    CGRect grect = {gpoint,gsize};
    self.GIFTagLabel.frame = grect;
}

- (void)selectClick:(UIButton *)button
{
    if (button.selected) { // cancel
        self.asset.isSelected = NO;
        if(self.didDeselectHanlder) self.didDeselectHanlder(self.asset);
    } else { // select
        if ([self canSelect]) {
            self.asset.isSelected = !button.selected;
            if (self.didSelectHanlder) {
                self.didSelectHanlder(self.asset);
            }
        }
    }
}

- (BOOL)canSelect
{
    if (self.shouldSelectHanlder) {
        BOOL canSelect = self.shouldSelectHanlder(self.asset);
        return canSelect;
    }
    return YES;
}

#pragma mark - public Method

- (void)configData:(GDorisAsset *)asset withIndex:(NSInteger)index
{
    self.asset = asset;
    [self configImageData:asset];
    [self configSelectButtonData:asset];
    [self configTagData:asset];
    if (!asset.isSelected && asset.selectDisabled) {
        self.operationCotainer.backgroundColor = [GDorisPhotoHelper colorWithHex:@"ffffff" alpha:0.5];
    } else {
        self.operationCotainer.backgroundColor = UIColor.clearColor;
    }
}

- (void)configImageData:(GDorisAsset *)asset
{
    PHAsset * phAsset = asset.asset;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = floor((width - (4 * (4-1))) / 4);
    __weak typeof(self) weakSelf = self;
    if (self.asset.thumbnailImage) {
        self.imageView.image = self.asset.thumbnailImage;
    } else {
        [phAsset asyncThumbnailImageWithSize:CGSizeMake(cellWidth, cellWidth) completion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
            weakSelf.imageView.image = result;
            weakSelf.asset.thumbnailImage = result;
        }];
    }
    
}

- (void)configSelectButtonData:(GDorisAsset *)asset
{
    if (self.asset.configuration.selectCountEnabled) {
        self.selectButton.selectType = GDorisPickerSelectCount;
        self.selectButton.selectIndex = [NSString stringWithFormat:@"%ld",(long)asset.selectIndex+1];
    } else {
        self.selectButton.selectType = GDorisPickerSelectICON;
    }
    
    if (asset.isSelected && !asset.animated) {
//
        self.selectButton.selected = asset.isSelected;
        asset.animated = YES;
        if (asset.configuration.selectAnimated) {
            [self.selectButton popAnimated];
        }
    } else {
        self.selectButton.selected = asset.isSelected;
    }
}

- (void)configTagData:(GDorisAsset *)asset
{
    self.videoTagLabel.hidden = YES;
    self.GIFTagLabel.hidden = YES;
    if (asset.meidaType == GDorisMediaTypeVideo) {
        self.videoTagLabel.hidden = NO;
        NSTimeInterval timeInterval = asset.asset.duration;//获取需要转换的timeinterval
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"mm:ss";
        NSString *dateString = [formatter stringFromDate:date];
        self.videoTagLabel.text = dateString;
    }
    if (asset.subType == GDorisImageSubTypeGIF) {
        self.GIFTagLabel.hidden = NO;
    }
}

@end
