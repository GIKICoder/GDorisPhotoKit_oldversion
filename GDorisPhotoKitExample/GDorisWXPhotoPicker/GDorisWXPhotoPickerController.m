//
//  GDorisWXPhotoPickerController.m
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXPhotoPickerController.h"
#import "GDorisPhotoPickerControllerInternal.h"
#import "GNavigationBar.h"
#import "GDorisWXAlbumViewController.h"
#import "GDorisWXToolbar.h"
#import "GDorisWXPhotoBrowserController.h"
#import "GDorisPhotoHelper.h"
#import "Masonry.h"
#import "MBProgressHUD.h"

#define kWXToolbarHeight (44+GDoris_TabBarMargin)

@interface GDorisWXPhotoPickerController ()<UIAlertViewDelegate,GDorisZoomPresentingControllerProtocol,GDorisPhotoBrowserDelegate>
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) XCAssetsGroup * collection;
@property (nonatomic, strong) GDorisWXToolbar * wxToolbar;
@property (nonatomic, strong) UIView * notAuthorizedView;
@property (nonatomic, strong) XCAssetsGroup * currentGroup;
@end

@implementation GDorisWXPhotoPickerController

+ (instancetype)WXPhotoPickerController:(GDorisPhotoPickerConfiguration *)configuration;
{
    if (!configuration) {
        configuration = [GDorisPhotoPickerConfiguration defaultConfiguration];
    }
    configuration.isReveres = NO;
    configuration.selectCountEnabled = NO;
    GDorisWXPhotoPickerController *vc = [[GDorisWXPhotoPickerController alloc] initWithConfiguration:configuration];
    return vc;
}

+ (instancetype)WXPhotoPickerController:(GDorisPhotoPickerConfiguration *)configuration collection:(XCAssetsGroup *)collection
{
    GDorisWXPhotoPickerController * picker = [GDorisWXPhotoPickerController WXPhotoPickerController:configuration];
    picker.currentGroup = collection;
    return picker;
}

- (void)presentPhotoPickerController:(UIViewController *)targetController
{
    GDorisWXAlbumViewController * albumVC = [GDorisWXAlbumViewController WXAlbumViewController:self.configuration];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:albumVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [albumVC.navigationController pushViewController:self animated:NO];
    [targetController presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxSelectCount = 9;
    self.functionTitle = @"确定";
    [self loadNavigationbar];
    [self loadWXToolbar];
    [self checkAlbumAuthorizationStatus];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    self.collectionView.frame = CGRectMake(0, G_NAV_HEIGHT, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-G_NAV_HEIGHT-self.wxToolbar.frame.size.height);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - loadDatas

- (void)checkAlbumAuthorizationStatus
{
    XCAssetAuthorizationStatus status = [XCAssetsManager authorizationStatus];
    if (status == XCAssetAuthorizationStatusAuthorized) {
        [self loadData];
    } else if (status == XCAssetAuthorizationStatusNotAuthorized) { ///手动禁止
        self.notAuthorizedView.hidden = NO;
        [self.view bringSubviewToFront:self.notAuthorizedView];
    } else {
        [XCAssetsManager requestAuthorization:^(XCAssetAuthorizationStatus status) {
            if (status == XCAssetAuthorizationStatusAuthorized) {
                [self loadData];
            } else {
                self.notAuthorizedView.hidden = NO;
                [self.view bringSubviewToFront:self.notAuthorizedView];
            }
        }];
    }
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (weakSelf.currentGroup) {
            [weakSelf loadPhotoAssetsWithCollection:weakSelf.currentGroup];
        } else {
            [[XCAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:weakSelf.configuration.albumType showEmptyAlbum:weakSelf.configuration.emptyAlbumEnabled showSmartAlbumIfSupported:weakSelf.configuration.samrtAlbumEnabled usingReturnBlock:^BOOL(XCAssetsGroup * _Nonnull resultAssetsGroup) {
                if (resultAssetsGroup) {
                    XCAssetsGroup * firstGroup = resultAssetsGroup;
                    [weakSelf loadPhotoAssetsWithCollection:firstGroup];
                    weakSelf.currentGroup = firstGroup;
                    return YES;
                }
                return NO;
            }];
        }
    });
}

#pragma mark - Lazy load

- (UIView *)notAuthorizedView
{
    if (!_notAuthorizedView) {
        _notAuthorizedView = [[UIView alloc] init];
        [self.view addSubview:_notAuthorizedView];
        _notAuthorizedView.backgroundColor = UIColor.whiteColor;
        _notAuthorizedView.frame = self.collectionView.bounds;
        UILabel * label = [UILabel new];
        label.text = @"开启相册权限,分享更好的自己";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [GDorisPhotoHelper colorWithHex:@"666666"];
        [_notAuthorizedView addSubview:label];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[GDorisPhotoHelper colorWithHex:@"666666"] forState:UIControlStateNormal];
        button.backgroundColor = [GDorisPhotoHelper colorWithHex:@"29CE85"];
        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        [button setTitle:@"去开启" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(authorizationStatusClick) forControlEvents:UIControlEventTouchUpInside];
        [_notAuthorizedView addSubview:button];
        [_notAuthorizedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.collectionView);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(60);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, 40));
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(label.mas_bottom).mas_offset(25);
        }];
    }
    return _notAuthorizedView;
}


