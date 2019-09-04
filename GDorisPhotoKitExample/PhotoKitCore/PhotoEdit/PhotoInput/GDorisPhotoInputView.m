//
//  GDorisPhotoInputView.m
//  GDoris
//
//  Created by GIKI on 2018/9/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoInputView.h"
#import "GDorisPhotoTextView.h"
#import "GDorisPhotoHelper.h"

@interface GDorisPhotoInputView ()
@property (nonatomic, strong) GDorisPhotoTextView * textView;

@end

@implementation GDorisPhotoInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __weak typeof(self) weakSelf = self;
        [self addSubview:({
            _textView = [[GDorisPhotoTextView alloc] initWithFrame:CGRectZero];
            _textView.DynamicHeightEnabled = YES;
            _textView.backgroundColor = [UIColor clearColor];
            _textView.TextViewHeightChanged = ^(GDorisPhotoTextView *textView,CGFloat textViewHeight) {
                CGRect rect = textView.frame;
                rect.size.height = textViewHeight;
                textView.frame = rect;
            };
            
            _textView.TextViewTextChanged = ^(GDorisPhotoTextView * _Nonnull textView, NSString * _Nonnull text) {
            };
            _textView;
        })];
        
//        _colorPanel = [[GDorisWXEditColorPanel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50)];
//        [_colorPanel configColors:[self colorPanelColors]];
//        _colorPanel.colorDidSelectBlock = ^(UIColor * _Nonnull color) {
//            weakSelf.textColor = color;
//        };
//        _textView.inputAccessoryView = _colorPanel;
        self.textColor = [UIColor whiteColor];
        self.textFont = [UIFont systemFontOfSize:36];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textView.frame = self.bounds;
}

- (void)becomeInputFirstResponder
{
    [self.textView becomeFirstResponder];
}

- (void)resignInputFirstResponder
{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.textView.font = textFont;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textView.textColor = textColor;
}

- (void)configText:(NSString *)text
{
    self.textView.text = text;
}

- (NSString *)currentText
{
    return self.textView.text;
}

- (NSArray *)colorPanelColors
{
    return @[GDorisColor(250, 250, 250),
             GDorisColor(43, 43, 43),
             GDorisColor(255, 29, 19),
             GDorisColor(251, 245, 7),
             GDorisColor(21, 225, 19),
             GDorisColor(251, 55, 254),
             GDorisColor(140, 6, 255)];
}

@end
