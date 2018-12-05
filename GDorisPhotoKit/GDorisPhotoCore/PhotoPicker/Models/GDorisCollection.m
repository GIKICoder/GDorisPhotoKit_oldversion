//
//  GDorisCollection.m
//  GDoris
//
//  Created by GIKI on 2018/8/9.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisCollection.h"

@implementation GDorisCollection

+ (instancetype)createCollection:(PHAssetCollection*)collection
{
    return [GDorisCollection createCollection:collection meidiaType:GDorisMediaTypeAll];
}

+ (instancetype)createCollection:(PHAssetCollection*)collection meidiaType:(GDorisMediaType)type
{
    GDorisCollection * DorisCollection = [[GDorisCollection alloc] initWithCollection:collection meidiaType:type];
    return DorisCollection;
}

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection meidiaType:(GDorisMediaType)type
{
    self = [super init];
    if (self) {
        self.collection = assetCollection;
        self.name = assetCollection.name;
        self.count = assetCollection.count;
    }
    return self;
}

- (UIImage *)coverImage
{
    if (!_coverImage) {
        _coverImage = [self.collection coverImage:CGSizeMake(55, 55)];
    }
    if (!_coverImage) {
        _coverImage = [UIImage imageNamed:@"GDoris_default_pic"];
    }
    return _coverImage;
}
@end
