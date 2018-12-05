//
//  GDorisPhotoKitManager.h
//  GDoris
//
//  Created by GIKI on 2018/8/7.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "GDorisPhotoHelper.h"

#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#elif __has_include(<YYWebImage/YYImage.h>)
#import <YYWebImage/YYImage.h>
#elif __has_include("YYImage.h")
#import "YYImage.h"
#else
#define GDorisWithoutYYImageInclude
#endif

#ifdef GDorisWithoutYYImageInclude
#if __has_include(<FLAnimatedImage/FLAnimatedImage.h>)
#import <FLAnimatedImage/FLAnimatedImage.h>
#elif __has_include("FLAnimatedImage.h")
#import "FLAnimatedImage.h"
#else
#define GDorisWithoutFLAnimatedImageInclude
#endif
#endif


/**
 安全线程唤起函数
 @param block code invoke
 */
static inline void GSafeInvokeThread(dispatch_block_t block) {
    
    if ([NSThread isMainThread]) {
        if (block) {block();}
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block) {block();}
        });
    }
}

static inline NSError * GComposeError(NSInteger code,NSString *errorInfo) {
    NSDictionary *userInfo = @{};
    if (errorInfo.length > 0) {
        userInfo = @{NSLocalizedFailureReasonErrorKey:errorInfo};
    }
    return [NSError errorWithDomain:GDorisPhotoErrorDomain code:code userInfo:userInfo];
}

/**
 相册授权状态
 
 - GDorisPhotoAuthorizationStatus_reject: 拒绝
 - GDorisPhotoAuthorizationStatus_authorize: 已经授权
 - GDorisPhotoAuthorizationStatus_notDetermined: 不明确
 */
typedef NS_ENUM(NSUInteger, GDorisPhotoAuthorizationStatus) {
    GDorisPhotoAuthorizationStatus_reject,
    GDorisPhotoAuthorizationStatus_authorize,
    GDorisPhotoAuthorizationStatus_notDetermined,
};

/**
 相册资源类型
 
 - GDorisMediaTypeAll: 所有类型
 - GDorisMediaTypeImage: 图片
 - GDorisMediaTypeVideo: 视频
 - GDorisMediaTypeAudio: 音频
 */
typedef NS_ENUM(NSUInteger, GDorisMediaType) {
    GDorisMediaTypeAll,
    GDorisMediaTypeImage,
    GDorisMediaTypeVideo,
    GDorisMediaTypeAudio,
};

/**
 相册中图片资源类型
 
 - GDorisImageSubTypeNone:
 - GDorisImageSubTypeImage: 图片
 - GDorisImageSubTypeLivePhoto: livePhoto
 - GDorisImageSubTypeGIF: GIF
 */
typedef NS_ENUM(NSUInteger, GDorisImageSubType) {
    GDorisImageSubTypeNone,
    GDorisImageSubTypeImage,
    GDorisImageSubTypeLivePhoto,
    GDorisImageSubTypeGIF,
};


@interface GDorisPhotoKitManager : NSObject

@property (nonatomic, strong, readonly) PHCachingImageManager * cachingImageManager;

+ (instancetype)sharedInstance;

#pragma mark - 系统授权
/**
 获取相册的授权状态

 @return 相册授权状态
 */
+ (GDorisPhotoAuthorizationStatus)authorizationStatus;

/**
 相册访问授权

 @param handler 状态回调(safeThread)
 */
+ (void)requestAuthorization:(void (^)(GDorisPhotoAuthorizationStatus status))handler;

#pragma mark - 相册资源获取

/**
 获取相册中的所有相册
 @breif：包含空相册
 @return <PHAssetCollection *>
 */
+ (NSArray<PHAssetCollection *> *)fetchAllPhotoCollections;

/**
 获取某类型的相册
 @breif：自动过滤空相册
 @param mediaType GDorisMediaType
 @return <PHAssetCollection *>
 */
+ (NSArray<PHAssetCollection *> *)fetchAllPhotoCollectionWithMediaType:(GDorisMediaType)mediaType;

/**
 创建一个相册筛选条件
 
 @param mediaType 筛选类型（GDorisMediaType）
 @param includeHiddenAssets 是否包含隐藏图片(默认false)
 @param includeAllBurstAssets 是否包含连拍图片(默认false)
 @return PHFetchOptions
 */
+ (PHFetchOptions *)createFetchOptionsWithMediaType:(GDorisMediaType)mediaType includeHiddenAssets:(BOOL)includeHiddenAssets includeAllBurstAssets:(BOOL)includeAllBurstAssets;
+ (PHFetchOptions *)createFetchOptionsWithMediaType:(GDorisMediaType)mediaType;

#pragma mark - 相册资源存储

/**
 保存图片至相册
 
 @param image UIImage
 @param completion safeThread
 */
