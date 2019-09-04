//
//  GDorisWXThumbnailContainer.m
//  GDoris
//
//  Created by GIKI on 2018/9/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXThumbnailContainer.h"
#import "GDorisPhotoHelper.h"

@interface GDorisWXThumbnailCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation GDorisWXThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView  addSubview:({
            _imageView = [UIImageView new];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.layer.masksToBounds = YES;
            _imageView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (void)configAsset:(GDorisAssetItem *)assetModel
{
    self.imageView.image = [assetModel.asset thumbnailWithSize:self.bounds.size];
}

@end

@interface GDorisWXThumbnailContainer ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) NSArray * assetModels;
@property (nonatomic, strong) UIView * borderView;
@end

@implementation GDorisWXThumbnailContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectV = [[UIVisualEffectView alloc] initWithEffect:effect];
        self.effectView = effectV;
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = @[(__bridge id) [UIColor colorWithRed:(4)/255.0 green:(0)/255.0 blue:(18)/255.0 alpha:0.76].CGColor,(__bridge id)[UIColor colorWithRed:(4)/255.0 green:(0)/255.0 blue:(18)/255.0 alpha:0.58].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [effectV.contentView.layer addSublayer:gradientLayer];
        [self addSubview:effectV];
        effectV.frame = self.bounds;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        [collectionView registerClass:[GDorisWXThumbnailCell class] forCellWithReuseIdentifier:@"GDorisWXThumbnailCell"];
        self.collectionView = collectionView;
        [self addSubview:self.collectionView];
        [self.collectionView addSubview:({
            _borderView = [UIView new];
            _borderView.layer.borderWidth = 2;
            _borderView.layer.borderColor = GDorisColorCreate(@"20A115").CGColor;
            _borderView.hidden = YES;
            _borderView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.effectView.frame = self.bounds;
    self.collectionView.frame = CGRectMake(0, (self.bounds.size.height-55)*0.5, self.bounds.size.width, 55);
}

#pragma mark - public Method

- (void)configDorisAssets:(NSArray<GDorisAssetItem *>*)assets
{
    if (assets.count == 0) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    self.assetModels = assets;
    [self.collectionView reloadData];
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= self.assetModels.count) {
        self.borderView.hidden = YES;
        return;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    GDorisWXThumbnailCell * cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:self.collectionView];
    self.borderView.hidden = NO;
    self.borderView.frame = rect;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES];

}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisWXThumbnailCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisWXThumbnailCell" forIndexPath:indexPath];
    if (self.assetModels.count > indexPath.item) {
        GDorisAssetItem * assetModel = [self.assetModels objectAtIndex:indexPath.item];
        [cell configAsset:assetModel];
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisWXThumbnailCell * cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:self.collectionView];
    self.borderView.hidden = NO;
    self.borderView.frame = rect;
    if (self.thumbnailCellDidSelect) {
        GDorisAssetItem * assetModel = [self.assetModels objectAtIndex:indexPath.item];
        self.thumbnailCellDidSelect(assetModel);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(55, 55);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 12, 0, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 14;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

@end
