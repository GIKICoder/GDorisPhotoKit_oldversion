//
//  GDorisPhotoKitManager.m
//  GDoris
//
//  Created by GIKI on 2018/8/7.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoKitManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
@interface GDorisPhotoKitManager()
@property (nonatomic, strong, readwrite) PHCachingImageManager * cachingImageManager;
@end

@implementation GDorisPhotoKitManager

+ (instancetype)sharedInstance
{
    static GDorisPhotoKitManager *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[GDorisPhotoKitManager alloc] init];
    });
    return inst;
}

/**
 提供获取缩略图和原图像或视频等方法,优化了预加载大量资源的功能。
 保证工作范围内容只创建一个 PHCachingImageManager 实例
 @return PHCachingImageManager
 */
- (PHCachingImageManager *)cachingImageManager
{
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

/**
 获取相册的授权状态
 
 @return 相册授权状态
 */
+ (GDorisPhotoAuthorizationStatus)authorizationStatus
{
    __block GDorisPhotoAuthorizationStatus status;
    
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    if (authorizationStatus == PHAuthorizationStatusRestricted || authorizationStatus == PHAuthorizationStatusDenied) {
        status = GDorisPhotoAuthorizationStatus_reject;
    } else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
        status = GDorisPhotoAuthorizationStatus_notDetermined;
    } else {
        status = GDorisPhotoAuthorizationStatus_authorize;
    }
    return status;
}

/**
 相册访问授权
 
 @param handler 状态回调(safeThread)
 */
+ (void)requestAuthorization:(void (^)(GDorisPhotoAuthorizationStatus status))handler
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        GDorisPhotoAuthorizationStatus gstatus;
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            gstatus = GDorisPhotoAuthorizationStatus_reject;
        } else if (status == PHAuthorizationStatusNotDetermined) {
            gstatus = GDorisPhotoAuthorizationStatus_notDetermined;
        } else {
            gstatus = GDorisPhotoAuthorizationStatus_authorize;
        }
        GSafeInvokeThread(^{
            if (handler) {
                handler(gstatus);
            }
        });
    }];
}

/**
 获取相册中的所有相册
 @breif：包含空相册
 @return <PHAssetCollection *>
 */
+ (NSArray<PHAssetCollection *> *)fetchAllPhotoCollections
{
    return [[self class] fetchAllPhotoCollectionWithMediaType:GDorisMediaTypeAll];
}

/**
 获取某类型的相册
 @breif：GDorisMediaTypeAll：获取所有相册， other：自动过滤空相册
 @param mediaType GDorisMediaType
 @return <PHAssetCollection *>
 */
+ (NSArray<PHAssetCollection *> *)fetchAllPhotoCollectionWithMediaType:(GDorisMediaType)mediaType
{
    PHFetchOptions *fetchOptions = [[self class] createFetchOptionsWithMediaType:mediaType includeHiddenAssets:NO includeAllBurstAssets:NO];
    __block NSMutableArray * collections = [NSMutableArray array];
    
    /// fetch PHAssetCollectionTypeSmartAlbum
    PHFetchResult  *smartAlbumResult  = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [smartAlbumResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *collection = obj;
            PHFetchResult *result =  [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            if (result.count > 0) { //
                // 相机胶卷
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    [collections insertObject:collection atIndex:0];
                } else {
                    [collections addObject:collection];
                }
            }
        }
    }];
    
    /// fetch UserCollections
    PHFetchResult *userCollectionResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [userCollectionResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *collection = obj;
            PHFetchResult *result =  [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            if (result.count > 0) { //
                [collections addObject:collection];
            }
        }
    }];
    
    /// fetch PHAssetCollectionTypeAlbum 云同步相册
    PHFetchResult *macCollectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    [macCollectionResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *collection = obj;
            PHFetchResult *result =  [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            if (result.count > 0) { //
                [collections addObject:collection];
            }
        }
    }];
    return collections.copy;
}

/**
 创建一个相册筛选条件
 
 @param mediaType 筛选类型（GDorisMediaType）
 @return PHFetchOptions
 */
+ (PHFetchOptions *)createFetchOptionsWithMediaType:(GDorisMediaType)mediaType
{
    return [[self class] createFetchOptionsWithMediaType:mediaType includeHiddenAssets:NO includeAllBurstAssets:NO];
}

/**
 创建一个相册筛选条件
 
 @param mediaType 筛选类型（GDorisMediaType）
 @param includeHiddenAssets 是否包含隐藏图片(默认false)
 @param includeAllBurstAssets 是否包含连拍图片(默认false)
 @return PHFetchOptions
 */
