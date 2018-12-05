//
//  GBaseNavigationBar.m
//  GNavigationBar
//
//  Created by GIKI on 2017/4/5.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#import "GNavigationBar.h"

@interface GNavigationBar ()
@property (nonatomic, strong,readwrite) UIImageView * backgroundImageView;
@property (nonatomic, strong) GNavigationItem * mainNavigationContainer;
@property (nonatomic, strong) GNavigationItem * leftNavigationContainer;
@property (nonatomic, strong) GNavigationItem * rightNavigationContainer;
@property (nonatomic, strong) GNavigationItem * centerNavigationContainer;

@property (nonatomic, strong) UILabel * centerLabel;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, assign) BOOL  animating;
@property (nonatomic, assign) BOOL  customBar;
@end

@implementation GNavigationBar

+ (instancetype)navigationBar
{
    GNavigationBar *navbar = [[GNavigationBar alloc] initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, G_NAV_HEIGHT) customBar:NO];
    return navbar;
}

#pragma mark -- init Method

- (instancetype)initWithFrame:(CGRect)frame customBar:(BOOL)customBar
{
    self = [super initWithFrame:frame];
    if (self) {
        self.customBar = customBar;
        [self loadUI];
    }
    return self;
}

- (void)loadUI
{
    [self addSubview:self.backgroundImageView];
    
    [self addSubview:self.mainNavigationContainer.rootView];
    
    [self.mainNavigationContainer layoutFatherContainers];
}

- (void)dealloc
{
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.mainNavigationContainer.minSubContainerWidth = [UIScreen mainScreen].bounds.size.width;
}

#pragma mark -- getter Method

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _backgroundImageView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroundImageView;
}

