//
//  GDorisPhotoPickerConfiguration.h
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCAssetsManager.h"
NS_ASSUME_NONNULL_BEGIN
@class GDorisPhotoPickerAppearance;
@interface GDorisPhotoPickerConfiguration : NSObject

/**
 相册展示类型
 */
@property (nonatomic, assign) XCAlbumContentType  albumType;

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
 是否开启低内存占用模式
 Default:NO
 开启后快速滚动的情况下会显示模糊图像
 */
@property (nonatomic, assign) BOOL  LowMemoryEnabled;

/**
 第一次加载显示的数量,可快速加载显示.
 Default:40 首屏数量
 */
@property (nonatomic, assign) BOOL  FirstNeedsLoadCount;

/**
 pickerphoto 间距
 */
@property (nonatomic, assign) CGFloat  pickerPadding;

@property (nonatomic, strong) GDorisPhotoPickerAppearance * appearance;
/**
 userInfo
 */
@property (nonatomic, strong) __kindof id userInfo;

+ (GDorisPhotoPickerConfiguration *)defaultConfiguration;
+ (GDorisPhotoPickerConfiguration *)configWithAlbumType:(XCAlbumContentType)type;

@end


@interface GDorisPhotoPickerAppearance : NSObject
///选中照片背景色 selectCountEnabled=NO
@property (nonatomic, strong) UIColor * countBackColor;
///选中照片数量字体 selectCountEnabled=NO
@property (nonatomic, strong) UIFont * countFont;
///选中照片数量字体颜色 selectCountEnabled=NO
@property (nonatomic, strong) UIColor * countColor;
///未选择ICON
@property (nonatomic, strong) UIImage * unselectImage;
///选择ICON selectCountEnabled=YES
@property (nonatomic, strong) UIImage * selectImage;
///picker 图片layer cornerRadius
@property (nonatomic, assign) CGFloat  cornerRadius;
///picker 图片选中边框宽度
@property (nonatomic, assign) CGFloat  selectBorderWidth;
///picker 图片选中边框颜色
@property (nonatomic, strong) UIColor * selectBorderColor;
///picker 图片不可选中的背景颜色
@property (nonatomic, strong) UIColor * disabledColor;
///picker 相机ICON
@property (nonatomic, strong) UIImage * cameraImage;
///picker 标签背景色
@property (nonatomic, strong) UIColor * tagColor;
@end
NS_ASSUME_NONNULL_END