+ (PHFetchOptions *)createFetchOptionsWithMediaType:(GDorisMediaType)mediaType includeHiddenAssets:(BOOL)includeHiddenAssets includeAllBurstAssets:(BOOL)includeAllBurstAssets
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.includeHiddenAssets = includeHiddenAssets;
    options.includeAllBurstAssets = includeAllBurstAssets;
    switch (mediaType) {
        case GDorisMediaTypeAudio:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeAudio];
            break;
        case GDorisMediaTypeImage:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeImage];
            break;
        case GDorisMediaTypeVideo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
    return options;
}

/**
 保存图片至相册
 
 @param image UIImage
 @param completion safeThread
 */
+ (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion
{
    if (!image) {
        NSParameterAssert(nil);
        if (completion) {
            completion(GComposeError(102,@"Image为nil"));
        }
    }
    NSDictionary * params = @{@"image":image};
    [[self class] savePhotoWithParams:params withCompletionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

/**
 保存图片至相册
 
 @param imageURL NSURL
 @param completion safeThread
 */
+ (void)saveImagePath:(NSURL *)imageURL completion:(void (^)(NSError *error))completion
{
    if (!imageURL) {
        NSParameterAssert(nil);
        if (completion) {
            completion(GComposeError(102,@"Image为nil"));
        }
    }
    NSDictionary * params = @{@"imageURL":imageURL};
    [[self class] savePhotoWithParams:params withCompletionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

/**
 保存视频至相册
 
 @param videoURL NSURL
 @param completion safeThread
 */
+ (void)saveVideoPath:(NSURL *)videoURL completion:(void (^)(NSError *error))completion
{
    if (!videoURL) {
        NSParameterAssert(nil);
        if (completion) {
            completion(GComposeError(102,@"videoURL为nil"));
        }
    }
    NSDictionary * params = @{@"videoURL":videoURL};
    [[self class] savePhotoWithParams:params withCompletionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

/**
 保存图片
 
 @param params
 @"image":UIImage图片存储
 @"imageURL":图片资源路径
 @"videoURL":视频资源路径
 @"AssetCollection":PHAssetCollection指定相册
 @param completionHandler completionHandler (safeThread)
 */
+ (void)savePhotoWithParams:(NSDictionary *)params withCompletionHandler:(void (^)(BOOL success,NSError *error))completionHandler
{
    UIImage *image = params[@"image"];
    NSURL *imageURL = params[@"imageURL"];
    NSURL *videoURL = params[@"videoURL"];
    PHAssetCollection *collection = params[@"AssetCollection"];
    if (!image && !imageURL && !videoURL) {
        NSParameterAssert(nil);
        if (completionHandler) {
            completionHandler(NO,GComposeError(102,@"没有传入需要存储的资源或者资源路径"));
        }
    }
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        PHAssetChangeRequest *saveRequest = nil;
        if (image) {
            saveRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } else if(imageURL) {
            saveRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageURL];
        } else if(videoURL) {
            saveRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:imageURL];
        } else {
            NSParameterAssert(nil);
        }
        saveRequest.creationDate = [NSDate date];
        /// 智能相册无法被保存
        if (collection && collection.assetCollectionType == PHAssetCollectionTypeAlbum) {
            PHAssetCollectionChangeRequest * collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            PHObjectPlaceholder *holder = [saveRequest placeholderForCreatedAsset];
            if(holder) {
                [collectionRequest addAssets:@[holder]];
            }
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        GSafeInvokeThread(^{
            if (completionHandler) {
                completionHandler(success,error);
            }
        });
    }];
}
@end

@implementation GDorisPhotoKitManager (PHAsset)

/**
 获取相册中最近的一个资源
 
 @param mediaType 要获取的资源类型
 @return PHAsset
 */
+ (PHAsset *)fetchRecentAsset:(GDorisMediaType)mediaType
{
    PHFetchOptions *options = [[self class] createFetchOptionsWithMediaType:mediaType];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
    return fetchResults.firstObject;
}

/**
 获取photo类型
 
 @param asset PHAsset
 @return GDorisMediaType
 */
+ (GDorisMediaType)meidaType:(PHAsset *)asset
{
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
            return GDorisMediaTypeImage;
            break;
        case PHAssetMediaTypeVideo:
            return GDorisMediaTypeVideo;
            break;
        case PHAssetMediaTypeAudio:
            return GDorisMediaTypeAudio;
            break;
        default:
            return GDorisMediaTypeAll;
            break;
    }
}

/**
 获取图片的子类型
 
 @param asset PHAsset
 @return GDorisImageSubType
 */
+ (GDorisImageSubType)mediaSubType:(PHAsset *)asset
{
    if (asset.mediaType == PHAssetMediaTypeImage) {
        if ([[asset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
            return GDorisImageSubTypeGIF;
        } else {
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                    return GDorisImageSubTypeLivePhoto;
                }
            }
        }
        return GDorisImageSubTypeImage;
    } else {
        return GDorisImageSubTypeNone;
    }
}

/**
 获取PHAsset原图
 
 @param asset PHAsset
 @return UIImage
 */
- (UIImage *)imageByOrigin:(PHAsset*)asset
{
    __block UIImage *originImage = nil;
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.synchronous = YES;
    [self.cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        originImage = result;
    }];
    return originImage;
}

- (PHImageRequestID)imageByOrigin:(PHAsset*)asset completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler
{
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.networkAccessAllowed = YES;
    requestOptions.progressHandler = progressHandler;
    return [self.cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            completion(result, info);
        }
    }];
    
}

