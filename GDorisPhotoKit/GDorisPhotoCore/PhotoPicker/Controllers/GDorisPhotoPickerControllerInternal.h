//
//  GDorisPhotoPickerControllerInternal.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoKitManager.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisPhotoPickerBaseCell.h"
#import "GDorisPhotoKitManager.h"
#import "GDorisAsset.h"
#import "GDorisLivePhotoPickerCell.h"
#import "GDorisGifPhotoPickerCell.h"
#import "GDorisPhotoPickerCameraCell.h"
#import "GDoris3DTouchPreviewController.h"
#import "GDorisBasePhotoBrowserController.h"
#import "UIView+GDoris.h"
@interface GDorisBasePhotoPickerController ()

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic,   weak) NSIndexPath  *clickIndexPath;
@property (nonatomic, assign) CGFloat  cellPadding;
@property (nonatomic, assign) CGFloat  cellColumn;
@property (nonatomic, assign) UIEdgeInsets collectionEdgeInsets;
@property (nonatomic, strong) NSArray  *photoAssets;
@property (nonatomic, strong) GDorisPhotoZoomAnimatedTransition * transition;
@property (nonatomic, strong) NSMutableArray * selectItems;
@property (nonatomic, assign) BOOL  selectDisabled;

- (void)performReload:(NSArray*)indexpaths;
- (BOOL)canSelectAsset:(GDorisAsset *)assetModel;
- (void)didSelectAsset:(GDorisAsset *)assetModel;
- (void)didDeselectAsset:(GDorisAsset *)assetModel;
- (void)didSelectDisabled:(BOOL)disabled;
- (void)collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath;

@end