+ (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

/**
 保存图片至相册
 
 @param imageURL NSURL
 @param completion safeThread
 */
+ (void)saveImagePath:(NSURL *)imageURL completion:(void (^)(NSError *error))completion;

/**
 保存视频至相册
 
 @param videoURL NSURL
 @param completion safeThread
 */
+ (void)saveVideoPath:(NSURL *)videoURL completion:(void (^)(NSError *error))completion;

/**
 保存资源至相册
 
 @param params
 @"image":UIImage图片存储
 @"imageURL":图片资源路径
 @"videoURL":视频资源路径
 @"AssetCollection":PHAssetCollection指定相册
 @param completionHandler completionHandler (safeThread)
 */
+ (void)savePhotoWithParams:(NSDictionary *)params withCompletionHandler:(void (^)(BOOL success,NSError *error))completionHandler;
@end

@interface GDorisPhotoKitManager (PHAsset)

/**
 获取相册中最近的一个资源

 @param mediaType 要获取的资源类型
 @return PHAsset
 */
+ (PHAsset *)fetchRecentAsset:(GDorisMediaType)mediaType;

/**
 获取photo类型

 @param asset PHAsset
 @return GDorisMediaType
 */
+ (GDorisMediaType)meidaType:(PHAsset *)asset;

/**
 获取图片的子类型
 
 @param asset PHAsset
 @return GDorisImageSubType
 */
+ (GDorisImageSubType)mediaSubType:(PHAsset *)asset;

/**
 获取PHAsset原图

 @param asset PHAsset
 @return UIImage
 */
- (UIImage *)imageByOrigin:(PHAsset*)asset;

/**
 异步获取PHAsset原图

 @param asset PHAsset
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler 如果有网络请求，加载进度 NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)imageByOrigin:(PHAsset*)asset completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler;

/**
 获取PHAsset缩略图

 @param asset PHAsset
 @param size 缩略图尺寸
 @return UIImage
 */
- (UIImage *)imageByThumbnail:(PHAsset *)asset size:(CGSize)size;

/**
 异步获取PHAsset原图
 
 @param asset PHAsset
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @return PHImageRequestID
 */
- (PHImageRequestID)imageByThumbnail:(PHAsset*)asset size:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion;

/**
 获取PHAsset预览图

 @param asset PHAsset
 @return UIImage
 */
- (UIImage *)imageByPreview:(PHAsset *)asset;

/**
 异步获取PHAsset预览图

 @param asset PHAsset
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)imageByPreview:(PHAsset*)asset completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler;

/**
 异步获取LivePhoto

 @param asset PHAsset
 @param size 获取图片尺寸
 @param completion 会被多次调用
 @param progressHandler NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)imageByLivePhoto:(PHAsset *)asset size:(CGSize)size completion:(void (^)(PHLivePhoto *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler API_AVAILABLE(ios(9.1));

/**
 获取ImageData

 @param asset PHAsset
 @param completion <#completion description#>
 */
- (PHImageRequestID)imageByData:(PHAsset *)asset completion:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completion;

@end

@interface GDorisPhotoKitManager (PHAssetCollection)

/**
 获取相册里的所有资源

 @param assetCollection PHAssetCollection
 @param mediaType GDorisMediaType
 @param isReveres 是否倒序输出 default NO
 @return NSArray<PHAsset *>
 */
+ (NSArray<PHAsset *> *)fetchAllAssets:(PHAssetCollection *)assetCollection mediaType:(GDorisMediaType)mediaType isReverse:(BOOL)isReveres;
+ (NSArray<PHAsset *> *)fetchAllAssets:(PHAssetCollection *)assetCollection mediaType:(GDorisMediaType)mediaType;

@end

@interface PHAsset (GDoirs)

/**
 获取photo类型
 
 @return GDorisMediaType
 */
- (GDorisMediaType)photoType;

/**
 获取图片的子类型
 
 @return GDorisImageSubType
 */
- (GDorisImageSubType)mediaSubType;

/**
 获取PHAsset原图

 @return UIImage
 */
- (UIImage *)originImage;

/**
 异步获取PHAsset原图

 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler 如果有网络请求，加载进度 NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler;

/**
 获取PHAsset缩略图

 @param size 缩略图尺寸
 @return UIImage
 */
- (UIImage *)thumbnailImageWithSize:(CGSize)size;

/**
 异步获取PHAsset原图
 
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion;

/**
 获取PHAsset预览图

 @return UIImage
 */
- (UIImage *)previewImage;

/**
 异步获取PHAsset预览图

 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler;

/**
 获取LivePhoto缩略图
 
 @param size 缩略图尺寸
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncLivePhotoWithSize:(CGSize)size completion:(void(^)(PHLivePhoto * result))completion API_AVAILABLE(ios(9.1));

/**
 异步获取imageData

 @param completion <#completion description#>
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncImageData:(void(^)(NSData * result))completion;
@end


@interface PHAssetCollection (GDoris)

/**
 获取相册名称
 */
- (NSString *)name;

/**
 获取相册里资源的数量
 */
- (NSInteger)count;

/**
 获取相册里mediaType的数量

 @param mediaType GDorisMediaType
 */
- (NSInteger)countWithMediaType:(GDorisMediaType)mediaType;

/**
 获取PHFetchResult
 */
- (PHFetchResult *)fetchResult;

/**
 获取相册里mediaType的PHFetchResult
 
 @param mediaType GDorisMediaType
 */
- (PHFetchResult *)fetchResultWithMediaType:(GDorisMediaType)mediaType;

/**
 获取相册封面图片
 */
- (UIImage *)coverImage:(CGSize)size;

@end

