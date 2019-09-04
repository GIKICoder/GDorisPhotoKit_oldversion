//
//  GDorisPhotoItem.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/4.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoItem : NSObject

@property (nonatomic, strong) Class cellClass;
@property (nonatomic, assign) BOOL  isAsset;
@property (nonatomic, assign) BOOL  isUrl;

@end

NS_ASSUME_NONNULL_END