/**
 获取PHAsset缩略图
 
 @param asset PHAsset
 @param size 缩略图尺寸
 @return UIImage
 */
- (UIImage *)imageByThumbnail:(PHAsset *)asset size:(CGSize)size
{
    return [self imageByThumbnail:asset resizeMode:PHImageRequestOptionsResizeModeFast  size:size];
}

- (UIImage *)imageByThumbnail:(PHAsset *)asset resizeMode:(PHImageRequestOptionsResizeMode)mode  size:(CGSize)size
{
    __block UIImage *temp = nil;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize tempSize = CGSizeMake(size.width * scale, size.height * scale);
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = YES;
    requestOptions.resizeMode = mode; //
    [self.cachingImageManager requestImageForAsset:asset targetSize:tempSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        temp = result;
    }];
    return temp;
}

- (PHImageRequestID)imageByThumbnail:(PHAsset*)asset size:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize tempSize = CGSizeMake(size.width * scale, size.height * scale);
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [self.cachingImageManager requestImageForAsset:asset targetSize:tempSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (completion) {
            completion(result,info);
        }
    }];
}

/**
 获取PHAsset预览图
 
 @param asset PHAsset
 @return UIImage
 */
- (UIImage *)imageByPreview:(PHAsset *)asset
{
    __block UIImage *temp = nil;
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.networkAccessAllowed = YES;
    requestOptions.synchronous = YES;
    [self.cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(sw, sh) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        temp = result;
    }];
    return temp;
}

- (PHImageRequestID)imageByPreview:(PHAsset*)asset completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler
{
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    imageRequestOptions.progressHandler = progressHandler;
    return [self.cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];
}


- (PHImageRequestID)imageByLivePhoto:(PHAsset *)asset size:(CGSize)size completion:(void (^)(PHLivePhoto *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler
API_AVAILABLE(ios(9.1)){
    if ([self.cachingImageManager respondsToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.progressHandler = progressHandler;
            return [self.cachingImageManager requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:completion];
        } else {
            if (completion) {
                completion(nil,nil);
            }
            return 0;
        }
       
    } else {
        if (completion) {
            completion(nil,nil);
        }
        return 0;
    }
}

- (PHImageRequestID)imageByData:(PHAsset *)asset completion:(void(^)(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info))completion
{
    if (asset.photoType != GDorisMediaTypeImage) {
        if (completion) {
            completion(nil, nil, 0, nil);
        }
        return 0;
    }
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = NO;
    imageRequestOptions.networkAccessAllowed = YES;
    return [self.cachingImageManager requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (completion) {
            completion(imageData,dataUTI,orientation,info);
        }
    }];
}

@end

@implementation GDorisPhotoKitManager (PHCollection)

/**
 获取相册里的所有资源
 
 @param assetCollection PHAssetCollection
 @param mediaType GDorisMediaType
 @return <#return value description#>
 */
+ (NSArray<PHAsset *> *)fetchAllAssets:(PHAssetCollection *)assetCollection mediaType:(GDorisMediaType)mediaType
{
    return [[self class] fetchAllAssets:assetCollection mediaType:mediaType isReverse:YES];
}

+ (NSArray<PHAsset *> *)fetchAllAssets:(PHAssetCollection *)assetCollection mediaType:(GDorisMediaType)mediaType isReverse:(BOOL)isReveres
{
    PHFetchOptions *options = [GDorisPhotoKitManager createFetchOptionsWithMediaType:mediaType includeHiddenAssets:NO includeAllBurstAssets:NO];
    PHFetchResult *result =  [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];;
    __block NSMutableArray * array = [NSMutableArray arrayWithCapacity:result.count];
    NSEnumerationOptions enoption = NSEnumerationConcurrent;
    if (isReveres) {
        enoption = NSEnumerationReverse;
    }
    [result enumerateObjectsWithOptions:(enoption) usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[PHAsset class]]) {
            [array addObject:obj];
        }
    }];
    return array.copy;
}


