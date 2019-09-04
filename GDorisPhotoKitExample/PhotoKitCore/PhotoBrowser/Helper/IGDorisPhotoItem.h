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
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, assign) NSInteger  itemIndex;

@optional

@property (nonatomic, strong) UIImage * dorisImage;
@property (nonatomic, strong) NSURL * dorisLocalUrl;
@property (nonatomic, strong) NSString * dorisImageName;
@property (nonatomic, strong) NSArray<NSString *> * dorisUrlStrings;
@property (nonatomic, strong) NSArray<NSURL *> * dorisUrls;
@property (nonatomic, strong) XCAsset * xc_Asset;
@property (nonatomic, strong) __kindof id context;


@optional
- (NSString *)photoUrl;
- (NSString *)placeholder;
- (NSString *)originUrl;
- (NSString *)thumbUrl;
- (NSString *)localImageName;
- (NSString *)videoUrl;
- (XCAsset *)asset;
- (BOOL)isVideo;

@property (nonatomic, strong) UIImage * thumbImage;
- (Class)customCellClass;

@end

NS_ASSUME_NONNULL_END
