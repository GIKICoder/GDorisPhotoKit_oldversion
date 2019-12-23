//
//  GDorisPhotoEditerController.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/12/23.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisPhotoEditerController.h"
#import "GDorisPhotoHelper.h"
#import "GNavigationBar.h"
#import "GDorisWXEditToolbar.h"
#import "GDorisCanvasView.h"
#import "GDorisWXEditColorPanel.h"
#import "UIView+GDoris.h"
#import "GDorisWXEditHitTestView.h"
#import "UIImage+GDorisDraw.h"
#import "GDorisWXPhotoCropController.h"
#import "GDorisInputViewController.h"
#import "GDorisDragDropView.h"
#import "GDorisWXEditCropMaskView.h"

@interface GDorisPhotoEditerController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate/*,TOCropViewControllerDelegate*/>
@property (nonatomic, strong) GDorisWXEditHitTestView * operationArea;
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisWXEditToolbar * toolBar;
@property (nonatomic, strong) GDorisWXEditColorPanel * colorPanel;
@property (nonatomic, strong) GDorisWXEditMosaicPanel * mosaicPanel;
@property (nonatomic, strong) GDorisCanvasView * canvasView;
@property (nonatomic, strong) GDorisCanvasView * mosaicView;
@property (nonatomic, strong) GDorisWXEditCropMaskView * cropMaskView;

@property (nonatomic, strong) UIScrollView * scrollerContainer;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImageView * cropImageView;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) UITapGestureRecognizer * tapGesture;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, strong) NSMutableArray * dragViews;

@property (nonatomic, strong) GDorisAssetItem * assetItem;
@property (nonatomic, strong) UIImage * originImage;

@end

@implementation GDorisPhotoEditerController

