//
//  GDorisWXPhotoBrowserController.m
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXPhotoBrowserController.h"
#import "GNavigationBar.h"
#import "GDorisWXToolbar.h"
#import "GDorisPhotoHelper.h"
#import "UIView+GDoris.h"
#import "GDorisAnimatedButton.h"
#import "GDorisPhotoBrowserControllerInternal.h"
#import "GDorisWXThumbnailContainer.h"
#import "GDorisWXPhotoEditController.h"
@interface GDorisWXPhotoBrowserController ()
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisAnimatedButton * selectCountBtn;
@property (nonatomic, strong) UIView * bottomContainer;
@property (nonatomic, strong) GDorisWXToolbar * wxToolbar;
@property (nonatomic, strong) GDorisWXThumbnailContainer * thumbnialContainer;
@property (nonatomic, strong) NSArray * selectAssets;
@end

@implementation GDorisWXPhotoBrowserController

#pragma mark -- life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadNavigationBar];
    [self loadBottomContainer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSArray * selectAssets = [self getSelectAssets];
    if (selectAssets.count > 0) {
        self.thumbnialContainer.hidden = NO;
        [self.thumbnialContainer configDorisAssets:selectAssets];
    }
    [self setToolbarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)dealloc
{
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)loadNavigationBar
{
    self.navigationController.navigationBar.hidden = YES;
    self.navigationBar = [GNavigationBar navigationBar];// [[GNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.g_width, G_NAV_HEIGHT)];
    [self.navigationBar setNavigationEffectWithStyle:(UIBlurEffectStyleDark)];
    [self.view addSubview:self.navigationBar];
    GNavigationItem * back = [GNavItemFactory createImageButton:[UIImage imageNamed:@"GDoris_picker_back_white"] highlightImage:[UIImage imageNamed:@"GDoris_picker_back_white"] target:self selctor:@selector(back)];
    self.navigationBar.leftNavigationItem = back;
    
    self.selectCountBtn = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
    self.selectCountBtn.frame = CGRectMake(0, 0, 26, 26);
    self.selectCountBtn.selectType = GDorisPickerSelectCount;
    self.selectCountBtn.selected = YES;
    self.selectCountBtn.selectIndex = @"1";
    self.selectCountBtn.countFont = [UIFont systemFontOfSize:17];
    [self.selectCountBtn setBackgroundImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar_normal"] forState:UIControlStateNormal];
    [self.selectCountBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    GNavigationItem * count = [GNavItemFactory createCustomView:self.selectCountBtn];
    self.navigationBar.rightNavigationItem = count;
}

- (void)loadBottomContainer
{
    self.bottomContainer = [UIView new];
    self.bottomContainer.frame = CGRectMake(0, self.view.g_height-44-80, self.view.g_width, 44+80);
    [self.view addSubview:self.bottomContainer];
    [self loadToolBar];
    [self loadThumbContainer];
}

- (void)loadToolBar
{
    self.wxToolbar = [[GDorisWXToolbar alloc] initWithFrame:CGRectMake(0, 80, G_SCREEN_WIDTH, 44)];
    [self.bottomContainer addSubview:self.wxToolbar];
    [self.wxToolbar.leftButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar"] forState:UIControlStateSelected];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar_normal"] forState:UIControlStateNormal];
    [self.wxToolbar.rightButton setTitle:@"发送" forState:UIControlStateNormal];
    self.wxToolbar.userInteractionEnabled = YES;
    self.wxToolbar.enabled = YES;
    __weak typeof(self) weakSelf = self;
    self.wxToolbar.wxToolbarClickBlock = ^(DorisWXToolbarItemType itemType) {
        [weakSelf wxToolbarClick:itemType];
    };
}

- (void)loadThumbContainer
{
    self.thumbnialContainer = [[GDorisWXThumbnailContainer alloc] initWithFrame:CGRectMake(0, 0 , self.view.g_width, 80)];
    self.thumbnialContainer.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.thumbnialContainer.thumbnailCellDidSelect = ^(GDorisAsset * _Nonnull asset) {
        [weakSelf processBrowserScroller:asset];
    };
    [self.bottomContainer addSubview:self.thumbnialContainer];
}

#pragma mark - action Method

- (void)wxToolbarClick:(DorisWXToolbarItemType)itemType
{
    if (itemType == DorisWXToolbarItemLeft) {
        [self presentPhotoEdit];
    } else if (itemType == DorisWXToolbarItemRight) {
        
    }
}

- (void)presentPhotoEdit
{
    [self setToolbarHidden:YES animated:NO];
    NSIndexPath *currentIndexPath = [self currentIndexPath];
    GDorisAsset * asset = [self.PhotoDatas objectAtIndex:currentIndexPath.item];
    GDorisWXPhotoEditController * controller = [[GDorisWXPhotoEditController alloc] initWithImage:[asset.asset previewImage]];
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

- (void)selectBtnClick:(GDorisAnimatedButton*)btn
{
    NSIndexPath *currentIndexPath = [self currentIndexPath];
    if (!currentIndexPath) return;
    GDorisAsset * asset = [self.PhotoDatas objectAtIndex:currentIndexPath.item];
    if (!asset.isSelected) {
        BOOL canSelect = [self canselect:asset];
        if (canSelect) {
            [self didSelectAsset:asset];
            btn.selected = YES;
            asset.isSelected = YES;
            [btn popAnimated];
        }
    } else {
        btn.selected = NO;
        asset.isSelected = NO;
        [self didDeselectAsset:asset];
    }
    NSArray * selectItems = [self getSelectAssets];
    self.wxToolbar.enabled = (selectItems.count > 0);
    self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",selectItems.count];
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    dispatch_block_t block = ^{
        if (hidden) {
            self.navigationBar.g_top -= self.navigationBar.g_height;
            self.bottomContainer.g_top += self.bottomContainer.g_height;
        } else {
            self.navigationBar.hidden = hidden;
            self.bottomContainer.hidden = hidden;
            self.navigationBar.g_top = 0;
            self.bottomContainer.g_bottom = self.view.g_bottom;
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            block();
        } completion:^(BOOL finished) {
            self.navigationBar.hidden = hidden;
            self.bottomContainer.hidden = hidden;
        }];
    } else {
        block();
        self.navigationBar.hidden = hidden;
        self.bottomContainer.hidden = hidden;
    }
}

- (void)processBrowserScroller:(GDorisAsset *)assetModel
{
    NSArray * selectAssets = [self getSelectAssets];
    if (selectAssets.count>0 && selectAssets.count == self.PhotoDatas.count) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetModel.selectIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    } else {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetModel.index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    }
}

#pragma mark - helper Method

- (BOOL)canselect:(GDorisAsset *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:shouldSelectAsset:)]) {
        return [self.delegate dorisPhotoBrowser:self shouldSelectAsset:asset];
    }
    return YES;
}

