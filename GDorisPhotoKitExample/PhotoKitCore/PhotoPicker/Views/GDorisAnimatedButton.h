//
//  GDorisAnimatedButton.h
//  GDoris
//
//  Created by GIKI on 2018/9/19.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GDorisPickerSelectType) {
    GDorisPickerSelectICON,
    GDorisPickerSelectCount,
};
@interface GDorisAnimatedButton : UIButton

@property (nonatomic, assign) GDorisPickerSelectType  selectType;
@property (nonatomic, copy  ) NSString * selectIndex;
@property (nonatomic, strong) UIFont * countFont;
@property (nonatomic, strong) UIColor * countColor;
@property (nonatomic, strong) UIColor * countBackColor;

- (void)popAnimated;
@end

NS_ASSUME_NONNULL_END
