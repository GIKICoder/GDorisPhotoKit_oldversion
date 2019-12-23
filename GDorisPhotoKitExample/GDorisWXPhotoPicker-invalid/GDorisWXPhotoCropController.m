//
//  GDorisWXPhotoCropController.m
//  GDoris
//
//  Created by GIKI on 2018/10/4.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXPhotoCropController.h"

#import "GDorisPhotoZoomAnimatedTransition.h"
#import "GDorisCropView.h"
#import "GDorisWXEditCropToolbar.h"
#import "UIView+GDoris.h"
@interface GDorisWXPhotoCropController ()
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) GDorisCropView * cropView;
@property (nonatomic, strong) GDorisWXEditCropToolbar * toolbar;
@end

@implementation GDorisWXPhotoCropController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:({
        _cropView = [[GDorisCropView alloc] initWithImage:self.image];
        _cropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cropView.aspectRatioLockEnabled = YES;
        _cropView.gridOverlayHidden = NO;
        _cropView;
    })];
    [self.view addSubview:({
        _toolbar = [[GDorisWXEditCropToolbar alloc] initWithFrame:CGRectMake(0,self.view.g_height-113, self.view.g_width, 113)];
        __weak typeof(self) weakSelf = self;
        _toolbar.dorisCropToolbarActionBlock = ^(DorisCropToolbarItemType itemType) {
            [weakSelf cropToolbarAction:itemType];
        };
        _toolbar;
    })];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    {
        CGFloat left = 0;
        CGFloat top = 10;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        self.cropView.frame = CGRectMake(left, top, width, height);
        [self.cropView moveCroppedContentToCenterAnimated:YES];
        [self.cropView performInitialSetup];
    }
}

- (void)cropToolbarAction:(DorisCropToolbarItemType)itemType
{
    switch (itemType) {
        case DorisCropToolbarItemClose:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case DorisCropToolbarItemReset:
        {
            [self.cropView resetLayoutToDefaultAnimated:YES];
        }
            break;
        case DorisCropToolbarItemRotate:
        {
            [self.cropView rotateImageNinetyDegreesAnimated:YES];
        }
            break;
        default:
            break;
    }
}
@end
