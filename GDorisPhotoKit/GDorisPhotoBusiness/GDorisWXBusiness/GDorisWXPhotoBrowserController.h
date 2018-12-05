//
//  GDorisWXPhotoBrowserController.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisBasePhotoBrowserController.h"
#import "GDorisPhotoBrowserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GDorisWXPhotoBrowserController : GDorisBasePhotoBrowserController

@property (nonatomic, weak  ) id<GDorisPhotoBrowserDelegate>  delegate;
@end

NS_ASSUME_NONNULL_END
