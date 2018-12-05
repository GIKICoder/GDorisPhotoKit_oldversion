//
//  GDorisWXEditColorPanel.h
//  GDoris
//
//  Created by GIKI on 2018/10/3.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisWXEditColorPanel : UIView

@property(nonatomic, copy) void (^colorDidSelectBlock)(UIColor *color);
@property(nonatomic, copy) void (^revokeActionBlock)(void);

- (void)configColors:(NSArray<UIColor *> *)colors;
- (void)setSelectedByIndex:(NSInteger)index;
- (void)setRevokeEnabled:(BOOL)enabled;

@end

@interface GDorisWXEditMosaicPanel : UIView

@property(nonatomic, copy) void (^mosaicDidSelectBlock)(NSInteger type);
@property(nonatomic, copy) void (^revokeActionBlock)(void);
- (void)setRevokeEnabled:(BOOL)enabled;
@end

NS_ASSUME_NONNULL_END
