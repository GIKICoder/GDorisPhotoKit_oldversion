//
//  GDorisPhotoBrowserDelegate.h
//  GDoris
//
//  Created by GIKI on 2018/9/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisAsset.h"
NS_ASSUME_NONNULL_BEGIN
@class GDorisBasePhotoBrowserController;
@protocol GDorisPhotoBrowserDelegate <NSObject>

@optional
/**
 选择相册资源完成后回调
 
 @param browser GDorisBasePhotoBrowserController
 @param assets NSArray<PHAsset *>
 */
- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didFinishPickingAssets:(NSArray<GDorisAsset *> *)assets;

/**
 取消图片预览控制器
 
 @param browser GDorisBasePhotoBrowserController
 */
- (void)dorisPhotoBrowserDidCancel:(GDorisBasePhotoBrowserController *)browser;

/**
 判断资源是否可选择
 
 @param browser GDorisBasePhotoBrowserController
 @param asset PHAsset
 @return 是否可选中
 */
- (BOOL)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser shouldSelectAsset:(GDorisAsset *)asset;

/**
 选择相册资源
 
 @param browser GDorisBasePhotoBrowserController
 @param asset PHAsset
 */
- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didSelectAsset:(GDorisAsset *)asset;

/**
 取消选中相册资源
 
 @param browser GDorisBasePhotoBrowserController
 @param asset PHAsset
 */
- (void)dorisPhotoBrowser:(GDorisBasePhotoBrowserController *)browser didDeselectAsset:(GDorisAsset *)asset;

/**
 获取已经选中的相册资源

 @param browser GDorisBasePhotoBrowserController
 @return selectItems
 */
- (NSArray *)dorisPhotoBrowserGetSelectAssets:(GDorisBasePhotoBrowserController *)browser;
@end

NS_ASSUME_NONNULL_END
