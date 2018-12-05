//
//  GDorisBasePhotoPickerController.m
//  GDoris
//
//  Created by GIKI on 2018/8/8.
//  Copyright © 2018年 GIKI. All rights reserved.
//


#import "GDorisBasePhotoPickerController.h"

#import "GDorisPhotoPickerControllerInternal.h"

typedef NS_ENUM(NSUInteger, GRecognizerState) {
    GRecognizerStateNone,
    GRecognizerStateLeft,
    GRecognizerStateRight,
};

@interface GDorisBasePhotoPickerController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIViewControllerPreviewingDelegate,GDorisZoomPresentingControllerProtocol>

@property (nonatomic,   weak) id <UIViewControllerPreviewing> previewing;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic, assign) GRecognizerState  recognizerState;
@property (nonatomic, assign) GRecognizerState  lastRecognizerState;
@property (nonatomic, strong) NSMutableArray * indexPaths;
@property (nonatomic, strong) NSIndexPath * beginIndexPath;
@property (nonatomic, strong) NSIndexPath * lastIndexPath;
@property (nonatomic, assign) BOOL  beginSelectState;

@end

@implementation GDorisBasePhotoPickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(1<0, @"请使用initWithConfiguration-delegate初始化photoPickerController");
    }
    return self;
}

- (instancetype)initWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration delegate:(GDorisPhotoPickerDelegate *)delegate
{
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.delegate = (id)delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUI];
    [self loadData];
    [self loadGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)loadData
{
    self.cellColumn = 4;
    self.cellPadding = self.configuration.pickerPadding;
    self.collectionEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    self.maxSelectCount = NSIntegerMax;
}

- (void)loadUI
{
    [self loadCollectionView];
    if (self.configuration.can3DTouchPreview) {
        [self load3DTouch];
    }
}

- (void)loadCollectionView
{
    [self.view addSubview:({
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[GDorisPhotoPickerBaseCell class] forCellWithReuseIdentifier:NSStringFromClass([GDorisPhotoPickerBaseCell class])];
        [_collectionView registerClass:[GDorisLivePhotoPickerCell class] forCellWithReuseIdentifier:NSStringFromClass([GDorisLivePhotoPickerCell class])];
        [_collectionView registerClass:[GDorisGifPhotoPickerCell class] forCellWithReuseIdentifier:NSStringFromClass([GDorisGifPhotoPickerCell class])];
        [_collectionView registerClass:[GDorisPhotoPickerCameraCell class] forCellWithReuseIdentifier:NSStringFromClass([GDorisPhotoPickerCameraCell class])];
        _collectionView;
    })];
}

- (void)load3DTouch
{
    if (@available(iOS 9,*)) {
        if ([self respondsToSelector:@selector(traitCollection)]) {
            if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
                if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) { //available
                    self.previewing = [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
                }
            }
        }
    }
}

- (void)loadGesture
{
    if (!self.configuration.gestureSelectEnabled) return;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    self.panGesture.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:self.panGesture];
    self.indexPaths = [NSMutableArray array];
}

#pragma mark - public Method

- (void)loadPhotoAssetsWithCollection:(GDorisCollection *)collection
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            PHAssetCollection * tempCollection = collection.collection;
            if (!tempCollection) {
                tempCollection = [GDorisPhotoKitManager fetchAllPhotoCollections].firstObject;
            }
            NSArray * assets = [GDorisPhotoKitManager fetchAllAssets:tempCollection mediaType:GDorisMediaTypeAll isReverse:weakSelf.configuration.isReveres];
            NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:assets.count];
            [assets enumerateObjectsUsingBlock:^(PHAsset* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PHAsset class]]) {
                    GDorisAsset * assetModel = [GDorisAsset createAsset:obj];
                    assetModel.index = idx;
                    assetModel.configuration = weakSelf.configuration;
                    [tempArray addObject:assetModel];
                }
            }];
            weakSelf.photoAssets = tempArray.copy;
            GSafeInvokeThread(^{
                [weakSelf.collectionView reloadData];
                [weakSelf collectionViewScroller];
            });
        });
    };
    [GDorisPhotoKitManager requestAuthorization:^(GDorisPhotoAuthorizationStatus status) {
        if (status == GDorisPhotoAuthorizationStatus_authorize) {
            if (block) {
                block();
            }
        }
    }];
  
}

#pragma mark - lazy load

- (NSMutableArray *)selectItems
{
    if (!_selectItems) {
        _selectItems = [[NSMutableArray alloc] init];
    }
    return _selectItems;
}

#pragma mark - performReload

