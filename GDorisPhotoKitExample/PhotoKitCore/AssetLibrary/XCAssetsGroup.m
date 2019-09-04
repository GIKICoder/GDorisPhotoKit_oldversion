//
//  XCAssetsGroup.m
//  GDoris
//
//  Created by GIKI on 2019/8/13.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "XCAssetsGroup.h"
#import "XCAsset.h"
#import "XCAssetsManager.h"

@interface  XCAssetsGroup()

@property(nonatomic, strong, readwrite) PHAssetCollection *phAssetCollection;
@property(nonatomic, strong, readwrite) PHFetchResult *phFetchResult;

@end

@implementation  XCAssetsGroup

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection fetchAssetsOptions:(PHFetchOptions *)pHFetchOptions {
    self = [super init];
    if (self) {
        PHFetchResult *phFetchResult = [PHAsset fetchAssetsInAssetCollection:phAssetCollection options:pHFetchOptions];
        self.phFetchResult = phFetchResult;
        self.phAssetCollection = phAssetCollection;
    }
    return self;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection {
    return [self initWithPHCollection:phAssetCollection fetchAssetsOptions:nil];
}

- (NSInteger)numberOfAssets {
    return self.phFetchResult.count;
}

- (NSString *)name {
    NSString *resultName = self.phAssetCollection.localizedTitle;
    return NSLocalizedString(resultName, resultName);
}

- (UIImage *)posterImageWithSize:(CGSize)size {
    // 系统的隐藏相册不应该显示缩略图
    if (self.phAssetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
        /// todo by giki
        return [UIImage imageNamed:@"QMUI_hiddenAlbum"];
    }
    
    __block UIImage *resultImage;
    NSInteger count = self.phFetchResult.count;
    if (count > 0) {
        PHAsset *asset = self.phFetchResult[count - 1];
        PHImageRequestOptions *pHImageRequestOptions = [[PHImageRequestOptions alloc] init];
        pHImageRequestOptions.synchronous = YES; // 同步请求
        pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        // targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        [[[ XCAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width * [[UIScreen mainScreen] scale], size.height * [[UIScreen mainScreen] scale]) contentMode:PHImageContentModeAspectFill options:pHImageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            resultImage = result;
        }];
    }
    return resultImage;
}

- (void)enumerateAssetsWithOptions:( XCAlbumSortType)albumSortType usingBlock:(void (^)( XCAsset *resultAsset))enumerationBlock {
    NSInteger resultCount = self.phFetchResult.count;
    if (albumSortType ==  XCAlbumSortTypeReverse) {
        for (NSInteger i = resultCount - 1; i >= 0; i--) {
            PHAsset *pHAsset = self.phFetchResult[i];
             XCAsset *asset = [[ XCAsset alloc] initWithPHAsset:pHAsset];
            if (enumerationBlock) {
                enumerationBlock(asset);
            }
        }
    } else {
        for (NSInteger i = 0; i < resultCount; i++) {
            PHAsset *pHAsset = self.phFetchResult[i];
             XCAsset *asset = [[XCAsset alloc] initWithPHAsset:pHAsset];
            if (enumerationBlock) {
                enumerationBlock(asset);
            }
        }
    }
    /**
     *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
     */
    if (enumerationBlock) {
        enumerationBlock(nil);
    }
}

- (void)enumerateAssetsUsingBlock:(void (^)( XCAsset *resultAsset))enumerationBlock {
    [self enumerateAssetsWithOptions: XCAlbumSortTypePositive usingBlock:enumerationBlock];
}

@end
