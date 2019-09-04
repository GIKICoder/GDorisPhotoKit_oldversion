//
//  GDorisBasePhotoPickerController.m
//  GDoris
//
//  Created by GIKI on 2018/8/8.
//  Copyright © 2018年 GIKI. All rights reserved.
//


#import "GDorisBasePhotoPickerController.h"
#import "GDorisPhotoPickerControllerInternal.h"
#import "GDorisRunLoopWorker.h"
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

- (instancetype)initWithConfiguration:(GDorisPhotoPickerConfiguration *)configuration
{
    self = [super init];
    if (self) {
        self.configuration = configuration;
        [self __loadPageData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self __loadUI];
    [self __loadGesture];
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
    [[GDorisRunLoopWorker sharedInstance] removeAllTasks];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)__loadPageData
{
    self.cellColumn = 4;
    self.cellPadding = self.configuration.pickerPadding;
    self.collectionEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    self.maxSelectCount = NSIntegerMax;
}

- (void)__loadUI
{
    [self __loadCollectionView];
    if (self.configuration.can3DTouchPreview) {
        [self __load3DTouch];
    }
}

- (void)__loadCollectionView
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
        /// Tips:在iOS 10中，引入了新的单元预取API 启用此功能会显著降低滚动性能。
        if(@available(iOS 10.0, *))  {
            _collectionView.prefetchingEnabled = NO;
        }
        _collectionView;
    })];
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
     self.collectionView.frame = self.view.bounds;
}

- (void)__load3DTouch
{
    if (@available(iOS 9,*)) {
        if ([self respondsToSelector:@selector(traitCollection)]) {
            if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
                if (self.traitCollection.forceTouchCapability != UIForceTouchCapabilityUnavailable) { //available
                    self.previewing = [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
                } 
            }
        }
    }
}

- (void)__loadGesture
{
    if (!self.configuration.gestureSelectEnabled) return;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    self.panGesture.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:self.panGesture];
    self.indexPaths = [NSMutableArray array];
}

#pragma mark - public Method

- (void)loadPhotoAssetsWithCollection:(XCAssetsGroup *)collection
{
    
    __block NSMutableArray * tempArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    __block NSInteger index = 0;
    if (self.configuration.showCamera && self.configuration.isReveres) {
        GDorisAssetItem * camera = [[GDorisAssetItem alloc] init];
        camera.iscamera = YES;
        camera.cellClass = @"GDorisPhotoPickerCameraCell";
        camera.index = index ++;
        [tempArray addObject:camera];
    }
    
    __block GDorisAssetItem * preselectItem = nil;
    __block NSInteger blockIndex = 0;
    NSInteger loadCount = self.configuration.FirstNeedsLoadCount;
    [collection enumerateAssetsWithOptions:XCAlbumSortTypeReverse usingBlock:^(XCAsset * _Nonnull resultAsset) {
        blockIndex ++;
        if (blockIndex == loadCount && loadCount > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoAssets = tempArray.copy;
                [self.collectionView reloadData];
            });
        }
        if (resultAsset) {
            GDorisAssetItem * assetModel = [GDorisAssetItem createAssetItem:resultAsset configuration:weakSelf.configuration index:index++];
            if (index == 2) {
                preselectItem = assetModel;
            }
            if ([weakSelf.selectItemMaps objectForKey:assetModel.asset.identifier]) {
                GDorisAssetItem * selectItem = [weakSelf.selectItemMaps objectForKey:assetModel.asset.identifier];
                assetModel.isSelected = YES;
                assetModel.selectIndex = selectItem.selectIndex;
                selectItem.index = assetModel.index;
            }
            [tempArray addObject:assetModel];
        }
    }];
    if (self.configuration.showCamera && !self.configuration.isReveres) {
        GDorisAssetItem * camera = [[GDorisAssetItem alloc] init];
        camera.iscamera = YES;
        camera.cellClass = @"GDorisPhotoPickerCameraCell";
        camera.index = index ++;
        [tempArray addObject:camera];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoAssets = tempArray.copy;
        [self.collectionView reloadData];
        [self collectionViewScroller];
    });
}

/**
 重置页面选中状态
 */
