//
//  GDorisPhotoBrowserControllerInternal.h
//  GDoris
//
//  Created by GIKI on 2018/9/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisBasePhotoBrowserController.h"
@interface GDorisBasePhotoBrowserController ()

@property (nonatomic, assign) NSInteger  beginIndex;

- (NSIndexPath*)currentIndexPath;

#pragma mark - override Method
- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)browserDidEndDisplayingCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)singleTapContentHandler:(id)data;

- (NSArray<Class> *)registerCellClass;

/**
 图片浏览器滚动位置
 用于显示当前图片的index
 @param index 当前图片的index
 */
- (void)browserDidEndDeceleratingWithIndex:(NSInteger)index;

@end