+ (instancetype)photoEditerWithAsset:(GDorisAssetItem *)assetItem image:(nullable UIImage *)image
{
    GDorisPhotoEditerController * editer = [GDorisPhotoEditerController new];
    editer.assetItem = assetItem;
    editer.originImage = image;
    editer.image = image;
    return editer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:({
        _scrollerContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollerContainer.delegate = self;
        _scrollerContainer.minimumZoomScale = 1;
        _scrollerContainer.maximumZoomScale = 2;
        _scrollerContainer;
    })];

    [self.scrollerContainer addSubview:({
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor clearColor];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView;
    })];
    self.imageView.image = self.image;
    [GDorisPhotoHelper fitImageSize:self.image.size containerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) Completed:^(CGRect containerFrame, CGSize scrollContentSize) {
        self.scrollerContainer.contentSize = scrollContentSize;
        self.imageView.frame = containerFrame;
    }];
    [self.view addSubview:({
        _operationArea = [GDorisWXEditHitTestView new];
        _operationArea.frame = self.view.bounds;
        _operationArea.userInteractionEnabled = NO;
        _operationArea.backgroundColor = [UIColor clearColor];
        _operationArea;
    })];
    
    [self loadMaskView];
    [self loadNavigationbar];
    [self loadToolbar];
    [self loadPanGesture];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadPanGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGesture.delegate = self;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)loadMaskView
{
    [self.operationArea addSubview:({
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
    [self.operationArea addSubview:({
        UIView * view = [UIView new];
        view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-130, [UIScreen mainScreen].bounds.size.width, 130);
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = view.bounds;
        gradientLayer.colors = @[(__bridge id)GNAVColorRGBA(4,0,18,0.26).CGColor,(__bridge id)GNAVColorRGBA(4,0,18,0.01).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0);
        [view.layer addSublayer:gradientLayer];
        view;
    })];
}

- (void)loadNavigationbar
{
    self.navigationBar = [GNavigationBar navigationBar];
    [self.operationArea addSubview:self.navigationBar];
    self.navigationBar.backgroundImageView.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    GNavigationItem *cancel = [GNavItemFactory createTitleButton:@"取消" titleColor:[UIColor whiteColor] highlightColor:[UIColor lightGrayColor] target:self selctor:@selector(cancel)];
    self.navigationBar.leftNavigationItem = cancel;
    GNavigationItem *done = [GNavItemFactory createTitleButton:@"完成" titleColor:GDorisColorCreate(@"20A115") highlightColor:GDorisColorCreate(@"154212") target:self selctor:@selector(done)];
    self.navigationBar.rightNavigationItem = done;
}

- (void)loadToolbar
{
    self.toolBar = [[GDorisWXEditToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width, 37)];
    self.toolBar.backgroundColor = GDorisColorA(0, 0, 0, 0.01);
    __weak typeof(self) weakSelf = self;
    self.toolBar.editToolbarClickBlock = ^(DorisEditToolbarItemType itemType,UIButton * sender) {
        [weakSelf editToolbarClick:itemType button:sender];
    };
    [self.operationArea addSubview:self.toolBar];
}

#pragma mark - private Method

#pragma mark - action Method

- (void)done
{
    
}

- (void)cancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)editToolbarClick:(DorisEditToolbarItemType)itemType button:(UIButton *)sender
{
    switch (itemType) {
        case DorisEditToolbarItemDraw:
        {
            [self.toolBar setToolbarSelected:!sender.selected itemType:DorisEditToolbarItemDraw];
            [self drawPhoto:sender.selected];
        }
            break;
        case DorisEditToolbarItemMosaic:
        {
            [self.toolBar setToolbarSelected:!sender.selected itemType:DorisEditToolbarItemMosaic];
            [self drawMosaic:sender.selected];
        }
            break;
        case DorisEditToolbarItemCrop:
        {
            [self cropPhoto];
        }
            break;
        case DorisEditToolbarItemText:
        {
            [self textPhoto];
        }
            break;
        default:
            break;
    }
}

- (void)bringSubviewToFront
{
    [self.view bringSubviewToFront:self.operationArea];
}

- (void)drawActionState:(DorisCanvasDrawState)state
{
    switch (state) {
        case DorisCanvasDrawStateBegin:
        {
            self.scrollerContainer.scrollEnabled = NO;
        }
            break;
        case DorisCanvasDrawStateMove:
        {
            [self operaAreaHidden:YES anmiated:YES];
        }
            break;
        case DorisCanvasDrawStateEnd:
        case DorisCanvasDrawStateCancel:
        {
            [self operaAreaHidden:NO anmiated:YES];
            self.scrollerContainer.scrollEnabled = YES;
        }
            break;
        default:
            break;
    }
}

- (void)operaAreaHidden:(BOOL)hidden anmiated:(BOOL)anmiated
{
    if (anmiated) {
        [UIView animateWithDuration:0.15 animations:^{
            self.operationArea.alpha = hidden ? 0 : 1;
        } completion:^(BOOL finished) {
            self.operationArea.hidden = hidden;
        }];
    } else {
          self.operationArea.hidden = hidden;
    }
}

- (void)textInputDone:(NSDictionary *)params
{
    NSString * text = params[@"text"];
    UIColor * textColor = params[@"textColor"];
    UIFont * font = params[@"font"];
    UILabel * label = [UILabel new];
    label.textColor = textColor;
    label.font = font;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = self.imageView.center;
    GDorisDragDropView * dragView = [[GDorisDragDropView alloc] initWithContentView:label];
    [self.imageView addSubview:dragView];
    [self.dragViews addObject:dragView];
}

- (void)bringDragViewToFront
{
    __weak typeof(self) weakSelf = self;
    [self.dragViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf.imageView bringSubviewToFront:obj];
    }];
}

#pragma mark - Gesture Method

