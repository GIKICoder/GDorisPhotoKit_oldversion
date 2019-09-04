//
//  GDorisTiledLayerView.h
//  GDoris
//
//  Created by GIKI on 2018/9/2.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisTiledLayerView : UIView

@property (nonatomic, strong) UIImage * image;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
