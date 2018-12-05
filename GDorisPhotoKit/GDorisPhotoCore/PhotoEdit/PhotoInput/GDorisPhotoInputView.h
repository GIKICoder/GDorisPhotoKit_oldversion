//
//  GDorisPhotoInputView.h
//  GDoris
//
//  Created by GIKI on 2018/9/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDorisWXEditColorPanel.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoInputView : UIView

@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, strong) UIColor * textBackgroundColor;

- (void)configText:(NSString *)text;
- (NSString *)currentText;

- (void)becomeInputFirstResponder;
- (void)resignInputFirstResponder;

@end

NS_ASSUME_NONNULL_END
