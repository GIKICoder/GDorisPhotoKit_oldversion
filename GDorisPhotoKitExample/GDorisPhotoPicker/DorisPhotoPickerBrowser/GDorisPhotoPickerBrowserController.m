//
//  GDorisPhotoPickerBrowserController.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerBrowserController.h"
#import "GDorisPhotoBrowserControllerInternal.h"
#import "GDorisPhotoBrowserContentCell.h"
#import "GDorisAssetItem.h"
#import "GDorisAnimatedButton.h"
#import "GDorisWXThumbnailContainer.h"
#import "GDoirsPhotoPickerToolbar.h"
#import "GNavigationBar.h"
#import "GDorisPhotoHelper.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "UIView+GDoris.h"
@interface GDorisPhotoPickerBrowserController ()
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisAnimatedButton * selectCountBtn;
@property (nonatomic, strong) UIView * bottomContainer;
@property (nonatomic, strong) GDoirsPhotoPickerToolbar * browserToolbar;
@property (nonatomic, strong) GDorisWXThumbnailContainer * thumbnialContainer;
@property (nonatomic, strong) NSArray * selectAssets;
@end

@implementation GDorisPhotoPickerBrowserController

+ (instancetype)photoBrowser:(NSArray<id<IGDorisPhotoItem>> *)photos index:(NSUInteger)index
{
    GDorisPhotoPickerBrowserController * browser = [[GDorisPhotoPickerBrowserController alloc] initWithPhotoItems:photos index:index];
    return browser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar removeFromSuperview];
    [self setupNavgationBar];
    [self loadBottomContainer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray * selectAssets = [self getSelectAssets];
    if (selectAssets.count > 0) {
        self.thumbnialContainer.hidden = NO;
        [self.thumbnialContainer configDorisAssets:selectAssets];
        self.browserToolbar.enabled = (selectAssets.count > 0);
        NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)selectAssets.count];
        [self.browserToolbar.rightButton setTitle:string forState:UIControlStateNormal];
    }
    [self setToolbarHidden:NO animated:YES];
}

- (void)dealloc
{

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupNavgationBar
{
    
    if (!self.navigationBar) {
        self.navigationBar = [GNavigationBar navigationBar];
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    }
    [self.navigationBar removeFromSuperview];
    [self.view addSubview:self.navigationBar];
   GNavigationItem * back = [GNavItemFactory createImageButton:[UIImage imageNamed:@"Fire_btn_cancel_white"] highlightImage:[UIImage imageNamed:@"Fire_btn_cancel_white"] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = back;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundImageView.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.6];
    self.selectCountBtn = [GDorisAnimatedButton buttonWithType:UIButtonTypeCustom];
    self.selectCountBtn.frame = CGRectMake(0, 0, 28, 28);
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
    if (!self.hiddenToolBar) {
       GNavigationItem * count = [GNavItemFactory createCustomView:self.selectCountBtn];
        self.navigationBar.rightNavigationItem = count;
    }
    
}

- (void)loadBottomContainer
{
    if (self.hiddenToolBar) {
        return;
    }
    self.bottomContainer = [UIView new];
    self.bottomContainer.backgroundColor = [UIColor clearColor];
    self.bottomContainer.frame = CGRectMake(0, self.view.frame.size.height-44-80-GDoris_TabBarMargin, self.view.frame.size.width, 44+80+GDoris_TabBarMargin);
    [self.view addSubview:self.bottomContainer];
    [self loadToolBar];
    [self loadThumbContainer];
}

- (void)loadToolBar
{
    self.browserToolbar = [[GDoirsPhotoPickerToolbar alloc] initWithFrame:CGRectMake(0, 80, G_SCREEN_WIDTH, 44+GDoris_TabBarMargin)];
    self.browserToolbar.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.6];
    [self.bottomContainer addSubview:self.browserToolbar];
    //    [self.browserToolbar.leftButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.browserToolbar.rightButton setTitle:self.functionTitle forState:UIControlStateNormal];
    self.browserToolbar.userInteractionEnabled = YES;
    __weak typeof(self) weakSelf = self;
    self.browserToolbar.photoToolbarClickBlock = ^(DorisPhotoPickerToolbarType itemType) {
        [weakSelf browserToolbarClick:itemType];
    };
    
}

