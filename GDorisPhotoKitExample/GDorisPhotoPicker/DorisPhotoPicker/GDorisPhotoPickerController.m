//
//  GDorisPhotoPickerController.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoPickerController.h"
#import "GDoirsPhotoPickerToolbar.h"
#import "GDorisPhotoAlbumTableView.h"
#import "GAdjustButton.h"
#import "GDorisPhotoPickerControllerInternal.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GNavigationBar.h"
#import "GDorisPhotoHelper.h"
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "GDorisPhotoPickerBrowserController.h"

#define kPhotoPickerToolbarHeight (38+GDoris_TabBarMargin)

@interface GDorisPhotoPickerController ()<GDorisPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GScrollerGestureTransitionDelegate,GDorisZoomPresentingControllerProtocol>
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDoirsPhotoPickerToolbar * pickerToolbar;
@property (nonatomic, strong) GDorisPhotoAlbumTableView * albumListView;
@property (nonatomic, strong) UIButton * titleButton;
@property (nonatomic, strong) NSArray * albumDatas;
@property (nonatomic, strong) XCAssetsGroup * currentGroup;
@property (nonatomic, strong) GScrollerGestureTransition * scrollerTransition;
@property (nonatomic, strong) UIView * notAuthorizedView;
@end

@implementation GDorisPhotoPickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationController.navigationBar.hidden = YES;
        self.navigationController.navigationBarHidden = YES;
    }
    return self;
}

- (instancetype)initWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration
{
    if (!configuration) {
        configuration = [GDorisPhotoPickerConfiguration defaultConfiguration];
    }
    self = [super initWithConfiguration:configuration];
    if (self) {
        self.functionTitle = @"确定";
        self.scrollerGestureEnabled = YES;
        self.transitionBottomOffset = [UIScreen mainScreen].bounds.size.height;
        self.transitionBeginOffset = 120;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar removeFromSuperview];
    [self setupUI];
    [self checkAlbumAuthorizationStatus];
    [self loadScrollerGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.addBySubViews) {
        self.navigationBar.hidden = YES;
        [self.scrollerTransition transitionMove:ScrollerTransitionStateBottom animated:NO completion:nil];
    }
    [self configPickerToolbarState];
}

- (void)loadScrollerGesture
{
    if (!self.scrollerGestureEnabled) {
        return;
    }
    self.scrollerTransition = [GScrollerGestureTransition transitionWithTargetView:self.view scroller:self.collectionView];
    self.scrollerTransition.delegate = self;
    self.scrollerTransition.feedBackEnabled = YES;
    self.scrollerTransition.transitionBottomPosition = self.transitionBottomOffset;
    self.scrollerTransition.beginTransitionPosition = self.transitionBeginOffset;
}

#pragma mark - loadData

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
        __block NSMutableArray * arrayM = [NSMutableArray array];
        [[XCAssetsManager sharedInstance]  enumerateAllAlbumsWithAlbumContentType:weakSelf.configuration.albumType showEmptyAlbum:weakSelf.configuration.emptyAlbumEnabled showSmartAlbumIfSupported:weakSelf.configuration.samrtAlbumEnabled usingBlock:^(XCAssetsGroup * _Nonnull resultAssetsGroup) {
            if (resultAssetsGroup) {
                if (arrayM.count == 0) {
                    XCAssetsGroup * firstGroup = resultAssetsGroup;
                    weakSelf.currentGroup = firstGroup;
                    [weakSelf loadPhotoAssets:firstGroup];
                }
                [arrayM addObject:resultAssetsGroup];
            }
        }];
        weakSelf.albumDatas = arrayM.copy;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.albumListView fulFill:weakSelf.albumDatas selectIndex:weakSelf.albumListView.selectIndex];
            [weakSelf.titleButton setTitle:weakSelf.currentGroup.name forState:UIControlStateNormal];
        });
    });
}

- (void)loadPhotoAssets:(XCAssetsGroup *)assetsGroup
{
    if (!assetsGroup) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf loadPhotoAssetsWithCollection:assetsGroup];
    });
}

#pragma mark - setupUI

- (void)setupUI
{
    [self setupNavigationBar];
    [self setupBottomToolbar];
    [self setupAlbumListView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-kPhotoPickerToolbarHeight);
    }];
    if (self.addBySubViews) {
        self.navigationBar.hidden = YES;
    }
}

