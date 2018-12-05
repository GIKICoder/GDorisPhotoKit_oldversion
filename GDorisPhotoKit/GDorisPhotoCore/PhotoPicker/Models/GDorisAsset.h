//
//  GDorisAsset.h
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisPhotoKitManager.h"
#import "GDorisPhotoPickerConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisAsset : NSObject

@property (nonatomic, strong) PHAsset  *asset;
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;
@property (nonatomic, assign) GDorisMediaType  meidaType;
@property (nonatomic, assign) GDorisImageSubType  subType;
@property (nonatomic, strong) UIImage * thumbnailImage;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, assign) CGSize  imageSize;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL  isSelected;
@property (nonatomic, assign) BOOL  selectDisabled;
@property (nonatomic, assign) NSInteger  selectIndex;
@property (nonatomic, assign) BOOL  animated;
@property (nonatomic, copy  ) NSString * cellClass;

+ (instancetype)createAsset:(PHAsset*)asset;
+ (instancetype)createAsset:(PHAsset*)asset configuration:(GDorisPhotoPickerConfiguration*)configuration index:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
