//
//  GDorisLargeImageView_old.h
//  GDoris
//
//  Created by GIKI on 2018/9/2.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisTiledLayerView.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisLargeImageView_old : UIScrollView
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) GDorisTiledLayerView * tiledLayerView;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