- (void)setupNavigationBar
{
    if (!self.navigationBar) {
        self.navigationBar = [GNavigationBar navigationBar];
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
        self.navigationBar.backgroundColor = [UIColor whiteColor];
    }
    self.navigationBar.titleFont = [UIFont systemFontOfSize:18];
    self.navigationBar.titleColor = GDorisColorCreate(@"262626");
    [self.navigationBar removeFromSuperview];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.title = @"相机胶卷";
    GAdjustButton * titleButton = [GAdjustButton buttonWithType:UIButtonTypeCustom];
    titleButton.imagePosition = GAdjustButtonIMGPositionRight;
    [titleButton addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [titleButton setTitleColor: GDorisColorCreate(@"262626") forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:18];
    UIImage * image = [UIImage imageNamed:@"Fire_btn_drop-down_black"];
    UIImage * select = [GDorisPhotoHelper imageByRotate180:image];
    [titleButton setImage:image forState:UIControlStateNormal];
    [titleButton setImage:select forState:UIControlStateSelected];
    self.titleButton = titleButton;
    GNavigationItem * centerItem = [GNavItemFactory createCustomView:titleButton];
    [self.navigationBar setCenterItem:centerItem];
    GNavigationItem * back = [GNavItemFactory createImageButton:[UIImage imageNamed:@"Fire_btn_cancel_black"] highlightImage:[UIImage imageNamed:@"Fire_btn_cancel_black"] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = back;
}

- (void)setupBottomToolbar
{
    self.pickerToolbar = [[GDoirsPhotoPickerToolbar alloc] init];
    [self.view addSubview:self.pickerToolbar];
    [self.pickerToolbar.leftButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.pickerToolbar.centerButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.pickerToolbar.centerButton setImage:[UIImage imageNamed:@"GDoris_picker_wxtoolbar"] forState:UIControlStateSelected];
    [self.pickerToolbar.centerButton setImage:[UIImage imageNamed:@"PhotoLibrary_unselected"] forState:UIControlStateNormal];
    [self.pickerToolbar.rightButton setTitle:self.functionTitle forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.pickerToolbar.photoToolbarClickBlock = ^(DorisPhotoPickerToolbarType itemType) {
        [weakSelf photoToolbarClick:itemType];
    };
    [self.pickerToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kPhotoPickerToolbarHeight);
    }];
}

- (void)setupAlbumListView
{
    self.albumListView = [[GDorisPhotoAlbumTableView alloc] init];
    [self.view addSubview:self.albumListView];
    [self.albumListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.navigationBar.mas_bottom);
    }];

    __weak typeof(self) weakSelf = self;
    self.albumListView.selectPhotoAlbum = ^(XCAssetsGroup * _Nonnull assetsGroup) {
        [weakSelf.titleButton setTitle:assetsGroup.name forState:UIControlStateNormal];
        weakSelf.currentGroup = assetsGroup;
        [weakSelf loadPhotoAssets:assetsGroup];
    };
    self.albumListView.photoAlbumDismiss = ^{
        weakSelf.titleButton.selected = NO;
    };
}

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


#pragma mark - Public Method

- (void)setFunctionTitle:(NSString *)functionTitle
{
    _functionTitle = functionTitle;
    [self.pickerToolbar.rightButton setTitle:functionTitle forState:UIControlStateNormal];
}

- (void)transitionMove:(ScrollerTransitionState)state
{
    [self.scrollerTransition transitionMove:state];
}

- (void)resetPickerToolbarStatus
{
    [self configPickerToolbarState];
}

- (void)reloadData
{
    [self loadPhotoAssets:self.currentGroup];
    [self configPickerToolbarState];
}

- (void)cancelWithAnimation:(BOOL)animated
{
    if (self.addBySubViews) {
        [self.scrollerTransition transitionMove:ScrollerTransitionStateBottom animated:NO completion:nil];
    } else {
        
    }
}

#pragma mark - Override Method

/**
 重置页面选中状态
 */
- (void)resetPageSeletStatus
{
    [super resetPageSeletStatus];
    [self resetPickerToolbarStatus];
}

- (BOOL)override_canSelectAsset:(GDorisAssetItem *)assetModel
{
    CGFloat maxCount = [self getAssetMaxCount:assetModel.asset];
    BOOL canSelect = [super override_canSelectAsset:assetModel];
    if (!canSelect) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
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
    if (self.photoAssets.count <= indexPath.item) {
        return;
    }
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

#pragma mark - Action Method

- (void)cancel
{
    if (self.addBySubViews) {
        [self.scrollerTransition transitionMove:ScrollerTransitionStateBottom];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPickerDidCancel:)]) {
            [self.delegate dorisPhotoPickerDidCancel:self];
        }
        [self dismiss];
    }
}