- (void)resetPageSeletStatus
{
    [self.selectItems enumerateObjectsUsingBlock:^(GDorisAssetItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelected = NO;
    }];
    [self.selectItems removeAllObjects];
    [self.selectItemMaps removeAllObjects];
    self.onlyEnableSelectAssetType = XCAssetTypeUnknow;
    [self didSelectDisabled:NO];
}

- (void)setInitializerSelects:(NSArray<XCAsset *> *)initializerSelects
{
    _initializerSelects = initializerSelects;

    [initializerSelects enumerateObjectsUsingBlock:^(XCAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:XCAsset.class]) {
            GDorisAssetItem * assetItem  = [GDorisAssetItem createAssetItem:obj configuration:self.configuration index:idx];
            assetItem.isSelected = YES;
            assetItem.selectIndex = idx;
            [self pushSelectItem:assetItem];
        }
        if (idx == 0 && self.onlySelectOneMediaType) {
            self.onlyEnableSelectAssetType = obj.assetType;
        }
    }];
    if (!initializerSelects || initializerSelects.count <= 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:selectItemsChanged:)]) {
            [self.delegate dorisPhotoPicker:self selectItemsChanged:self.selectItems.copy];
        }
    }
}


#pragma mark - lazy load

- (NSMutableArray *)selectItems
{
    if (!_selectItems) {
        _selectItems = [[NSMutableArray alloc] init];
    }
    return _selectItems;
}

- (NSMutableDictionary *)selectItemMaps
{
    if (!_selectItemMaps) {
        _selectItemMaps = [[NSMutableDictionary alloc] init];
    }
    return _selectItemMaps;
}

#pragma mark - Private Method

- (void)pushSelectItem:(GDorisAssetItem *)item
{
    if (item && [item isKindOfClass:GDorisAssetItem.class]) {
        [self.selectItems addObject:item];
        self.selectItemMaps[item.asset.identifier] = item;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:selectItemsChanged:)]) {
        [self.delegate dorisPhotoPicker:self selectItemsChanged:self.selectItems.copy];
    }
}

- (void)popSelectItem:(GDorisAssetItem *)item
{
    if (item && [item isKindOfClass:GDorisAssetItem.class]) {
        [self.selectItemMaps removeObjectForKey:item.asset.identifier];
        if ([self.selectItems containsObject:item]) {
            [self.selectItems removeObject:item];
        } else {
            __block GDorisAssetItem * alreaditem = nil;
            [self.selectItems enumerateObjectsUsingBlock:^(GDorisAssetItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.asset.identifier isEqualToString:item.asset.identifier]) {
                    alreaditem = obj;
                    *stop = YES;
                }
            }];
            if (alreaditem) {
                [self.selectItems removeObject:alreaditem];
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:selectItemsChanged:)]) {
        [self.delegate dorisPhotoPicker:self selectItemsChanged:self.selectItems.copy];
    }
}

/**
 获取当前选中资源类型的最大数量

 @param asset <#asset description#>
 @return <#return value description#>
 */
- (NSInteger)getAssetMaxCount:(XCAsset *)asset
{
    if (self.selectCountRegular && self.selectCountRegular.count > 0) {
        NSNumber * assetType = @(asset.assetType);
        if ([self.selectCountRegular.allKeys containsObject:assetType]) {
            NSNumber * MaxCount = [self.selectCountRegular objectForKey:assetType];
            if ([MaxCount isKindOfClass:NSNumber.class]) {
                return [MaxCount integerValue];
            }
        }
    }
    return self.maxSelectCount;
}

#pragma mark - performReload

