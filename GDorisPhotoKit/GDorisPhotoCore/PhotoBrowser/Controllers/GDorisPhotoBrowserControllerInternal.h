//
//  GDorisPhotoBrowserControllerInternal.h
//  GDoris
//
//  Created by GIKI on 2018/9/28.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoKitManager.h"
#import "GDorisAsset.h"
#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisBasePhotoBrowserController.h"
@interface GDorisBasePhotoBrowserController ()

@property (nonatomic, assign) NSInteger  beginIndex;

- (NSIndexPath*)currentIndexPath;

#pragma mark - override Method
- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)browserDidEndDisplayingCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)singleTapContentHandler:(GDorisAsset *)data;
@end