- (void)dismiss
{
    if ([self.navigationController.viewControllers count] > 1){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)photoToolbarClick:(DorisPhotoPickerToolbarType)itemType
{
    if (itemType == DorisPhotoPickerToolbarLeft) {
        [self previewSelectItems];
    } else if (itemType == DorisPhotoPickerToolbarRight) {
        [self photoSelectDidFinish];
    }
}

- (void)previewSelectItems
{
    if (self.selectItems.count <= 0) {
        return;
    }
    GDorisPhotoPickerBrowserController * browser = [GDorisPhotoPickerBrowserController photoBrowser:self.selectItems.copy index:0];
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

- (void)previewPhotoBrowserAction:(NSInteger)index
{
    GDorisPhotoPickerBrowserController * browser = [GDorisPhotoPickerBrowserController photoBrowser:self.photoAssets index:index];
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

- (void)titleAction:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [self.albumListView show];
    } else {
        [self.albumListView dismiss];
    }
}

- (void)clickCareamAction
{
//    WS(weakSelf);
//    [XCPermissionHelper checkPhotoAlbumResult:^(BOOL AlbumResult) {
//        if (AlbumResult) {
//            [XCPermissionHelper checkCameraResult:^(BOOL result) {
//                if (result) {
//                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//                    imagePickerController.delegate = weakSelf;
//                    imagePickerController.allowsEditing = NO;
//                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//                    if (self.configuration.albumType == XCAlbumContentTypeAll) {
//                        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
//                    } else if (self.configuration.albumType == XCAlbumContentTypeOnlyVideo) {
//                        imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
//                    } else {
//                        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
//                    }
//                    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
//                    [self presentViewController:imagePickerController animated:YES completion:nil];
//                } else {
//                    [XCAlertHelper showAlertWithTitle:@"未获得摄像头权限，是否去设置中开启摄像头权限？" message:nil confirmTitle:@"去设置" cancelTitle:@"取消" preferredStyle:(UIAlertControllerStyleAlert) confirmHandle:^{
//                        [XCApplication gotoSystemSettingPage];
//                    } cancleHandle:^{
//
//                    }];
//                }
//            }];
//        } else {
//            [XCAlertHelper showAlertWithTitle:@"未获得相册权限，是否去设置中开启相册权限？" message:nil confirmTitle:@"去设置" cancelTitle:@"取消" preferredStyle:(UIAlertControllerStyleAlert) confirmHandle:^{
//                [XCApplication gotoSystemSettingPage];
//            } cancleHandle:^{
//
//            }];
//        }
//    }];
}

- (void)photoSelectDidFinish
{
    NSArray * selectItems = self.selectItems.copy;
    __block NSMutableArray * selectAssetsM = [NSMutableArray array];
    [selectItems enumerateObjectsUsingBlock:^(GDorisAssetItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:GDorisAssetItem.class]) {
            [selectAssetsM addObject:obj.asset];
        }
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didFinishPickingAssets:)]) {
        [self.delegate dorisPhotoPicker:self didFinishPickingAssets:selectAssetsM.copy];
    }
}

- (void)configPickerToolbarState
{
    self.pickerToolbar.enabled = (self.selectItems.count > 0);
    if (self.selectItems.count > 0) {
        NSString * string = [NSString stringWithFormat:@"%@(%lu)",self.functionTitle,(unsigned long)self.selectItems.count];
        [self.pickerToolbar.rightButton setTitle:string forState:UIControlStateNormal];
    } else {
        [self.pickerToolbar.rightButton setTitle:self.functionTitle forState:UIControlStateNormal];
    }
}

- (void)authorizationStatusClick
{
    [GDorisPhotoHelper gotoSystemSettingPage];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollerTransition __scrollViewDidScroll:scrollView];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.scrollerTransition __scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.scrollerTransition __scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

#pragma mark - GScrollerGestureTransitionDelegate

- (void)transitionChangedStateFinish:(ScrollerTransitionState)state offsetY:(CGFloat)offsetY animated:(BOOL)animated
{
    if (!self.addBySubViews) {
        if (state == ScrollerTransitionStateBottom) {
            if ([self.navigationController.viewControllers count] > 1){
                [self.navigationController popViewControllerAnimated:NO];
            } else {
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];
            }
        }
        return;
    }
    
    if (state == ScrollerTransitionStateBottom) {
        self.navigationBar.hidden = YES;
        if (self.TransitionChangedState) {
            self.TransitionChangedState(self.scrollerTransition.transitionBottomPosition, NO);
        }
    }
}

- (void)transitionChangedStateBegin:(ScrollerTransitionState)state offsetY:(CGFloat)offsetY
{
    if (self.addBySubViews && state != ScrollerTransitionStateTop) {
        
    }
}

- (void)transitionChangedState:(ScrollerTransitionState)state
                       offsetY:(CGFloat)offsetY
{
    if (!self.addBySubViews) {
        return;
    }
    BOOL showNavBar = (offsetY < self.scrollerTransition.beginTransitionPosition);
    self.navigationBar.hidden = !showNavBar;
    if (self.TransitionChangedState) {
        self.TransitionChangedState(offsetY, showNavBar);
    }
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSInteger index = self.albumListView.selectIndex;
    if (self.albumDatas.count <= index) {
        return;
    }
    XCAssetsGroup * group = [self.albumDatas objectAtIndex:index];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [[XCAssetsManager sharedInstance] saveVideoWithVideoPathURL:movieUrl albumAssetsGroup:group completionBlock:^(XCAsset *asset, NSError *error) {
            if (asset) {
                [self selectFromCamera:asset];
            }
            
        }];
    } else {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [[XCAssetsManager sharedInstance] saveImageWithImageRef:image.CGImage albumAssetsGroup:group orientation:image.imageOrientation completionBlock:^(XCAsset *asset, NSError *error) {
            if (asset) {
                [self selectFromCamera:asset];
            }
        }];
    }
    [picker dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)selectFromCamera:(XCAsset *)asset
{
    [self loadData];
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
