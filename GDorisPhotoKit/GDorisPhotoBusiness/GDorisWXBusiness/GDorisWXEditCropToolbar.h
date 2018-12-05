//
//  GDorisWXEditCropToolbar.h
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisCropToolbarItemType) {
    DorisCropToolbarItemRotate = 1001,
    DorisCropToolbarItemClose,
    DorisCropToolbarItemReset,
    DorisCropToolbarItemDone
};
@interface GDorisWXEditCropToolbar : UIView

@property(nonatomic, copy) void (^dorisCropToolbarActionBlock)(DorisCropToolbarItemType itemType);
@end

NS_ASSUME_NONNULL_END