- (void)performReload:(NSArray*)indexpaths
{
    __weak typeof(self) weakSelf = self;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [UIView performWithoutAnimation:^{
        [self.collectionView performBatchUpdates:^{
            if (indexpaths && indexpaths.count > 0) {
                [weakSelf.collectionView reloadItemsAtIndexPaths:indexpaths];
            } else {
                [weakSelf.collectionView reloadData];
            }
        } completion:^(BOOL finished) {
        }];
    }];
    [CATransaction commit];
}

- (void)collectionViewScroller
{
    if (!self.configuration.isReveres && self.photoAssets.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.photoAssets.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionBottom) animated:NO];
    }
}

#pragma mark - photo Select Method

- (BOOL)canSelectAsset:(GDorisAsset *)assetModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:shouldSelectAsset:)]) {
        return [self.delegate dorisPhotoPicker:self shouldSelectAsset:assetModel.asset];
    }
    if (self.selectItems.count >= self.maxSelectCount) {
        return NO;
    }
    return YES;
}

- (void)didSelectAsset:(GDorisAsset *)assetModel
{
    if (![self.selectItems containsObject:assetModel]) {
        if (self.configuration.selectCountEnabled) {
            assetModel.selectIndex = self.selectItems.count;
        }
        [self.selectItems addObject:assetModel];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didSelectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didSelectAsset:assetModel.asset];
    }
}

- (void)didDeselectAsset:(GDorisAsset *)assetModel
{
    __block NSMutableArray * indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForItem:assetModel.index inSection:0]];
    if ([self.selectItems containsObject:assetModel]) {
        [self.selectItems removeObject:assetModel];
        assetModel.animated = NO;
        if (self.configuration.selectCountEnabled) {
            assetModel.selectIndex = 0;
            [self.selectItems enumerateObjectsUsingBlock:^(GDorisAsset*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GDorisAsset * tfModel = [self.photoAssets objectAtIndex:obj.index];
                tfModel.selectIndex = idx;
                [indexPaths addObject:[NSIndexPath indexPathForItem:obj.index inSection:0]];
            }];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didDeselectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didDeselectAsset:assetModel.asset];
    }
    if (indexPaths.count > 0) {
        [self performReload:indexPaths.copy];
    }
}

- (void)didSelectDisabled:(BOOL)disabled
{
    self.selectDisabled = disabled;
    if (disabled) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{

        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
        }];
    }

}

