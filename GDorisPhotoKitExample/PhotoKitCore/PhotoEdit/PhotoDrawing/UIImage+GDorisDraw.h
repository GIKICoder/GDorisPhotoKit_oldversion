//
//  UIImage+GDorisDraw.h
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GDorisDraw)

- (UIImage *)mosaicLevel:(NSUInteger)level;
- (UIImage *)blurLevel:(NSInteger)level;
@end

NS_ASSUME_NONNULL_END
