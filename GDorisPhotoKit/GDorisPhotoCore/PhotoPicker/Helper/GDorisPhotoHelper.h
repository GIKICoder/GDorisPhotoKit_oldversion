//
//  GDorisPhotoHelper.h
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define GDorisColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define GDorisColorA(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
// 随机色
#define GDorisRandomColor GDorisColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define GDorisColorCreate(colorHex) [GDorisPhotoHelper colorWithHex:colorHex]

#define GDorisWidth ([[UIScreen mainScreen] bounds].size.width)
#define GDorisHeight ([[UIScreen mainScreen] bounds].size.height)


#define GDorisPhotoErrorDomain  @"GDorisPhoto.Error.domain"


@interface GDorisPhotoHelper : NSObject

+ (UIColor *)colorWithHex:(NSString *)hexColor;
+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)alpha;

+ (UIImage *)createImageWithColor: (UIColor *)color;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image;

+ (void)fitImageSize:(CGSize)imageSize containerSize:(CGSize)containerSize Completed:(void(^)(CGRect containerFrame, CGSize scrollContentSize))completed;
@end

NS_ASSUME_NONNULL_END
