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
#import "GDorisPhotoKitManager.h"
#import "GDorisCollection.h"
@class GDorisBasePhotoPickerController;
@protocol GDorisPhotoPickerDelegate <NSObject>

@optional

/**
 选择相册资源完成后回调

 @param picker GDorisBasePhotoPickerController
 @param assets NSArray<PHAsset *>
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didFinishPickingAssets:(NSArray<PHAsset *> *)assets;

/**
 取消相册资源选择控制器

 @param picker GDorisBasePhotoPickerController
 */
- (void)dorisPhotoPickerDidCancel:(GDorisBasePhotoPickerController *)picker;

/**
 判断资源是否可选择

 @param picker GDorisBasePhotoPickerController
 @param asset PHAsset
 @return 是否可选中
 */
- (BOOL)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker shouldSelectAsset:(PHAsset *)asset;

/**
 选择相册资源

 @param picker GDorisBasePhotoPickerController
 @param asset PHAsset
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didSelectAsset:(PHAsset *)asset;

/**
 取消选中相册资源

 @param picker GDorisBasePhotoPickerController
 @param asset PHAsset
 */
- (void)dorisPhotoPicker:(GDorisBasePhotoPickerController *)picker didDeselectAsset:(PHAsset *)asset;

@end


NS_ASSUME_NONNULL_BEGIN

@class GDorisPhotoPickerDelegate;
@interface GDorisBasePhotoPickerController : UIViewController

- (instancetype)initWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration delegate:(GDorisPhotoPickerDelegate *)delegate;

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
 DorisPhotoPicker 最大选择数量
 Default: MaxInteger
 */
@property (nonatomic, assign) NSInteger  maxSelectCount;

@property (nonatomic, strong) NSArray * photoPickerHandlerChains;

- (void)loadPhotoAssetsWithCollection:(GDorisCollection *)collection;

@end

NS_ASSUME_NONNULL_END
