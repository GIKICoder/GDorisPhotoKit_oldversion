//
//  GDorisPhotoTextView.m
//  GDoris
//
//  Created by GIKI on 2018/9/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisPhotoTextView.h"
@interface GDorisPhotoTextView ()
{
    CGFloat _lastHeight;
}
@end

static NSString * FONTText = @"文字高度";

@implementation GDorisPhotoTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxHeight = CGFLOAT_MAX;
        self.minHeight = 24;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
         [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
         [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
         [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
         [self addObserver:self forKeyPath:@"textAlignment" options:NSKeyValueObservingOptionNew context:nil];
         [self addObserver:self forKeyPath:@"textContainerInset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
    [self removeObserver:self forKeyPath:@"bounds"];
    [self removeObserver:self forKeyPath:@"text"];
    [self removeObserver:self forKeyPath:@"textAlignment"];
    [self removeObserver:self forKeyPath:@"textContainerInset"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textViewTextDidChange:(NSNotification *)notification
{
    [self adjustTextViewFrame];
    if (self.TextViewTextChanged) {
        self.TextViewTextChanged(self, self.text);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]){
        [self adjustTextViewFrame];
    }
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    if (self.bounds.size.height <= 0) {
        CGSize size = [FONTText sizeWithAttributes:@{NSFontAttributeName: font}];
        CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        self.minHeight = adjustedSize.height + 6;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)adjustTextViewFrame
{
    if (!_DynamicHeightEnabled) return;
    if (_maxHeight >= self.bounds.size.height) {
        NSInteger currentHeight = ceil([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
        if (_lastHeight != currentHeight) {
            self.scrollEnabled = currentHeight >= _maxHeight;
            CGFloat currentTextViewHeight = currentHeight >= _maxHeight ? _maxHeight : currentHeight;
            if (currentTextViewHeight >= _minHeight) {
                CGRect frame = self.frame;
                frame.size.height = currentTextViewHeight;
                self.frame = frame;
                if (self.TextViewHeightChanged) self.TextViewHeightChanged(self,currentTextViewHeight);
                _lastHeight = currentTextViewHeight;
            }
        }
    }
    if (!self.isFirstResponder) [self becomeFirstResponder];
}
@end