- (void)performReload:(NSArray*)indexpaths
{
    __weak typeof(self) weakSelf = self;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (!indexpaths || indexpaths.count <= 0) {
         [self.collectionView reloadData];
    } else {
        [UIView performWithoutAnimation:^{
            [self.collectionView performBatchUpdates:^{
                if (indexpaths && indexpaths.count > 0) {
                    [weakSelf.collectionView reloadItemsAtIndexPaths:indexpaths];
                }
            } completion:^(BOOL finished) {
            }];
        }];
    }
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

- (BOOL)override_canSelectAsset:(GDorisAssetItem *)assetModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:shouldSelectAsset:)]) {
        return [self.delegate dorisPhotoPicker:self shouldSelectAsset:assetModel.asset];
    }
    NSInteger maxCount = [self getAssetMaxCount:assetModel.asset];
    if (self.selectItems.count >= maxCount) {
        return NO;
    }
    if (self.onlySelectOneMediaType && self.selectItems.count > 0) {
        GDorisAssetItem * assetItem = self.selectItems.firstObject;
        if (assetItem.asset.assetType == assetModel.asset.assetType) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)override_didSelectAsset:(GDorisAssetItem *)assetModel
{
    if (![self.selectItemMaps objectForKey:assetModel.asset.identifier]) {
        if (self.configuration.selectCountEnabled) {
            assetModel.selectIndex = self.selectItems.count;
        }
        [self pushSelectItem:assetModel];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didSelectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didSelectAsset:assetModel.asset];
    }
    NSInteger maxCount = [self getAssetMaxCount:assetModel.asset];
    BOOL NeedsReloadAll = NO;
    if (self.selectItems.count == maxCount) {
        if (!self.selectDisabled) {
            [self didSelectDisabled:YES];
            NeedsReloadAll = YES;
        }
    }
    if (self.onlySelectOneMediaType) {
        self.onlyEnableSelectAssetType = assetModel.asset.assetType;
        if (self.selectItems.count <= 1) {
            NeedsReloadAll = YES;
        }
    }
    if (self.photoAssets.count > assetModel.index && !NeedsReloadAll) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetModel.index inSection:0];
        [self performReload:@[indexPath]];
    } else {
        [self performReload:nil];
    }
}

- (void)override_didDeselectAsset:(GDorisAssetItem *)assetModel
{
    __block NSMutableArray * indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForItem:assetModel.index inSection:0]];
    if ([self.selectItemMaps objectForKey:assetModel.asset.identifier]) {
        [self popSelectItem:assetModel];
        assetModel.animated = NO;
        if (self.configuration.selectCountEnabled) {
            assetModel.selectIndex = 0;
            [self.selectItems enumerateObjectsUsingBlock:^(GDorisAssetItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GDorisAssetItem * tfModel = [self.photoAssets objectAtIndex:obj.index];
                tfModel.selectIndex = idx;
                [indexPaths addObject:[NSIndexPath indexPathForItem:obj.index inSection:0]];
            }];
        }
    }
    BOOL NeedsReloadAll = NO;
    if (self.onlySelectOneMediaType && self.selectItems.count == 0) {
        self.onlyEnableSelectAssetType = XCAssetTypeUnknow;
        NeedsReloadAll = YES;
    }
    if (self.selectDisabled) {
        [self didSelectDisabled:NO];
        NeedsReloadAll = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dorisPhotoPicker:didDeselectAsset:)]) {
        [self.delegate dorisPhotoPicker:self didDeselectAsset:assetModel.asset];
    }
    if (NeedsReloadAll) {
        [self performReload:nil];
    } else {
        [self performReload:indexPaths.copy];
    }
}

- (void)didSelectDisabled:(BOOL)disabled
{
    self.selectDisabled = disabled;
}

#pragma mark - Override Method

- (void)override_collectionViewDidSelectItemAtIndexPath:(NSIndexPath*)indexPath
{}

- (void)override_previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{}

