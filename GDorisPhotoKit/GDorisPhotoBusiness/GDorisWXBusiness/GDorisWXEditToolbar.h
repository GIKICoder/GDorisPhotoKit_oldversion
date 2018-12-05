//
//  GDorisWXEditToolbar.h
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisEditToolbarItemType) {
    DorisEditToolbarItemDraw = 1000,
    DorisEditToolbarItemEmjio,
    DorisEditToolbarItemText,
    DorisEditToolbarItemMosaic,
    DorisEditToolbarItemCrop,
};

@interface GDorisWXEditToolbar : UIView
@property(nonatomic, copy) void (^editToolbarClickBlock)(DorisEditToolbarItemType itemType,UIButton *sender);

- (void)setToolbarSelected:(BOOL)selected itemType:(DorisEditToolbarItemType)itemType;
@end


NS_ASSUME_NONNULL_END
