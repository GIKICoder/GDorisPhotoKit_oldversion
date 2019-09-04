//
//  GDorisPhotoPickerBaseCell.m
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBaseCell.h"
#import "GDorisAnimatedButton.h"
#import "GDorisPhotoHelper.h"
#import "XCAssetsManager.h"

#define BasecellBundle(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"GDorisPhotoPicker.bundle/%@",imageName]]
@interface GDorisPhotoPickerBaseCell ()
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIView * operationCotainer;
@property (nonatomic, strong) GDorisAnimatedButton  *selectButton;
@property (nonatomic, strong) UILabel * videoTagLabel;
@property (nonatomic, strong) UILabel * photoTagLabel;
@property (nonatomic, strong) GDorisAssetItem * assetItem;
@property (nonatomic, assign) BOOL  isAnimated;
@property (nonatomic, copy  ) NSString * currentImageId;
@property (nonatomic, assign) PHImageRequestID  imageRequestID;
@property (nonatomic, strong) UIColor * disabledColor;
@end

@implementation GDorisPhotoPickerBaseCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.disabledColor = [GDorisPhotoHelper colorWithHex:@"ffffff" alpha:0.5];
        [self.contentView addSubview:({
            _imageView = [UIImageView new];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.layer.cornerRadius = 6;
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
            _selectButton.countBackColor = GDorisColorCreate(@"28CD84");
            _selectButton.countColor = GDorisColorCreate(@"FFFFFF");
            _selectButton.countFont = [UIFont systemFontOfSize:12];
            [_selectButton setImage:BasecellBundle(@"GDoris_Base_PhotoPicker_Unselect") forState:UIControlStateNormal];
            [_selectButton setImage:BasecellBundle(@"GDoris_Base_PhotoPicker_Select") forState:UIControlStateSelected];
            _selectButton.selectType = GDorisPickerSelectCount;
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
            _photoTagLabel = [UILabel new];
            _photoTagLabel.textColor = [UIColor whiteColor];
            _photoTagLabel.font = [UIFont systemFontOfSize:12];
            _photoTagLabel.textAlignment = NSTextAlignmentCenter;
            _photoTagLabel.layer.cornerRadius = 4;
            _photoTagLabel.layer.masksToBounds = YES;
            _photoTagLabel.backgroundColor = GDorisColor(91, 121, 164);
            _photoTagLabel.text = @"GIF";
            _photoTagLabel.hidden = YES;
            _photoTagLabel;
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
    self.photoTagLabel.frame = grect;
}

- (void)selectClick:(UIButton *)button
{
    if (button.selected) { // cancel
        self.assetItem.isSelected = NO;
        if(self.didDeselectHanlder) self.didDeselectHanlder(self.assetItem);
    } else { // select
        if ([self canSelect]) {
            self.assetItem.isSelected = !button.selected;
            if (self.didSelectHanlder) {
                self.didSelectHanlder(self.assetItem);
            }
        }
    }
}

- (BOOL)canSelect
{
    if (self.shouldSelectHanlder) {
        BOOL canSelect = self.shouldSelectHanlder(self.assetItem);
        return canSelect;
    }
    return YES;
}

#pragma mark - public Method

- (void)configData:(GDorisAssetItem *)assetItem withIndex:(NSInteger)index
{
    self.assetItem = assetItem;
    [self configAppearance:assetItem.configuration];
    [self configImageData:assetItem];
    [self configSelectButtonData:assetItem];
    [self configTagData:assetItem];
    if (!assetItem.isSelected && assetItem.selectDisabled) {
        self.operationCotainer.backgroundColor = self.disabledColor;
    } else {
        self.operationCotainer.backgroundColor = UIColor.clearColor;
    }
}

- (void)loadLargerAsset:(GDorisAssetItem*)asset
{
    @autoreleasepool {
        XCAsset * xcasset =  self.assetItem.asset;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat cellWidth = floor((width - (4 * (4-1))) / 4);
        __weak typeof(self) weakSelf = self;
        int64_t imageRequestID = [xcasset requestThumbnailImageWithSize:CGSizeMake(cellWidth, cellWidth) completion:^(UIImage * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
            if ([asset.asset.identifier isEqualToString:self.currentImageId] && result) {
                weakSelf.imageView.image = result;
            } else {
                [[PHImageManager defaultManager] cancelImageRequest:weakSelf.imageRequestID];
            }
        }];
        if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
            [[PHImageManager defaultManager] cancelImageRequest:weakSelf.imageRequestID];
            
        }
        self.imageRequestID = imageRequestID;
    }
 
}

- (void)configImageData:(GDorisAssetItem *)asset
{
    self.imageView.image = nil;
    self.currentImageId = asset.asset.identifier;
    XCAsset * xcasset = asset.asset;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = floor((width - (4 * (4-1))) / 4);
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale > 2) {
        if (asset.configuration.LowMemoryEnabled) {
            cellWidth = cellWidth/scale;
        }
    }
    @autoreleasepool {
        UIImage * image =  [xcasset thumbnailWithSize:CGSizeMake(cellWidth, cellWidth)];
        self.imageView.image = image;
    }
}

