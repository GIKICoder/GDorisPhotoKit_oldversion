//
//  GDorisCollection.h
//  GDoris
//
//  Created by GIKI on 2018/8/9.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisPhotoKitManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisCollection : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic, assign) NSInteger  count;
@property (nonatomic, strong) PHAssetCollection * collection;
@property (nonatomic, strong) UIImage * coverImage;

+ (instancetype)createCollection:(PHAssetCollection*)collection;
+ (instancetype)createCollection:(PHAssetCollection*)collection meidiaType:(GDorisMediaType)type;
@end

NS_ASSUME_NONNULL_END
