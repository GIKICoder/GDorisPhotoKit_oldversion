//
//  GDorisWXEditColorPanel.m
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXEditColorPanel.h"
#import "UIView+GDoris.h"
#import "GDorisPhotoHelper.h"
@interface GDorisWXEditColorCell : UICollectionViewCell
@property (nonatomic, strong) UIView * colorView;
@property (nonatomic, strong) UIView * selectColorView;
@end

@implementation GDorisWXEditColorCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:({
            _colorView = [UIView new];
            _colorView.layer.cornerRadius = 10;
            _colorView.layer.masksToBounds = YES;
            _colorView.layer.borderColor = [UIColor whiteColor].CGColor;
            _colorView.layer.borderWidth = 2;
            _colorView;
        })];
        [self.contentView addSubview:({
            _selectColorView = [UIView new];
            _selectColorView.layer.cornerRadius = 13;
            _selectColorView.layer.masksToBounds = YES;
            _selectColorView.layer.borderColor = [UIColor whiteColor].CGColor;
            _selectColorView.layer.borderWidth = 2;
            _selectColorView.hidden = YES;
            _selectColorView;
        })];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat width = 20;
        CGFloat height = 20;
        CGFloat left = 0.5*(self.g_width - width);
        CGFloat top = 0.5*(self.g_height - height);
        self.colorView.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 26;
        CGFloat height = 26;
        CGFloat left = 0.5*(self.g_width - width);
        CGFloat top = 0.5*(self.g_height - height);
        self.selectColorView.frame = CGRectMake(left, top, width, height);
    }
}

- (void)configColor:(UIColor *)color
{
    self.colorView.backgroundColor = color;
    self.selectColorView.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectColorView.hidden = !selected;
}
@end

@interface GDorisWXEditColorPanel ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UIButton * revokeBtn;
@property (nonatomic, strong) NSArray * colors;
@end

@implementation GDorisWXEditColorPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = NO;
        [collectionView registerClass:[GDorisWXEditColorCell class] forCellWithReuseIdentifier:@"GDorisWXEditColorCell"];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
        [button setTitle:@"撤销" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(revokeClick:) forControlEvents:UIControlEventTouchUpInside];
        _revokeBtn = button;
        [self addSubview:_revokeBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat width = self.g_width;
        CGFloat height = 45;
        CGFloat left = 0;
        CGFloat top = 0;
        self.collectionView.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = 32;
        CGFloat height = 45;
        CGFloat left = self.g_width-15-32;
        CGFloat top = 0;
        self.revokeBtn.frame = CGRectMake(left, top, width, height);
    }
   
}

- (void)configColors:(NSArray<UIColor *> *)colors
{
    self.colors = colors;
    [self.collectionView reloadData];
}

- (void)revokeClick:(UIButton *)button
{
    if (self.revokeActionBlock) {
        self.revokeActionBlock();
    }
}

- (void)setSelectedByIndex:(NSInteger)index
{
    if (index >= self.colors.count) {
        index = 0;
    }
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    cell.selected = YES;
}

- (void)setRevokeEnabled:(BOOL)enabled
{
    self.revokeBtn.enabled = enabled;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisWXEditColorCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisWXEditColorCell" forIndexPath:indexPath];
    if (self.colors.count > indexPath.item) {
        UIColor * color = [self.colors objectAtIndex:indexPath.item];
        if (![color isKindOfClass:[NSString class]]) {
            [cell configColor:color];
        }
    }
    if (indexPath.item == 0) {
        cell.selected = YES;
        if (cell.selected) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
        }
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    if (self.colorDidSelectBlock) {
        if (self.colors.count > indexPath.item) {
            UIColor * color = [self.colors objectAtIndex:indexPath.item];
            self.colorDidSelectBlock(color);
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(26, 45);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 17;
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


@interface GDorisWXEditMosaicPanel ()
@property (nonatomic, strong) UIButton * revokeBtn;
@property (nonatomic, strong) UIButton * mosaicBtn1;
@property (nonatomic, strong) UIButton * mosaicBtn2;
@end

@implementation GDorisWXEditMosaicPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.revokeBtn = [self createBtn:@"撤销" tag:1001];
        self.mosaicBtn1 = [self createBtn:@"马赛克" tag:1002];
        self.mosaicBtn1.selected = YES;
        self.mosaicBtn2 = [self createBtn:@"模糊" tag:1003];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    {
        CGFloat width = 32;
        CGFloat height = 45;
        CGFloat left = self.g_width-15-32;
        CGFloat top = 0;
        self.revokeBtn.frame = CGRectMake(left, top, width, height);
    }
    CGFloat itemwidth = (self.g_width - 32 -15)*0.5;
    {
        CGFloat width = itemwidth;
        CGFloat height = 45;
        CGFloat left = 0;
        CGFloat top = 0;
        
        self.mosaicBtn1.frame = CGRectMake(left, top, width, height);
    }
    {
        CGFloat width = itemwidth;
        CGFloat height = 45;
        CGFloat left = itemwidth;
        CGFloat top = 0;
        
        self.mosaicBtn2.frame = CGRectMake(left, top, width, height);
    }
}

- (UIButton *)createBtn:(NSString*)title tag:(NSInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:GDorisColorCreate(@"20A115") forState:(UIControlStateSelected)];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)buttonClick:(UIButton *)btn
{
    if (btn.tag == 1001) {
        if (self.revokeActionBlock) {
            self.revokeActionBlock();
        }
    } else {
        self.mosaicBtn1.selected = NO;
        self.mosaicBtn2.selected = NO;
        btn.selected = YES;
        if (self.mosaicDidSelectBlock) {
            self.mosaicDidSelectBlock(btn.tag);
        }
    }
}

- (void)setRevokeEnabled:(BOOL)enabled
{
    self.revokeBtn.enabled = enabled;
}
@end

