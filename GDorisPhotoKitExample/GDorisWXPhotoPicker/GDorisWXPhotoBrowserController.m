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
#import "Masonry.h"
#define kWXToolbarHeight (44+GDoris_TabBarMargin)
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    
}

#pragma mark - Public Method

- (void)setFunctionTitle:(NSString *)functionTitle
{
    _functionTitle = functionTitle;
    [self.wxToolbar.rightButton setTitle:functionTitle forState:UIControlStateNormal];
}

#pragma mark - load UI

- (void)loadNavigationBar
{
    self.navigationController.navigationBar.hidden = YES;
    self.navigationBar = [GNavigationBar navigationBar];
    [self.navigationBar setNavigationEffectWithStyle:(UIBlurEffectStyleDark)];
    [self.view addSubview:self.navigationBar];
    GNavigationItem * back = [GNavItemFactory createImageButton:[UIImage imageNamed:@"GDoris_picker_back_white"] highlightImage:[UIImage imageNamed:@"GDoris_picker_back_white"] target:self selctor:@selector(back)];
    self.navigationBar.leftNavigationItem = back;
    
    self.selectCountBtn = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
    self.selectCountBtn.frame = CGRectMake(0, 0, 26, 26);
    if (self.configuration.selectCountEnabled) {
        self.selectCountBtn.selectType = GDorisPickerSelectCount;
        self.selectCountBtn.countBackColor = GDorisColorCreate(@"28CD84");
        self.selectCountBtn.countColor = GDorisColorCreate(@"FFFFFF");
        self.selectCountBtn.countFont = [UIFont systemFontOfSize:17];
    } else {
        self.selectCountBtn.selectType = GDorisPickerSelectICON;
    }
  
    [self.selectCountBtn setImage:[UIImage imageNamed:@"GDorisPhotoPicker.bundle/GDoris_Base_PhotoPicker_Unselect"] forState:UIControlStateNormal];
    [self.selectCountBtn setImage:[UIImage imageNamed:@"GDorisPhotoPicker.bundle/GDoris_Base_PhotoPicker_Select"] forState:UIControlStateSelected];
    [self.selectCountBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    GNavigationItem * count = [GNavItemFactory createCustomView:self.selectCountBtn];
    self.navigationBar.rightNavigationItem = count;
}

- (void)loadBottomContainer
{
    self.bottomContainer = [UIView new];
    self.bottomContainer.frame = CGRectMake(0, self.view.g_height-kWXToolbarHeight-80, self.view.g_width, kWXToolbarHeight+80);
    [self.view addSubview:self.bottomContainer];
    [self loadToolBar];
    [self loadThumbContainer];
}

- (void)loadToolBar
{
    self.wxToolbar = [[GDorisWXToolbar alloc] initWithFrame:CGRectMake(0, 80, G_SCREEN_WIDTH, kWXToolbarHeight)];
    [self.bottomContainer addSubview:self.wxToolbar];
    [self.wxToolbar.leftButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar"] forState:UIControlStateSelected];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"PhotoLibrary_unselected"] forState:UIControlStateNormal];
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
    self.thumbnialContainer.thumbnailCellDidSelect = ^(GDorisAssetItem * _Nonnull asset) {
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
    GDorisAssetItem * asset = [self.PhotoDatas objectAtIndex:currentIndexPath.item];
    GDorisWXPhotoEditController * controller = [[GDorisWXPhotoEditController alloc] initWithImage:[asset.asset previewImage]];
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)selectBtnClick:(GDorisAnimatedButton*)btn
{
    NSIndexPath *currentIndexPath = [self currentIndexPath];
    if (!currentIndexPath) return;
    GDorisAssetItem * asset = [self.PhotoDatas objectAtIndex:currentIndexPath.item];
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
    [self configWXToolbarState];
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

- (void)processBrowserScroller:(GDorisAssetItem *)assetModel
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

- (void)configWXToolbarState
{
    NSArray * selectItems = [self getSelectAssets];
    self.wxToolbar.enabled = (selectItems.count > 0);
    self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%lu",(unsigned long)selectItems.count];
    if (selectItems.count > 0) {
        NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)selectItems.count];
        [self.wxToolbar.rightButton setTitle:string forState:UIControlStateNormal];
    } else {
        [self.wxToolbar.rightButton setTitle:self.functionTitle forState:UIControlStateNormal];
    }
}

#pragma mark - helper Method

- (BOOL)canselect:(GDorisAssetItem *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:shouldSelectAsset:)]) {
        return [self.delegate dorisPhotoBrowser:self shouldSelectAsset:asset];
    }
    return YES;
}

- (void)didSelectAsset:(GDorisAssetItem *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didSelectAsset:)]) {
        [self.delegate dorisPhotoBrowser:self didSelectAsset:asset];
    }
    [self.thumbnialContainer configDorisAssets:[self getSelectAssets]];
}

- (void)didDeselectAsset:(GDorisAssetItem *)asset
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


#pragma mark - override method

- (void)singleTapContentHandler:(id)data
{
    GDorisAssetItem * photo = data;
    if (!photo.isVideo) {
        [self setToolbarHidden:!self.navigationBar.hidden animated:YES];
    } else {
//        if ([[XCCVideoPlayCenter defaultCenter] isPlaying]) {
//            [self setToolbarHidden:NO animated:YES];
//            [[XCCVideoPlayCenter defaultCenter] stop];
//        } else {
//            [self setToolbarHidden:YES animated:YES];
//            GDorisPhotoBrowserContentCell *cell = (GDorisPhotoBrowserContentCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
//            [[XCCVideoPlayCenter defaultCenter] playPhotoVideoWithObject:photo.asset targetView:cell.containerView];
//        }
    }
    
}

/**
 图片浏览器滚动位置
 用于显示当前图片的index
 @param index 当前图片的index
 */
- (void)browserDidEndDeceleratingWithIndex:(NSInteger)index
{
    if (index >= self.PhotoDatas.count) {
        return;
    }
    GDorisAssetItem * asset = [self.PhotoDatas objectAtIndex:index];
    self.selectCountBtn.selected = asset.isSelected;
    if (asset.isSelected) {
        self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",asset.selectIndex+1];
        [self.thumbnialContainer scrollToIndex:asset.selectIndex];
    } else {
        [self.thumbnialContainer scrollToIndex:NSIntegerMax];
    }
}

- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisAssetItem * item = [self.PhotoDatas objectAtIndex:indexPath.item];
    if (item.iscamera) { ///相机hack一下. 不让浏览.
        NSInteger index = indexPath.item;
        if (indexPath.item == 0) {
            index ++;
        } else {
            index --;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:indexPath.section] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
    } else {
        self.selectCountBtn.selected = item.isSelected;
        if (item.isSelected) {
            self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",item.selectIndex+1];
            [self.thumbnialContainer scrollToIndex:item.selectIndex];
        } else {
            [self.thumbnialContainer scrollToIndex:NSIntegerMax];
        }
    }
}

- (void)browserDidEndDisplayingCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisAssetItem * photo = [self.PhotoDatas objectAtIndex:indexPath.item];
//    if (photo.isVideo) {
//        [[XCCVideoPlayCenter defaultCenter] stop];
//    }
}



#pragma mark - GDorisZoomGestureHandlerProtocol

- (void)beginGestureHandler:(CGFloat)progress
{
    [self setToolbarHidden:YES animated:NO];
}

- (void)endGestureHandler:(BOOL)isCanceled
{
    if (!isCanceled) {
        [self setToolbarHidden:NO animated:NO];
    }
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