@end

@implementation PHAsset (GDoirs)

/**
 获取photo类型
 
 @return GDorisMediaType
 */
- (GDorisMediaType)photoType
{
    return [GDorisPhotoKitManager meidaType:self];
}

/**
 获取图片的子类型
 
 @return GDorisImageSubType
 */
- (GDorisImageSubType)mediaSubType
{
    return [GDorisPhotoKitManager mediaSubType:self];
}

/**
 获取PHAsset原图
 
 @return UIImage
 */
- (UIImage *)originImage
{
    return [[GDorisPhotoKitManager sharedInstance] imageByOrigin:self];
}

/**
 异步获取PHAsset原图
 
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler 如果有网络请求，加载进度 NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler
{
    return [[GDorisPhotoKitManager sharedInstance] imageByOrigin:self completion:completion progressHandler:progressHandler];
}

/**
 获取PHAsset缩略图
 
 @param size 缩略图尺寸
 @return UIImage
 */
- (UIImage *)thumbnailImageWithSize:(CGSize)size
{
    return [[GDorisPhotoKitManager sharedInstance] imageByThumbnail:self size:size];
}

/**
 异步获取PHAsset原图
 
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion
{
    return [[GDorisPhotoKitManager sharedInstance] imageByThumbnail:self size:size completion:completion];
}

/**
 获取PHAsset预览图
 
 @return UIImage
 */
- (UIImage *)previewImage
{
    return [[GDorisPhotoKitManager sharedInstance] imageByPreview:self];
}

/**
 异步获取PHAsset预览图
 
 @param completion 会被多次调用,其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图
 @param progressHandler NotSafeThread
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion progressHandler:(PHAssetImageProgressHandler)progressHandler
{
    return  [[GDorisPhotoKitManager sharedInstance] imageByPreview:self completion:completion progressHandler:progressHandler];
}

- (PHImageRequestID)asyncLivePhotoWithSize:(CGSize)size completion:(void(^)(PHLivePhoto * result))completion
{
    if (self.mediaSubType == GDorisImageSubTypeLivePhoto) {
        return [[GDorisPhotoKitManager sharedInstance] imageByLivePhoto:self size:size completion:^(PHLivePhoto * _Nonnull result, NSDictionary<NSString *,id> * _Nonnull info) {
            if(completion){
                completion(result);
            }
        } progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
        }];
    } else {
        if(completion){
            completion(nil);
        };
        return 0;
    }
}

/**
 异步获取imageData
 
 @param completion <#completion description#>
 @return PHImageRequestID
 */
- (PHImageRequestID)asyncImageData:(void(^)(NSData * result))completion
{
    if (self.photoType == GDorisMediaTypeImage) {
        return [[GDorisPhotoKitManager sharedInstance] imageByData:self completion:^(NSData * _Nonnull imageData, NSString * _Nonnull dataUTI, UIImageOrientation orientation, NSDictionary * _Nonnull info) {
            GSafeInvokeThread(^{
                if (completion) {
                    completion(imageData);
                }
            });
        }];
    } else {
        if(completion){
            completion(nil);
        };
        return 0;
    }
}
@end


@implementation PHAssetCollection (GDoris)

- (NSString *)name
{
    return self.localizedTitle;
}

- (NSInteger)count
{
    return self.fetchResult.count;
}

- (NSInteger)countWithMediaType:(GDorisMediaType)mediaType
{
    return [self fetchResultWithMediaType:mediaType].count;
}

- (PHFetchResult *)fetchResult
{
    return [PHAsset fetchAssetsInAssetCollection:self options:nil];
}

- (PHFetchResult *)fetchResultWithMediaType:(GDorisMediaType)mediaType
{
    PHFetchOptions *op = [GDorisPhotoKitManager createFetchOptionsWithMediaType:mediaType];
    return [PHAsset fetchAssetsInAssetCollection:self options:op];
}

- (UIImage *)coverImage:(CGSize)size
{
    NSInteger count = self.count;
    if (count > 0) {
        PHAsset * asset = self.fetchResult[count-1];
        return [[GDorisPhotoKitManager sharedInstance] imageByThumbnail:asset resizeMode:PHImageRequestOptionsResizeModeExact size:size];
    }
    return nil;
}
@end
