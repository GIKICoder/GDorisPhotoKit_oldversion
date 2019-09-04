//
//  GDorisPhotoPickerControllerInternal.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisPhotoPickerBaseCell.h"
#import "GDorisAssetItem.h"
#import "GDorisLivePhotoPickerCell.h"
#import "GDorisGifPhotoPickerCell.h"
#import "GDorisPhotoPickerCameraCell.h"
#import "GDoris3DTouchPreviewController.h"
#import "GDorisBasePhotoBrowserController.h"


@interface GDorisBasePhotoPickerController ()

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic,   weak) NSIndexPath  *clickIndexPath;
@property (nonatomic, assign) CGFloat  cellPadding;
@property (nonatomic, assign) CGFloat  cellColumn;
@property (nonatomic, assign) UIEdgeInsets collectionEdgeInsets;
@property (nonatomic, strong) NSArray  *photoAssets;
@property (nonatomic, strong) GDorisPhotoZoomAnimatedTransition * transition;
@property (nonatomic, strong) NSMutableArray * selectItems;
@property (nonatomic, strong) NSMutableDictionary * selectItemMaps;
@property (nonatomic, assign) BOOL  selectDisabled;

#pragma mark - voerride Method
- (BOOL)override_canSelectAsset:(GDorisAssetItem *)assetModel;
- (void)override_didSelectAsset:(GDorisAssetItem *)assetModel;
- (void)override_didDeselectAsset:(GDorisAssetItem *)assetModel;
- (void)override_collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)override_previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit;

#pragma mark - public Function Method

- (void)performReload:(NSArray*)indexpaths;

- (void)didSelectDisabled:(BOOL)disabled;

/**
 获取当前选中资源类型的最大数量
 
 @param asset <#asset description#>
 @return <#return value description#>
 */
- (NSInteger)getAssetMaxCount:(XCAsset *)asset;


@end
