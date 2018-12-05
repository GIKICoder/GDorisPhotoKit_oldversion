//
//  GDorisDragDropView.h
//  GDoris
//
//  Created by GIKI on 2018/9/16.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisDragDropView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign) BOOL  dragEnabled;

@property (nonatomic, assign) NSInteger minimumSize;

@property (nonatomic, assign) CGSize  maxSize;

@property (nonatomic, strong) UIColor *outlineBorderColor;

@property (nonatomic, assign) BOOL  editEnabled;

@property (nonatomic, strong) __kindof id userInfo;

- (instancetype)initWithContentView:(__kindof UIView *)contentView;

@end

NS_ASSUME_NONNULL_END
