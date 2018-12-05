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
@interface GDorisWXPhotoPickerController ()<UIAlertViewDelegate,GDorisZoomPresentingControllerProtocol,GDorisPhotoBrowserDelegate>
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisCollection * collection;
@property (nonatomic, strong) GDorisWXToolbar * wxToolbar;
@property (nonatomic, strong) UIAlertView * msgAlert;
@end

@implementation GDorisWXPhotoPickerController

+ (instancetype)wxPhotoPickerControllerDelegate:(GDorisPhotoPickerDelegate *)delegate collection:(GDorisCollection *)collection
{
    GDorisPhotoPickerConfiguration * wxconfig = [GDorisPhotoPickerConfiguration defaultWXConfiguration];
    wxconfig.gestureSelectEnabled = YES;
    GDorisWXPhotoPickerController *vc = [[GDorisWXPhotoPickerController alloc] initWithConfiguration:wxconfig delegate:delegate];
    [vc loadPhotoAssetsWithCollection:collection];
    return vc;
}

+ (instancetype)wxPhotoPickerControllerDelegate:(GDorisPhotoPickerDelegate *)delegate
{
    return [GDorisWXPhotoPickerController wxPhotoPickerControllerDelegate:delegate collection:nil];
}

- (void)presentWXPhotoPickerController:(UIViewController *)targetController
{
    GDorisWXAlbumViewController * albumVC = [[GDorisWXAlbumViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:albumVC];
    [albumVC.navigationController pushViewController:self animated:NO];
    [targetController presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.maxSelectCount = 9;
    [self loadNavigationbar];
    [self loadWXToolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ///需要设置info.plist 将 View controller-based status bar appearance 的值设置为NO
    ///否则不生效
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews
{
    self.collectionView.frame = CGRectMake(0, G_NAV_HEIGHT, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-G_NAV_HEIGHT-self.wxToolbar.g_height);
}

- (BOOL)canSelectAsset:(GDorisAsset *)assetModel
{
    if (self.selectItems.count >= self.maxSelectCount) {
        if (!self.msgAlert) {
            NSString * msg = [NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)self.maxSelectCount];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
            [alert show];
            self.msgAlert = alert;
        }
        
    }
    return [super canSelectAsset:assetModel];
}
- (void)didSelectAsset:(GDorisAsset *)assetModel
{
    [super didSelectAsset:assetModel];
    if (self.selectItems.count == self.maxSelectCount) {
        if (!self.selectDisabled) {
            [self didSelectDisabled:YES];
        }
    }
    self.wxToolbar.enabled = (self.selectItems.count > 0);
    NSString * string = [NSString stringWithFormat:@"发送(%lu)",(unsigned long)self.selectItems.count];
    [self.wxToolbar.rightButton setTitle:string forState:UIControlStateNormal];
}

- (void)didDeselectAsset:(GDorisAsset *)assetModel
{
    [super didDeselectAsset:assetModel];
    if (self.selectDisabled) {
        [self didSelectDisabled:NO];
    }
    self.wxToolbar.enabled = (self.selectItems.count > 0);
    NSString * string = [NSString stringWithFormat:@"发送(%lu)",(unsigned long)self.selectItems.count];
    if (self.selectItems.count == 0) {
        string = @"发送";
    }
    [self.wxToolbar.rightButton setTitle:string forState:UIControlStateNormal];
}

- (void)collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    self.clickIndexPath = indexPath;
    GDorisWXPhotoBrowserController * browser = [GDorisWXPhotoBrowserController photoBrowserWithDorisAssets:self.photoAssets beginIndex:indexPath.item];
    browser.delegate = self;
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:browser];
    browser.transitioningDelegate = self.transition;
    [self presentViewController:browser animated:YES completion:nil];
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
    self.wxToolbar = [[GDorisWXToolbar alloc] initWithFrame:CGRectMake(0, G_SCREEN_HEIGHT-44, G_SCREEN_WIDTH, 44)];
    [self.view addSubview:self.wxToolbar];
    [self.wxToolbar.leftButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar"] forState:UIControlStateSelected];
    [self.wxToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar_normal"] forState:UIControlStateNormal];
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

- (void)presentPhotoBrowser
{
    if (self.selectItems.count <= 0) {
        return;
    }
    GDorisWXPhotoBrowserController * browser = [GDorisWXPhotoBrowserController photoBrowserWithDorisAssets:self.selectItems.copy beginIndex:0];
    browser.delegate = self;
    GDorisAsset * asset = [self.selectItems firstObject];
    self.clickIndexPath = [NSIndexPath indexPathForItem:asset.index inSection:0];
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:browser];
    browser.transitioningDelegate = self.transition;
    
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)photoSelectDidFinish
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didFinishPickingAssets:)]) {
        [self.delegate dorisPhotoPicker:self didFinishPickingAssets:self.selectItems];
    }
}

#pragma mark - loadData

- (void)loadPhotoAssetsWithCollection:(GDorisCollection *)collection
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.msgAlert = nil;
}

#pragma mark - GDorisPhotoBrowserDelegate

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didFinishPickingAssets:(NSArray<GDorisAsset *> *)assets
{
    [self photoSelectDidFinish];
}

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didSelectAsset:(GDorisAsset *)asset
{
    [self didSelectAsset:asset];
}

- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)picker didDeselectAsset:(GDorisAsset *)asset
{
    [self didDeselectAsset:asset];
}

- (BOOL)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser shouldSelectAsset:(GDorisAsset *)asset
{
    return [self canSelectAsset:asset];
}

- (NSArray *)dorisPhotoBrowserGetSelectAssets:(GDorisBasePhotoBrowserController *)browser
{
    return self.selectItems.copy;
}
@end