- (void)loadThumbContainer
{
    self.thumbnialContainer = [[GDorisWXThumbnailContainer alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, 80)];
    self.thumbnialContainer.backgroundColor = [GDorisPhotoHelper colorWithHex:@"000000" alpha:0.6];
    self.thumbnialContainer.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.thumbnialContainer.thumbnailCellDidSelect = ^(GDorisAssetItem * _Nonnull asset) {
        [weakSelf processBrowserScroller:asset];
    };
    [self.bottomContainer addSubview:self.thumbnialContainer];
}

#pragma mark - Public Method

- (void)setFunctionTitle:(NSString *)functionTitle
{
    _functionTitle = functionTitle;
    [self.browserToolbar.rightButton setTitle:functionTitle forState:UIControlStateNormal];
}

#pragma mark - Action Method

- (void)browserToolbarClick:(DorisPhotoPickerToolbarType)itemType
{
    if (itemType == DorisPhotoPickerToolbarLeft) {
        
    } else if (itemType == DorisPhotoPickerToolbarRight) {
        NSArray * selectItems = [self getSelectAssets];
        if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didFinishPickingAssets:)]) {
            [self.delegate dorisPhotoBrowser:self didFinishPickingAssets:selectItems];
        }
    }
}

- (void)processBrowserScroller:(GDorisAssetItem *)assetModel
{
    NSArray * selectAssets = [self getSelectAssets];
    if (selectAssets.count>0 && selectAssets.count == self.PhotoDatas.count) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetModel.selectIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
    } else {
        if (self.PhotoDatas.count > assetModel.index) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetModel.index inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO];
        }
    }
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
    NSArray * selectItems = [self getSelectAssets];
    self.browserToolbar.enabled = (selectItems.count > 0);
    self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%lu",(unsigned long)selectItems.count];
    
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
    NSArray * selectArray = [self getSelectAssets];
    [self.thumbnialContainer configDorisAssets:selectArray];
    self.browserToolbar.enabled = (selectArray.count > 0);
    self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%lu",(unsigned long)selectArray.count];
    NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)selectArray.count];
    [self.browserToolbar.rightButton setTitle:string forState:UIControlStateNormal];
}

- (void)didDeselectAsset:(GDorisAssetItem *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoBrowser:didDeselectAsset:)]) {
        [self.delegate dorisPhotoBrowser:self didDeselectAsset:asset];
    }
    NSArray * selectArray = [self getSelectAssets];
    [self.thumbnialContainer configDorisAssets:selectArray];
    self.browserToolbar.enabled = (selectArray.count > 0);
    NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)selectArray.count];
    if (selectArray.count == 0) {
        string = self.functionTitle;
    }
    [self.browserToolbar.rightButton setTitle:string forState:UIControlStateNormal];
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
    GDorisAssetItem * asset = [self.PhotoDatas objectAtIndex:index];
    self.selectCountBtn.selected = asset.isSelected;
    if (asset.isSelected) {
        self.selectCountBtn.selectIndex = [NSString stringWithFormat:@"%ld",asset.selectIndex+1];
        [self.thumbnialContainer scrollToIndex:asset.selectIndex];
    } else {
        [self.thumbnialContainer scrollToIndex:NSIntegerMax];
    }
}

- (void)browserWillDisplayCell:(__kindof GDorisPhotoBrowserContentCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
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
    if (photo.isVideo) {
//        [[XCCVideoPlayCenter defaultCenter] stop];
    }
}


#pragma mark - GDorisZoomGestureHandlerProtocol

- (void)beginGestureHandler:(CGFloat)progress
{
    [self setToolbarHidden:YES animated:NO];
}

- (void)endGestureHandler:(BOOL)isCanceled
{
    if (isCanceled) {
        [self setToolbarHidden:NO animated:NO];
    }
}

- (CGRect)gestureEffectiveFrame
{
    if (self.navigationBar.hidden) {
        return self.view.bounds;
    } else {
        return CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.frame.size.width,self.view.frame.size.height - CGRectGetMaxY(self.navigationBar.frame) - self.thumbnialContainer.frame.size.height-self.browserToolbar.frame.size.height);
    }
}


@end