#pragma mark - Private Method

- (void)configPickerToolbarState
{
    self.wxToolbar.enabled = (self.selectItems.count > 0);
    if (self.selectItems.count > 0) {
        NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)self.selectItems.count];
        [self.wxToolbar.rightButton setTitle:string forState:UIControlStateNormal];
    } else {
        [self.wxToolbar.rightButton setTitle:self.functionTitle forState:UIControlStateNormal];
    }
}

- (BOOL)override_canSelectAsset:(GDorisAssetItem *)assetModel
{
    CGFloat maxCount = [self getAssetMaxCount:assetModel.asset];
    BOOL canSelect = [super override_canSelectAsset:assetModel];
    if (!canSelect) {
         UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if (self.onlySelectOneMediaType && self.onlyEnableSelectAssetType != assetModel.asset.assetType) {
            [[self class] showToastHUD:window info:@"不能同时选择照片和视频"];
        } else if (self.selectItems.count >= maxCount) {
            NSString * name = @"张照片";
            if (assetModel.asset.assetType == XCAssetTypeVideo) {
                name = @"个视频";
            }
            NSString * msg = [NSString stringWithFormat:@"最多只能选择%ld%@",(long)maxCount,name];
            [[self class] showToastHUD:window info:msg];
        }
    }
    return canSelect;
}

- (void)override_didSelectAsset:(GDorisAssetItem *)assetModel
{
    [super override_didSelectAsset:assetModel];
    [self configPickerToolbarState];
}

- (void)override_didDeselectAsset:(GDorisAssetItem *)assetModel
{
    [super override_didDeselectAsset:assetModel];
    [self configPickerToolbarState];
}

- (void)override_collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    GDorisAssetItem * assetItem = [self.photoAssets objectAtIndex:indexPath.item];
    if (assetItem.iscamera) {
        [self clickCareamAction];
    } else {
        [self previewPhotoBrowserAction:indexPath.item];
    }
}

- (void)override_previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self previewPhotoBrowserAction:self.clickIndexPath.item];
}

#pragma mark - load UI

- (void)loadNavigationbar
{
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar = [GNavigationBar navigationBar];
    [self.navigationBar setNavigationEffectWithStyle:(UIBlurEffectStyleDark)];
    [self.view addSubview:self.navigationBar];
    if (!self.collection) {
        self.navigationBar.title = @"相机胶卷";
    } else {
        self.navigationBar.title = self.collection.name;
    }
    self.navigationBar.titleColor = UIColor.whiteColor;
    self.navigationBar.titleFont = [UIFont boldSystemFontOfSize:18];
    GNavigationItem * back = [GNavItemFactory createImageButton:[UIImage imageNamed:@"GDoris_picker_back_white"] highlightImage:[UIImage imageNamed:@"GDoris_picker_back_white"] target:self selctor:@selector(back)];
    self.navigationBar.leftNavigationItem = back;
    GNavigationItem * cancel = [GNavItemFactory createTitleButton:@"取消" titleColor:UIColor.whiteColor highlightColor:UIColor.lightGrayColor target:self selctor:@selector(cancel)];
    self.navigationBar.rightNavigationItem = cancel;
}

