//
//  GDorisInputViewController.h
//  GDoris
//
//  Created by GIKI on 2018/9/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisInputViewController : UIViewController

@property(nonatomic, copy) void (^inputTextDoneBlock)(NSDictionary * params);

@end

NS_ASSUME_NONNULL_END
