//
//  GDorisAssetItem.h
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCAssetsManager.h"
#import "GDorisPhotoPickerConfiguration.h"
#import "IGDorisPhotoItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisAssetItem : NSObject<IGDorisPhotoItem>

@property (nonatomic, strong) XCAsset * asset;
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;

@property (nonatomic, strong) UIImage * thumbImage;
@property (nonatomic, assign) BOOL  iscamera;
@property (nonatomic, assign) CGSize  imageSize;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL  isSelected;
@property (nonatomic, assign) BOOL  selectDisabled;
@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) BOOL  animated;
@property (nonatomic, copy  ) NSString * cellClass;

#pragma mark - IGDorisPhotoItem
@property (nonatomic, assign) NSInteger  itemIndex;
@property (nonatomic, assign) BOOL  isVideo;
@property (nonatomic, strong) NSArray * videoURLArray;

+ (instancetype)createAssetItem:(XCAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index;
+ (instancetype)createAssetItem:(XCAsset*)asset index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
