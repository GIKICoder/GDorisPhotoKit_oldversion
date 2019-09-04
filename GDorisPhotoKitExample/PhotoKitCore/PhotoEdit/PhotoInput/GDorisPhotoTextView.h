//
//  GDorisPhotoTextView.h
//  GDoris
//
//  Created by GIKI on 2018/9/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GDorisPhotoTextView : UITextView

@property (nonatomic, assign) BOOL  DynamicHeightEnabled;
@property (nonatomic, assign) CGFloat  maxHeight;
@property (nonatomic, assign) CGFloat  minHeight;
@property(nonatomic, copy) void (^TextViewHeightChanged)(GDorisPhotoTextView *textView,CGFloat textViewHeight);
@property(nonatomic, copy) void (^TextViewTextChanged)(GDorisPhotoTextView *textView,NSString* text);

@end

NS_ASSUME_NONNULL_END