- (void)handleTapGesture:(UIPanGestureRecognizer *)recognizer
{
    [self operaAreaHidden:!self.operationArea.hidden anmiated:NO];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    CGRect rect = self.colorPanel.hidden ? CGRectZero : self.colorPanel.frame;
    BOOL contains = CGRectContainsPoint(rect, point);
    return !contains;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Edit Toolbar Action

- (void)drawPhoto:(BOOL)selected
{
    self.mosaicPanel.hidden = YES;
    self.colorPanel.hidden = !selected;
    self.mosaicView.hidden = NO;
    self.canvasView.hidden = NO;
    self.canvasView.userInteractionEnabled = selected;
    self.mosaicView.userInteractionEnabled = NO;
    [self bringDragViewToFront];
}

- (void)drawMosaic:(BOOL)selected
{
    self.colorPanel.hidden = YES;
    self.mosaicView.hidden = NO;
    self.canvasView.hidden = NO;
    self.mosaicPanel.hidden = !selected;
    self.canvasView.userInteractionEnabled = NO;
    self.mosaicView.userInteractionEnabled = selected;
    [self bringDragViewToFront];
}

- (void)didSelectDrawColor:(UIColor *)color
{
    self.canvasView.paintColor = color;
}

- (void)revokeDrawAction
{
    [self.canvasView revokeLastMask];
    [self.colorPanel setRevokeEnabled:[self.canvasView canRevoke]];
}

- (void)revokeMosaicAction
{
    [self.mosaicView revokeLastMask];
    [self.mosaicPanel setRevokeEnabled:[self.mosaicView canRevoke]];
}


- (void)cropPhoto
{
    /*
//    UIImage * image = [self.imageView snapshotImage];
//    GDorisWXPhotoCropController * cropVC = [[GDorisWXPhotoCropController alloc] initWithImage:image];
//    [self presentViewController:cropVC animated:YES completion:^{
//
//    }];
    
    UIImage * image = [self.imageView snapshotImage];
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:image];
    cropController.delegate = self;
    CGRect viewFrame = [self.view convertRect:self.imageView.frame toView:self.view];
    [cropController presentAnimatedFromParentViewController:self
                                                  fromImage:image
                                                   fromView:nil
                                                  fromFrame:viewFrame
                                                      angle:self.angle
                                               toImageFrame:self.croppedFrame
                                                      setup:^{ }
                                                 completion:nil];
      */
}


- (void)textPhoto
{
    [self operaAreaHidden:YES anmiated:NO];
    GDorisInputViewController * inputVC = [[GDorisInputViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    inputVC.inputTextDoneBlock = ^(NSDictionary * _Nonnull params) {
        [weakSelf textInputDone:params];
    };
    [self presentViewController:inputVC animated:YES completion:nil];
}

#pragma mark - layz load

- (GDorisCanvasView *)canvasView
{
    if (!_canvasView) {
        CGRect rect = self.imageView.bounds;
        _canvasView = [[GDorisCanvasView alloc] init];
        _canvasView.frame = rect;
        _canvasView.hidden = YES;
        [self.imageView addSubview:_canvasView];
        [self bringSubviewToFront];
        __weak typeof(self) weakSelf = self;
        _canvasView.dorisDrawActionBlock = ^(DorisCanvasDrawState state) {
            [weakSelf drawActionState:state];
            if (state == DorisCanvasDrawStateEnd) {
                [weakSelf.colorPanel setRevokeEnabled:YES];
            }
        };
    }
    return _canvasView;
}

- (GDorisCanvasView *)mosaicView
{
    if (!_mosaicView) {
        CGRect rect = self.imageView.bounds;
        _mosaicView = [[GDorisCanvasView alloc] initWithImage:self.imageView.image];
        _mosaicView.frame = rect;
        _mosaicView.hidden = YES;
        _mosaicView.lineWidth = 24;
        [self.imageView addSubview:_mosaicView];
        UIImage * image = [self.image mosaicLevel:20];
        [_mosaicView setMaskImage:image];
        [self bringSubviewToFront];
        __weak typeof(self) weakSelf = self;
        _mosaicView.dorisDrawActionBlock = ^(DorisCanvasDrawState state) {
            [weakSelf drawActionState:state];
            if (state == DorisCanvasDrawStateEnd) {
                [weakSelf.mosaicPanel setRevokeEnabled:YES];
            }
        };
    }
    return _mosaicView;
}
- (GDorisWXEditColorPanel *)colorPanel
{
    if (!_colorPanel) {
        _colorPanel = [[GDorisWXEditColorPanel alloc] initWithFrame:CGRectMake(0, self.toolBar.g_top-63, [UIScreen mainScreen].bounds.size.width, 63)];
        _colorPanel.hidden = YES;
        [_colorPanel configColors:[self colorPanelColors]];
        [_colorPanel setRevokeEnabled:NO];
        [self.operationArea addSubview:_colorPanel];
        __weak typeof(self) weakSelf = self;
        _colorPanel.revokeActionBlock = ^{
            [weakSelf revokeDrawAction];
        };
        _colorPanel.colorDidSelectBlock = ^(UIColor * _Nonnull color) {
            [weakSelf didSelectDrawColor:color];
        };
    }
    return _colorPanel;
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

- (GDorisWXEditMosaicPanel *)mosaicPanel
{
    if (!_mosaicPanel) {
        _mosaicPanel = [[GDorisWXEditMosaicPanel alloc] initWithFrame:CGRectMake(0, self.toolBar.g_top-63, [UIScreen mainScreen].bounds.size.width, 63)];
        _mosaicPanel.hidden = YES;
        [self.operationArea addSubview:_mosaicPanel];
        __weak typeof(self) weakSelf = self;
        _mosaicPanel.mosaicDidSelectBlock = ^(NSInteger type) {
             NSInteger level = 20;
            if (type == 1003) {
                UIImage * image = [weakSelf.image blurLevel:level];
                [weakSelf.mosaicView setMaskImage:image];
            } else {
                UIImage * image = [weakSelf.image mosaicLevel:level];
                [weakSelf.mosaicView setMaskImage:image];
            }
        };
        _mosaicPanel.revokeActionBlock = ^{
            [weakSelf revokeMosaicAction];
        };
    }
    return _mosaicPanel;
}

- (NSArray *)dragViews
{
    if (!_dragViews) {
        _dragViews = [[NSMutableArray alloc] init];
    }
    return _dragViews;
}

- (GDorisWXEditCropMaskView *)cropMaskView
{
    if (!_cropMaskView) {
        _cropMaskView = [[GDorisWXEditCropMaskView alloc] initWithFrame:self.imageView.bounds];
        [self.imageView addSubview:_cropMaskView];
        [self bringSubviewToFront];
    }
    return _cropMaskView;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self containerViewDidZoom:scrollView];
}

- (void)containerViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    UIView * container = self.imageView;
    container.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - TOCropViewControllerDelegate
/*
- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didCropToImage:(nonnull UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    CGRect iamgeViewFrame = cropViewController.cropView.imageViewFrame;
    self.croppedFrame = cropRect;
    self.angle = angle;
    self.cropMaskView.hidden = NO;
//    UIImageView *imageView = self.imageView;
//
//    imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, self.angle * (M_PI/180.0f));
    self.imageView.frame = iamgeViewFrame;
    self.cropMaskView.frame = self.imageView.bounds;
 
    CGFloat padding = 0.0f;
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = cropRect.size;
    
    if (cropRect.size.width > viewFrame.size.width ||
        cropRect.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
    }
    else {
        CGPoint point = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
        imageFrame.origin = point;
    }
    cropRect = imageFrame;

//    CGPoint cropCenter = CGPointMake(cropRect.origin.x+cropRect.size.width*0.5, cropRect.origin.y+cropRect.size.height*0.5);
//    CGPoint convertPoint = [self.imageView.superview convertPoint:cropCenter fromView:self.imageView];
//    CGPoint viewCenter = self.view.center;
//    CGFloat tempX = 0;
//    CGFloat tempY = 0;
//    tempX = convertPoint.x - viewCenter.x;
//    tempY = convertPoint.y - viewCenter.y;
//    iamgeViewFrame.origin.x -= tempX;
//    iamgeViewFrame.origin.y -= tempY;
//    self.imageView.frame = iamgeViewFrame;

    [self.cropMaskView setMaskRect:cropRect];

    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:nil
                                                         toView:nil
                                                        toFrame:CGRectZero
                                                          setup:^{ }
                                                     completion:
     ^{
         
     }];
  
}

- (void)cropViewController:(nonnull TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled
{
    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:self.imageView.image
                                                         toView:self.imageView
                                                        toFrame:CGRectZero
                                                          setup:^{ }
                                                     completion:
     ^{
         
     }];
}

- (void)layoutImageView:(UIImage*)cropImage
{
    if (cropImage == nil)
        return;
    UIImageView *imageView = self.imageView;
    imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, self.angle * (M_PI/180.0f));
    imageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
 
    CGFloat padding = 0.0f;
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = cropImage.size;
    
    if (cropImage.size.width > viewFrame.size.width ||
        cropImage.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
        CGRect maskRect = [self.imageView.superview convertRect:imageFrame toView:self.imageView];
        [self.cropMaskView setMaskRect:maskRect];
    }
    else {
        CGPoint point = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
        imageFrame.origin = point;
        CGRect maskRect = [self.imageView.superview convertRect:imageFrame toView:self.imageView];
        [self.cropMaskView setMaskRect:maskRect];
       
    }
}

- (void)layoutImageView
{
    if (self.imageView.image == nil)
        return;
    
    CGFloat padding = 20.0f;
    
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.imageView.image.size;
    
    if (self.imageView.image.size.width > viewFrame.size.width ||
        self.imageView.image.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
        self.imageView.frame = imageFrame;
    }
    else {
        self.imageView.frame = imageFrame;
        self.imageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
    }
}
*/
@end
