//
//  GDorisPhotoPickerConfiguration.h
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisPhotoKitManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoPickerConfiguration : NSObject

/**
 相册展示类型
 */
@property (nonatomic, assign) GDorisMediaType  mediaType;

/**
 是否展示空相册
 */
@property (nonatomic, assign) BOOL  emptyAlbumEnabled;

/**
 是否展示智能相册
 */
@property (nonatomic, assign) BOOL  samrtAlbumEnabled;

/**
 是否倒叙输出相册图片
 default：NO
 */
@property (nonatomic, assign) BOOL  isReveres;

/**
 是否展示LivePhoto
 @available: iOS 9.0
 */
@property (nonatomic, assign) BOOL  livePhotoEnabled;

/**
 是否展示Gif
 */
@property (nonatomic, assign) BOOL  gifPhotoEnabled;

/**
 是否支持手势选择
 */
@property (nonatomic, assign) BOOL  gestureSelectEnabled;

/**
 是否在相册选择展示相机图标
 */
@property (nonatomic, assign) BOOL  showCamera;

/**
 是否在相册选择展示实时相机图标
 */
@property (nonatomic, assign) BOOL  showLiveCamera;

/**
 是否支持3Dtouch预览
 */
@property (nonatomic, assign) BOOL  can3DTouchPreview;

/**
 是否开启图片选择框动画
 */
@property (nonatomic, assign) BOOL  selectAnimated;

/**
 是否开启图片选择框显示选择数字
 */
@property (nonatomic, assign) BOOL  selectCountEnabled;

/**
 pickerphoto 间距
 */
@property (nonatomic, assign) CGFloat  pickerPadding;

/**
 userInfo
 */
@property (nonatomic, strong) __kindof id userInfo;

+ (GDorisPhotoPickerConfiguration *)defaultWXConfiguration;
@end

NS_ASSUME_NONNULL_END