- (void)didSelectAsset:(GDorisAsset *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didSelectAsset:)]) {
        [self.delegate dorisPhotoBrowser:self didSelectAsset:asset];
    }
    [self.thumbnialContainer configDorisAssets:[self getSelectAssets]];
}

- (void)didDeselectAsset:(GDorisAsset *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didDeselectAsset:)]) {
        [self.delegate dorisPhotoBrowser:self didDeselectAsset:asset];
    }
    [self.thumbnialContainer configDorisAssets:[self getSelectAssets]];
}

- (NSArray *)getSelectAssets
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowserGetSelectAssets:)]) {
        self.selectAssets = [self.delegate dorisPhotoBrowserGetSelectAssets:self];
        return self.selectAssets;
    }
    return nil;
}

#pragma mark - override Method

- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisAsset * asset = [self.PhotoDatas objectAtIndex:indexPath.item];
    self.selectCountBtn.selected = asset.isSelected;
    if (asset.isSelected) {
        if (!self.selectAssets) {
            self.selectAssets = [self getSelectAssets];
        }
        NSInteger index = [self.selectAssets indexOfObject:asset];
        if (self.selectAssets.count > index) {
            GDorisAsset * selectAsset = [self.selectAssets objectAtIndex:index];
            self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",selectAsset.selectIndex+1];
            [self.thumbnialContainer scrollToIndex:index];
        } else {
            self.selectCountBtn.selected = NO;
        }
    }
}

- (void)singleTapContentHandler:(GDorisAsset *)data
{
    [self setToolbarHidden:!self.navigationBar.hidden animated:YES];
}

#pragma mark - GDorisZoomGestureHandlerProtocol

- (void)beginGestureHandler:(CGFloat)progress
{
    [self setToolbarHidden:YES animated:NO];
}

- (void)endGestureHandler:(BOOL)isCanceled
{
    [self setToolbarHidden:NO animated:NO];
}

- (CGRect)gestureEffectiveFrame
{
    if (self.navigationBar.hidden) {
        return CGRectZero;
    } else {
        return CGRectMake(0, self.navigationBar.g_bottom, self.view.g_width,self.view.g_height - self.navigationBar.g_bottom - self.thumbnialContainer.g_height-self.wxToolbar.g_height); 
    }
}


@end
