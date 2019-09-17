//
//  GDorisLargeTiledView.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/6.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisTiledImageBuilder.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisLargeTiledView : UIView
@property (nonatomic, assign) BOOL annotates;
@property (nonatomic, strong, readonly) UIImage * image;

- (instancetype)initWithImageBuilder:(GDorisTiledImageBuilder *)imageBuilder;
- (CGSize)imageSize;

@end

NS_ASSUME_NONNULL_END
