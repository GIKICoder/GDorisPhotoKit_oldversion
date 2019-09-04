//
//  GDorisBasePhotoPickerController.h
//  GDoris
//
//  Created by GIKI on 2018/8/8.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoPickerConfiguration.h"
#import "GDorisPhotoActionHandler.h"
#import "XCAssetsManager.h"
#import "GDorisAssetItem.h"

NS_ASSUME_NONNULL_BEGIN

@class GDorisBasePhotoPickerController;
@protocol GDorisPhotoPickerDelegate <NSObject>

@optional

/**
 选择相册资源完成后回调

 @param picker GDorisBasePhotoPickerController
 @param assets NSArray<XCAsset *>
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didFinishPickingAssets:(NSArray<XCAsset *> *)assets;

/**
 取消相册资源选择控制器

 @param picker GDorisBasePhotoPickerController
 */
- (void)dorisPhotoPickerDidCancel:(GDorisBasePhotoPickerController *)picker;

/**
 判断资源是否可选择

 @param picker GDorisBasePhotoPickerController
 @param asset XCAsset
 @return 是否可选中
 */
- (BOOL)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker shouldSelectAsset:(XCAsset *)asset;

/**
 选择相册资源

 @param picker GDorisBasePhotoPickerController
 @param asset XCAsset
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didSelectAsset:(XCAsset *)asset;

/**
 取消选中相册资源

 @param picker GDorisBasePhotoPickerController
 @param asset XCAsset
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didDeselectAsset:(XCAsset *)asset;

/**
 选中的asset资源改变时回调

 @param picker picker description
 @param assets assets description
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker selectItemsChanged:(NSArray<XCAsset *> *)assets;
@end


@class GDorisPhotoPickerDelegate;
@interface GDorisBasePhotoPickerController : UIViewController

- (instancetype)initWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration;

@property (nonatomic, strong,readonly) UICollectionView * collectionView;

/**
 DorisPhotoPicker Configuration
 */
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;

/**
 DorisPhotoPicker Delegate
 */
@property (nonatomic, weak  ) id <GDorisPhotoPickerDelegate>  delegate;

/**
 初始选择项
 */
@property (nonatomic, strong) NSArray<XCAsset *> * initializerSelects;

/**
 DorisPhotoPicker 最大选择数量
 Default: MaxInteger
 @breif: selectCountRegular中有对应MediaType规则,maxSelectCount不生效
 */
@property (nonatomic, assign) NSInteger  maxSelectCount;

/**
 DorisPhotoPicker 最大选择数量规则Map
 Default: nil
 @breif: Key:@(XCAssetType) value:@(MaxCount)
 */
@property (nonatomic, strong) NSDictionary * selectCountRegular;

/**
 只可以选择一种资源
 Default: NO
 */
@property (nonatomic, assign) BOOL  onlySelectOneMediaType;

/**
 当前仅可选择的类型
 Default: XCAssetTypeNone
 */
@property (nonatomic, assign) XCAssetType  onlyEnableSelectAssetType;

@property (nonatomic, strong) NSArray * photoPickerHandlerChains;


#pragma mark - public Method

/**
 加载PhotoKit collection 资源

 @param collection XCAssetsGroup
 */
- (void)loadPhotoAssetsWithCollection:(XCAssetsGroup *)collection;

/**
 重置页面选中状态
 */
- (void)resetPageSeletStatus;


@end

NS_ASSUME_NONNULL_END
