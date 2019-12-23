//
//  GDorisWXToolbar.h
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DorisWXToolbarItemType) {
    DorisWXToolbarItemLeft,
    DorisWXToolbarItemCenter,
    DorisWXToolbarItemRight,
};

@interface GDorisWXToolbar : UIView
@property (nonatomic, strong, readonly) UIButton * leftButton;
@property (nonatomic, strong, readonly) UIButton * centerButton;
@property (nonatomic, strong, readonly) UIButton * rightButton;
@property (nonatomic, assign) BOOL  enabled;

@property(nonatomic, copy) void (^wxToolbarClickBlock)(DorisWXToolbarItemType itemType);
@end

NS_ASSUME_NONNULL_END