- (GNavigationItem *)mainNavigationContainer
{
    if (!_mainNavigationContainer) {
        UIView *view = [UIView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _mainNavigationContainer = [[GNavigationItem alloc] initWithRootView:view];
        _mainNavigationContainer.minSubContainerWidth = [UIScreen mainScreen].bounds.size.width;
        _mainNavigationContainer.customNavBar = self.customBar;
        if (self.customBar) {
            _mainNavigationContainer.rootView.frame = self.bounds;
        } else {
            _mainNavigationContainer.rootView.frame = CGRectMake(0,GStatusBarHeight, G_SCREEN_WIDTH, G_NAV_HEIGHT-GStatusBarHeight);
        }

        [_mainNavigationContainer addChild:self.centerNavigationContainer];
        [_mainNavigationContainer addChild:self.rightNavigationContainer];
        [_mainNavigationContainer addChild:self.leftNavigationContainer];
        if(G_NAVI_DEBUG) {
            self.leftNavigationContainer.rootView .backgroundColor = [UIColor redColor];
            self.centerNavigationContainer.rootView .backgroundColor = [UIColor blueColor];
            self.rightNavigationContainer.rootView .backgroundColor = [UIColor orangeColor];
        }
    }
    return _mainNavigationContainer;
}

- (GNavigationItem *)leftNavigationContainer
{
    if (!_leftNavigationContainer) {
        UIView *view = [UIView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _leftNavigationContainer = [[GNavigationItem alloc] initWithRootView:view];
        _leftNavigationContainer.attachStyle = GNavItemAttachStyle_left;
        _leftNavigationContainer.customNavBar = self.customBar;
    }
    return _leftNavigationContainer;
}

- (GNavigationItem *)centerNavigationContainer
{
    if (!_centerNavigationContainer) {
        UIView *view = [UIView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _centerNavigationContainer = [[GNavigationItem alloc] initWithRootView:view];
        _centerNavigationContainer.attachStyle = GNavItemAttachStyle_center;
        _centerNavigationContainer.customNavBar = self.customBar;
    }
    return _centerNavigationContainer;
}

- (GNavigationItem *)rightNavigationContainer
{
    if (!_rightNavigationContainer) {
        UIView *view = [UIView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; //保持右边局不变
        _rightNavigationContainer = [[GNavigationItem alloc] initWithRootView:view];
        _rightNavigationContainer.attachStyle = GNavItemAttachStyle_right;
        _rightNavigationContainer.customNavBar = self.customBar;
    }
    return _rightNavigationContainer;
}

#pragma mark -- public Method

#pragma mark - setter Method

- (void)setLeftNavigationItem:(GNavigationItem *)leftNavigationItem
{
    _leftNavigationItem = leftNavigationItem;
    [self removeAllLeftItem];
    if (leftNavigationItem) {
        [self addLeftItem:leftNavigationItem];
    }
    
}

- (void)setRightNavigationItem:(GNavigationItem *)rightNavigationItem
{
    _rightNavigationItem = rightNavigationItem;
    [self removeAllRightItem];
    if (rightNavigationItem) {
        [self addRightItem:rightNavigationItem];
    }
}

- (void)setLeftNavigaitonItems:(NSArray<GNavigationItem *> *)leftNavigaitonItems
{
    _leftNavigaitonItems = leftNavigaitonItems;
    [self removeAllLeftItem];
    
    [leftNavigaitonItems enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customNavBar = self.customBar;
        [self addLeftItem:obj];
    }];
    
    [self refreshConfig];
}

- (void)setRightNavigaitonItems:(NSArray<GNavigationItem *> *)rightNavigaitonItems
{
    _rightNavigaitonItems = rightNavigaitonItems;
    [self removeAllRightItem];
    
    [rightNavigaitonItems enumerateObjectsUsingBlock:^(GNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customNavBar = self.customBar;
        [self addRightItem:obj];
    }];
    
    [self refreshConfig];
}


#pragma mark - open Method

-(void)addLeftItem:(GNavigationItem*)item
{
    NSAssert(item, @"传入item不能为空");
    item.customNavBar = self.customBar;
    item.attachStyle = GNavItemAttachStyle_left;
    [self.leftNavigationContainer addChild:item];
    
}

-(void)addRightItem:(GNavigationItem*)item
{
    NSAssert(item, @"传入item不能为空");
    item.customNavBar = self.customBar;
    item.attachStyle = GNavItemAttachStyle_right;
    [self.rightNavigationContainer addChild:item];
}

//centerView可通过此接口自定义
-(void)setCenterItem:(GNavigationItem*)item
{
    NSAssert(item, @"传入item不能为空");
    [self.centerNavigationContainer removeAllChildContainer];
    item.customNavBar = self.customBar;
    item.attachStyle = GNavItemAttachStyle_center;
    [self.centerNavigationContainer addChild:item];
}

-(void)removeLeftItem
{
    
}

-(void)removeRightItem
{
    
}

- (void)removeAllLeftItem
{
    [self.leftNavigationContainer removeAllChildContainer];
}

- (void)removeAllRightItem
{
    [self.rightNavigationContainer removeAllChildContainer];
}

//刷新配置
-(void)refreshConfig
{
    //bug
    //    [self.mainNavigationContainer resetAndLayoutTheWholdContainersTree];
}

- (void)setTitle:(NSString *)title
{
    self.centerLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    self.centerLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.centerLabel.textColor = titleColor;
}

- (void)setTitleMode:(NSLineBreakMode)titleMode
{
    self.centerLabel.lineBreakMode = titleMode;
}

- (void)setNavigationEffectWithStyle:(UIBlurEffectStyle)style
{
    if ([self.backgroundImageView.subviews containsObject:self.effectView]) {
        [self.effectView removeFromSuperview];
    }
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *effectV = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView = effectV;
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = self.backgroundImageView.bounds;
    gradientLayer.colors = @[(__bridge id)GNAVColorRGBA(4,0,18,0.76).CGColor,(__bridge id)GNAVColorRGBA(4,0,18,0.28).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    [effectV.contentView.layer addSublayer:gradientLayer];
//    effectV.contentView.alpha = 0.5;
    [self.backgroundImageView addSubview:effectV];
    effectV.frame = self.backgroundImageView.bounds;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    
    [self setNavigationBarHidden:hidden animated:animated complete:nil];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated complete:(dispatch_block_t)block
{
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    
    if (!hidden) {
        [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setHidden:NO];
        }];
    }
    
    self.userInteractionEnabled = NO;
    
    
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        CGRect frame = self.frame;
        if (hidden) {
            frame.origin.y = -(self.frame.size.height-20);
        }
        else{
            frame.origin.y = 0;
        }
        self.frame = frame;
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = YES;
        self.animating = NO;
        
        if (finished && hidden) {
            [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj setHidden:YES];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
        
    }];
}

#pragma mark -- private Method

- (UILabel *)centerLabel
{
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _centerLabel.font = [UIFont systemFontOfSize:G_NAVI_TITLE_FONT];
        _centerLabel.textColor = [UIColor blackColor];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        GNavigationItem *item = [[GNavigationItem alloc] initWithRootView:_centerLabel attachStyle:GNavItemAttachStyle_center];
        [self.centerNavigationContainer addChild:item];
    }
    return _centerLabel;
}


@end

