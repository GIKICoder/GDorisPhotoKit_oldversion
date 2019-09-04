//
//  GDorisProgressView.h
//  GDoris
//
//  Created by GIKI on 2018/8/26.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisProgressView : UIView

@property (nonatomic, assign) float  progress;

@property (nonatomic, assign) CFTimeInterval  progressDuration;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