- (void)loadWXToolbar
{
    self.wxToolbar = [[GDorisWXToolbar alloc] initWithFrame:CGRectMake(0, G_SCREEN_HEIGHT-kWXToolbarHeight, G_SCREEN_WIDTH, kWXToolbarHeight)];
    [self.view addSubview:self.wxToolbar];
    [self.wxToolbar.leftButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar"] forState:UIControlStateSelected];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"PhotoLibrary_unselected"] forState:UIControlStateNormal];
    [self.wxToolbar.rightButton setTitle:@"发送" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.wxToolbar.wxToolbarClickBlock = ^(DorisWXToolbarItemType itemType) {
        [weakSelf wxToolbarClick:itemType];
    };
}

- (void)wxToolbarClick:(DorisWXToolbarItemType)itemType
{
    if (itemType == DorisWXToolbarItemLeft) {
        [self presentPhotoBrowser];
    } else if (itemType == DorisWXToolbarItemRight) {
        [self photoSelectDidFinish];
    }
}

- (void)previewPhotoBrowserAction:(NSInteger)index
{
      GDorisWXPhotoBrowserController * browser = [[GDorisWXPhotoBrowserController alloc] initWithPhotoItems:self.photoAssets.copy index:index];
    browser.delegate = self;
    browser.functionTitle = self.functionTitle;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:browser];
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:browser];
    nav.transitioningDelegate = self.transition;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)presentPhotoBrowser
{
    if (self.selectItems.count <= 0) {
        return;
    }
    GDorisWXPhotoBrowserController * browser = [[GDorisWXPhotoBrowserController alloc] initWithPhotoItems:self.selectItems.copy index:0];
    browser.delegate = self;
    browser.functionTitle = self.functionTitle;
    GDorisAssetItem * asset = [self.selectItems firstObject];
    self.clickIndexPath = [NSIndexPath indexPathForItem:asset.index inSection:0];
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:browser];
    browser.transitioningDelegate = self.transition;
    
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)clickCareamAction
{
    
}

- (void)photoSelectDidFinish
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didFinishPickingAssets:)]) {
        [self.delegate dorisPhotoPicker:self didFinishPickingAssets:self.selectItems];
    }
}

#pragma mark - loadData

- (void)loadPhotoAssetsWithCollection:(XCAssetsGroup *)collection
{
    [super loadPhotoAssetsWithCollection:collection];
    self.collection = collection;
}

#pragma mark - action Method

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)authorizationStatusClick
{
    [GDorisPhotoHelper gotoSystemSettingPage];
}


#pragma mark - GDorisPhotoBrowserDelegate

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didFinishPickingAssets:(NSArray<GDorisAssetItem *> *)assets
{
    [browser dismissViewControllerAnimated:NO completion:nil];
    [self photoSelectDidFinish];
}

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didSelectAsset:(GDorisAssetItem *)asset
{
    asset.isSelected = YES;
    [self override_didSelectAsset:asset];
}

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)picker didDeselectAsset:(GDorisAssetItem *)asset
{
    asset.isSelected = NO;
    [self override_didDeselectAsset:asset];
}

- (BOOL)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser shouldSelectAsset:(GDorisAssetItem *)asset
{
    return [self override_canSelectAsset:asset];
}

- (NSArray *)dorisPhotoBrowserGetSelectAssets:(GDorisBasePhotoBrowserController *)browser
{
    return self.selectItems.copy;
}

#pragma mark - Helper Method

+ (void)showToastHUD:(UIView *)view info:(NSString*)text
{
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:1];
}

@end