- (void)configSelectButtonData:(GDorisAssetItem *)assetItem
{
    if (self.assetItem.configuration.selectCountEnabled) {
        self.selectButton.selectType = GDorisPickerSelectCount;
        self.selectButton.selectIndex = [NSString stringWithFormat:@"%ld",(long)assetItem.selectIndex+1];
    } else {
        self.selectButton.selectType = GDorisPickerSelectICON;
    }
    GDorisPhotoPickerAppearance * appearance = assetItem.configuration.appearance;
    if (assetItem.isSelected && !assetItem.animated) {
        self.selectButton.selected = assetItem.isSelected;
        assetItem.animated = YES;
        if (assetItem.configuration.selectAnimated) {
            [self.selectButton popAnimated];
        }
        if (appearance.selectBorderColor) {
            self.imageView.layer.borderColor = appearance.selectBorderColor.CGColor;
        }
        if (appearance.selectBorderWidth > 0) {
            self.imageView.layer.borderWidth = appearance.selectBorderWidth;
        }
    } else {
        self.selectButton.selected = assetItem.isSelected;
        if (appearance.selectBorderColor) {
            self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        }
        if (appearance.selectBorderWidth > 0) {
            self.imageView.layer.borderWidth = 0;
        }
    }
}

- (void)configTagData:(GDorisAssetItem *)assetItem
{
    self.videoTagLabel.hidden = YES;
    self.photoTagLabel.hidden = YES;
    if (assetItem.asset.assetType == XCAssetTypeVideo) {
        self.videoTagLabel.hidden = NO;
        NSTimeInterval timeInterval = assetItem.asset.duration;//获取需要转换的timeinterval
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"mm:ss";
        NSString *dateString = [formatter stringFromDate:date];
        self.videoTagLabel.text = dateString;
    }
    if (assetItem.asset.assetSubType == XCAssetSubTypeGIF) {
        self.photoTagLabel.hidden = NO;
        self.photoTagLabel.text = @"GIF";
    }
    
    if (assetItem.asset.isLongImage) {
        self.photoTagLabel.hidden = NO;
        self.photoTagLabel.text = @"长图";
    }
    
}

- (void)configAppearance:(GDorisPhotoPickerConfiguration*)configuration
{
    GDorisPhotoPickerAppearance * appearance = configuration.appearance;
    if (appearance.countBackColor) {
        self.selectButton.countBackColor = appearance.countBackColor;
    }
    if (appearance.countColor) {
        self.selectButton.countColor = appearance.countColor;
    }
    if (appearance.countFont) {
        self.selectButton.countFont = appearance.countFont;
    }
    if (appearance.cornerRadius > 0) {
        self.layer.cornerRadius = appearance.cornerRadius;
    }
    if (appearance.selectImage) {
        [_selectButton setImage:appearance.selectImage forState:UIControlStateSelected];
    }
    if (appearance.unselectImage) {
        [_selectButton setImage:appearance.unselectImage forState:UIControlStateNormal];
    }
    if (appearance.disabledColor) {
        self.disabledColor = appearance.disabledColor;
    }
    if (appearance.tagColor) {
        self.photoTagLabel.backgroundColor = appearance.tagColor;
        self.videoTagLabel.backgroundColor = appearance.tagColor;
    }
}

@end
