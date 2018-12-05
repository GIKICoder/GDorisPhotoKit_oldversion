//
//  GDorisInputViewController.m
//  GDoris
//
//  Created by GIKI on 2018/9/15.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisInputViewController.h"
#import "GDorisPhotoInputView.h"
#import "GNavigationBar.h"
#import "GDorisPhotoHelper.h"
@interface GDorisInputViewController ()
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisPhotoInputView * inputView;
@end

@implementation GDorisInputViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavigationbar];
    self.view.backgroundColor = [UIColor colorWithRed:(0)/255.0 green:(0)/255.0 blue:(0)/255.0 alpha:0.6];
    self.inputView =[[GDorisPhotoInputView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(self.navigationBar.frame))];
    [self.view addSubview:self.inputView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.inputView becomeInputFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.inputView resignInputFirstResponder];
}

- (void)loadNavigationbar
{
    [self.view addSubview:({
        UIView * view = [UIView new];
        view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GNAVColorRGBA(4,0,18,0.26).CGColor,(__bridge id)GNAVColorRGBA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
    self.navigationBar = [GNavigationBar navigationBar];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.backgroundImageView.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    GNavigationItem *cancel = [GNavItemFactory createTitleButton:@"取消" titleColor:[UIColor whiteColor] highlightColor:[UIColor lightGrayColor] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = cancel;
    GNavigationItem *done = [GNavItemFactory createTitleButton:@"完成" titleColor:GDorisColorCreate(@"20A115") highlightColor:GDorisColorCreate(@"154212") target:self selctor:@selector(done)];
    self.navigationBar.rightNavigationItem = done;
}


#pragma mark - action Method

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    if (self.inputTextDoneBlock) {
        NSMutableDictionary * dictM = [NSMutableDictionary dictionary];
        if ([self.inputView currentText]) {
            [dictM setObject:[self.inputView currentText] forKey:@"text"];
        }
        [dictM setObject:self.inputView.textColor forKey:@"textColor"];
        [dictM setObject:self.inputView.textFont forKey:@"font"];
        self.inputTextDoneBlock(dictM.copy);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
