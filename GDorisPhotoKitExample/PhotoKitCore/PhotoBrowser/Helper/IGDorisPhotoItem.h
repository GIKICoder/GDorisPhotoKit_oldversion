//
//  IGDorisPhotoItem.h
//  GDoris
//
//  Created by GIKI on 2019/3/31.
//  Copyright © 2019年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XCAsset;
NS_ASSUME_NONNULL_BEGIN

@protocol IGDorisPhotoItem <NSObject>

@required
- (NSString *)photoUrl;
- (NSString *)placeholder;

@optional
- (NSString *)originUrl;
- (NSString *)thumbUrl;
- (NSString *)localImageName;
- (NSString *)videoUrl;
- (XCAsset *)asset;
- (BOOL)isVideo;

@property (nonatomic, strong) UIImage * thumbImage;
@property (nonatomic, strong) __kindof id context;
@property (nonatomic, assign) NSInteger  itemIndex;
- (Class)customCellClass;

@end

NS_ASSUME_NONNULL_END
