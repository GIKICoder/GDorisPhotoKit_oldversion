//
//  GDorisPhotoActionHandler.m
//  GDoris
//
//  Created by GIKI on 2018/8/12.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoActionHandler.h"

@implementation GDorisPhotoActionHandler

+ (instancetype)photoActionWithController:(UIViewController *)controller
{
    GDorisPhotoActionHandler * actionHandler = [GDorisPhotoActionHandler new];
    actionHandler.currentController = controller;
    return actionHandler;
}


- (void)actionType:(GDorisPhotoActionType)actionType model:(__kindof id)model completion:(void(^)(id response))completion
{
    
}
@end
