//
//  GDorisPickerHandler.h
//  GDoris
//
//  Created by GIKI on 2018/9/26.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisPhotoPickerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GDorisRegisterCellClassProtcol <NSObject>

- (NSArray *)handlerCellClassWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration;

@end

@interface GDorisRegisterCellClassHandler : NSObject <GDorisRegisterCellClassProtcol>

@end

NS_ASSUME_NONNULL_END
