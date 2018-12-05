//
//  GDorisPhotoActionHandler.h
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GDorisPhotoActionType) {
    GDorisPhotoActionTypeSelectPhoto,
    GDorisPhotoActionTypeUnselectPhoto,
};

@interface GDorisPhotoActionHandler : NSObject

+ (instancetype)photoActionWithController:(UIViewController *)controller;

@property (nonatomic, weak  ) __kindof UIViewController *currentController;

- (void)actionType:(GDorisPhotoActionType)actionType model:(__kindof id)model completion:(void(^)(id response))completion;

@end

NS_ASSUME_NONNULL_END