#pragma mark - UIPanGestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.collectionView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan ) { //UIGestureRecognizerStateEnded
        
        [self.indexPaths removeAllObjects];
        self.beginIndexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (self.beginIndexPath.item >= self.photoAssets.count) return;
        if (!self.beginIndexPath) return;
        GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
        self.beginSelectState = !layout.isSelected;
        if (![self.indexPaths containsObject:self.beginIndexPath]) {
            [self.indexPaths addObject:self.beginIndexPath];
            GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
            [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            [self performReload:@[self.beginIndexPath]];
            self.lastIndexPath = self.beginIndexPath;
            return;
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged ) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        if (!self.beginIndexPath) {
            self.beginIndexPath = indexPath;
            GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
            self.beginSelectState = !layout.isSelected;
            if (![self.indexPaths containsObject:self.beginIndexPath]) {
                if (self.beginIndexPath.item >= self.photoAssets.count) return;
                if (!self.beginIndexPath) return;
                [self.indexPaths addObject:self.beginIndexPath];
                GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
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
                GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
                [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            } else {
                GDorisAssetItem *layout = [self.photoAssets objectAtIndex:self.beginIndexPath.item];
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
                    GDorisAssetItem *layout = [self.photoAssets objectAtIndex:path.item];
                    [self processGestureSelectAsset:layout changeState:self.beginSelectState];
                } else {
                    GDorisAssetItem *layout = [self.photoAssets objectAtIndex:path.item];
                    [self processGestureSelectAsset:layout changeState:!layout.isSelected] ;
                }
            }
        } else if(count == 1) {
            if (![self.indexPaths containsObject:indexPath]) {
                [self.indexPaths addObject:indexPath];
                GDorisAssetItem *layout = [self.photoAssets objectAtIndex:indexPath.item];
                [self processGestureSelectAsset:layout changeState:self.beginSelectState];
            } else {
                GDorisAssetItem *layout = [self.photoAssets objectAtIndex:indexPath.item];
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

- (void)processGestureSelectAsset:(GDorisAssetItem*)assetModel changeState:(BOOL)isSelected
{
    if (isSelected && ![self override_canSelectAsset:assetModel]) return;
    
    assetModel.isSelected = isSelected;
    if (assetModel.isSelected) {
        [self override_didSelectAsset:assetModel];
    } else {
        [self override_didDeselectAsset:assetModel];
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
    GDorisAssetItem * asset = self.photoAssets[indexPath.row];
    GDoris3DTouchPreviewController * vc = [[GDoris3DTouchPreviewController alloc] initWithDorisAsset:asset configuration:self.configuration];
    vc.indexPath = indexPath;
    return vc;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    GDoris3DTouchPreviewController *vc = (id)viewControllerToCommit;
    self.clickIndexPath = vc.indexPath;
    [self override_previewingContext:previewingContext commitViewController:viewControllerToCommit];
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
    GDorisAssetItem * assetItem = self.photoAssets[indexPath.row];
    UICollectionViewCell<GDorisPhotoPickerCellProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:assetItem.cellClass forIndexPath:indexPath];
    
    assetItem.selectDisabled = self.selectDisabled;
    if (self.onlySelectOneMediaType
        && self.onlyEnableSelectAssetType != XCAssetTypeUnknow
        && assetItem.asset.assetType != self.onlyEnableSelectAssetType) {
        assetItem.selectDisabled = YES;
    }
    cell.currentIndexPath = indexPath;
    [cell configData:assetItem withIndex:indexPath.row];
    [[GDorisRunLoopWorker sharedInstance] postTask:^BOOL{
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        if ([cell respondsToSelector:@selector(loadLargerAsset:)]) {
            [cell loadLargerAsset:assetItem];
        }
        return YES;
    } withKey:indexPath];
    
    __weak typeof(self) weakSelf = self;
    cell.shouldSelectHanlder = ^BOOL(GDorisAssetItem * _Nonnull assetModel) {
        return [weakSelf override_canSelectAsset:assetModel];
    };
    cell.didSelectHanlder = ^(GDorisAssetItem * _Nonnull assetModel) {
        [weakSelf override_didSelectAsset:assetModel];
    };
    cell.didDeselectHanlder = ^(GDorisAssetItem * _Nonnull assetModel) {
        [weakSelf override_didDeselectAsset:assetModel];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.clickIndexPath = indexPath;
    [self override_collectionViewDidSelectItemAtIndexPath:indexPath];
}

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

- (void)setClickIndexPath:(NSIndexPath *)clickIndexPath
{
    _clickIndexPath = clickIndexPath;
}

#pragma mark - GDorisZoomModalControllerProtocol

- (__kindof UIView *)presentingView
{
    NSInteger index = 1;
    if (self.clickIndexPath) {
        index = self.clickIndexPath.item;
        if (self.photoAssets.count <= index) {
            return nil;
        }
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewCell<GDorisPhotoPickerCellProtocol> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.clickIndexPath = nil;
        return cell.imageView;
    } else if (self.selectItems.count > 0) {
        GDorisAssetItem * assetItem = self.selectItems.firstObject;
        if (assetItem.index < self.photoAssets.count) {
            GDorisAssetItem *item = [self.photoAssets objectAtIndex:assetItem.index];
            if ([item.asset.identifier isEqualToString:assetItem.asset.identifier]) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:assetItem.index inSection:0];
                UICollectionViewCell<GDorisPhotoPickerCellProtocol> *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
                return cell.imageView;
            }
        }
    }
    return nil;
}

- (__kindof UIView *)presentingViewAtIndex:(NSInteger)index
{
    if (self.photoAssets.count <= index) {
        return nil;
    }
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