#pragma mark - UIPanGestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.collectionView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan ) { //UIGestureRecognizerStateEnded
        
        [self.indexPaths removeAllObjects];
        self.beginIndexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (self.beginIndexPath.item >= self.photoAssets.count) return;
        if (!self.beginIndexPath) return;
        GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
        self.beginSelectState = !layout.isSelected;
        if (![self.indexPaths containsObject:self.beginIndexPath]) {
            [self.indexPaths addObject:self.beginIndexPath];
            GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
            [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            [self performReload:@[self.beginIndexPath]];
            self.lastIndexPath = self.beginIndexPath;
            return;
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged ) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        if (!self.beginIndexPath) {
            self.beginIndexPath = indexPath;
            GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
            self.beginSelectState = !layout.isSelected;
            if (![self.indexPaths containsObject:self.beginIndexPath]) {
                if (self.beginIndexPath.item >= self.photoAssets.count) return;
                if (!self.beginIndexPath) return;
                [self.indexPaths addObject:self.beginIndexPath];
                GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
                [self processGestureSelectAsset:layout changeState:self.beginSelectState];
                [self performReload:@[self.beginIndexPath]];
                self.lastIndexPath = indexPath;
                return;
            }
        }
        if (indexPath.item >= self.photoAssets.count) return;
        if (!indexPath) return;
        if (self.lastIndexPath.item == indexPath.item) return;
        self.lastIndexPath = indexPath;
        if (self.beginIndexPath.item < indexPath.item) {
            self.recognizerState = GRecognizerStateRight;
        } else {
            self.recognizerState = GRecognizerStateLeft;
        }
        if (self.lastRecognizerState == GRecognizerStateNone) {
            self.lastRecognizerState = self.recognizerState;
        }
        if (self.lastRecognizerState != self.recognizerState) {
            self.lastRecognizerState = self.recognizerState;
            if (![self.indexPaths containsObject:self.beginIndexPath]) {
                [self.indexPaths addObject:self.beginIndexPath];
                GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
                [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            } else {
                GDorisAsset *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
                [self processGestureSelectAsset:layout changeState:!layout.isSelected];
            }
        }
        NSInteger count = labs(indexPath.item - self.beginIndexPath.item);
        if ( count > 1) {
            for (int index = 1; index <= count; index++) {
                NSIndexPath *path = nil;
                if (self.beginIndexPath.item < indexPath.item) {
                    path = [NSIndexPath indexPathForItem:self.beginIndexPath.item+index inSection:0];
                } else {
                    path = [NSIndexPath indexPathForItem:self.beginIndexPath.item-index inSection:0];
                }
                if (![self.indexPaths containsObject:path]) {
                    [self.indexPaths addObject:path];
                    GDorisAsset *layout = [self.photoAssets objectAtIndex:path.item];
                    [self processGestureSelectAsset:layout changeState:self.beginSelectState];
                } else {
                    GDorisAsset *layout = [self.photoAssets objectAtIndex:path.item];
                    [self processGestureSelectAsset:layout changeState:!layout.isSelected] ;
                }
            }
        } else if(count == 1) {
            if (![self.indexPaths containsObject:indexPath]) {
                [self.indexPaths addObject:indexPath];
                GDorisAsset *layout = [self.photoAssets objectAtIndex:indexPath.item];
                [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            } else {
                GDorisAsset *layout = [self.photoAssets objectAtIndex:indexPath.item];
                [self processGestureSelectAsset:layout changeState:!layout.isSelected];
            }
        }
        self.beginIndexPath = indexPath;
        NSArray *array = self.indexPaths.copy;
        [self performReload:array];
    } else if (recognizer.state == UIGestureRecognizerStateEnded|| recognizer.state == UIGestureRecognizerStateCancelled ) {
        [self.indexPaths removeAllObjects];
        self.beginIndexPath = nil;
        self.recognizerState = 0;
        self.lastRecognizerState = 0;
    }
}

- (void)processGestureSelectAsset:(GDorisAsset*)assetModel changeState:(BOOL)isSelected
{
    if (isSelected && ![self canSelectAsset:assetModel]) return;
    
    assetModel.isSelected = isSelected;
    if (assetModel.isSelected) {
        [self didSelectAsset:assetModel];
    } else {
        [self didDeselectAsset:assetModel];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    
    if (@available(iOS 9.0, *)) {
        previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    } else {
        // Fallback on earlier versions
    }
    GDorisAsset * asset = self.photoAssets[indexPath.row];
    GDoris3DTouchPreviewController * vc = [[GDoris3DTouchPreviewController alloc] initWithDorisAsset:asset configuration:self.configuration];
    vc.indexPath = indexPath;
    return vc;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    GDoris3DTouchPreviewController *vc = (id)viewControllerToCommit;
    self.clickIndexPath = vc.indexPath;
    GDorisBasePhotoBrowserController * browser = [GDorisBasePhotoBrowserController photoBrowserWithDorisAssets:self.photoAssets beginIndex:vc.indexPath.row];
    self.transition = [GDorisPhotoZoomAnimatedTransition zoomAnimatedWithPresenting:self presented:browser];
    browser.transitioningDelegate = self.transition;
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.photoAssets.count <= indexPath.row) return nil;
    GDorisAsset * asset = self.photoAssets[indexPath.row];
    UICollectionViewCell<GDorisPhotoPickerCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:asset.cellClass forIndexPath:indexPath];
    asset.selectDisabled = self.selectDisabled;
    [cell configData:asset withIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    cell.shouldSelectHanlder = ^BOOL(GDorisAsset * _Nonnull assetModel) {
        return [weakSelf canSelectAsset:assetModel];
    };
    cell.didSelectHanlder = ^(GDorisAsset * _Nonnull assetModel) {
        [weakSelf didSelectAsset:assetModel];
        [weakSelf performReload:@[indexPath]];
    };
    cell.didDeselectHanlder = ^(GDorisAsset * _Nonnull assetModel) {
        [weakSelf didDeselectAsset:assetModel];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionViewDidSelectItemAtIndexPath:indexPath];
}

- (void)collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath
{}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = floor((width - self.collectionEdgeInsets.left - self.collectionEdgeInsets.right - (self.cellPadding * (self.cellColumn-1))) / self.cellColumn);
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.collectionEdgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellPadding;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark - GDorisZoomModalControllerProtocol

- (__kindof UIView *)presentingView
{
    return [self presentingViewAtIndex:self.clickIndexPath.item];
}

- (__kindof UIView *)presentingViewAtIndex:(NSInteger)index
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell<GDorisPhotoPickerCellProtocol> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        return cell.imageView;
    } else {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    
    return cell;
}

@end
