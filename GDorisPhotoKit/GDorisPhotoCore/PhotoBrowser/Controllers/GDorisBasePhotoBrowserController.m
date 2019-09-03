//
//  GDorisBasePhotoBrowserController.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisBasePhotoBrowserController.h"
#import <objc/runtime.h>
#import "GDorisPhotoHelper.h"
#import "GDorisPhotoBrowserContentCell.h"
#import "GDorisPhotoBrowserLivePhotoCell.h"
#import "GDorisPhotoBrowseGifCell.h"
#import "GDorisPhotoBrowserControllerInternal.h"

@interface GDorisBasePhotoBrowserController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * PhotoDatas;
@property (nonatomic, assign) CGFloat  lineSpace;
@end

@implementation GDorisBasePhotoBrowserController

#pragma mark - init Method

+ (instancetype)photoBrowserWithDorisAssets:(NSArray<GDorisAsset *> *)dorisAssets beginIndex:(NSInteger)index
{
    GDorisBasePhotoBrowserController * vc = [[[self class] alloc] initWithDorisAssets:dorisAssets beginIndex:index];
    return vc;
}

- (instancetype)initWithDorisAssets:(NSArray<GDorisAsset *> *)dorisAssets beginIndex:(NSInteger)index
{
    if (self = [super init]) {
        self.PhotoDatas = dorisAssets.copy;
        self.beginIndex = index;
        self.lineSpace = 20;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

#pragma mark - life Cycle Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(-(_lineSpace / 2), 0,self.view.bounds.size.width + _lineSpace, self.view.bounds.size.height);
    if (self.beginIndex != 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.beginIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
            if (objc_getAssociatedObject(self, _cmd)) return;
            else objc_setAssociatedObject(self, _cmd, @"FirstLoad", OBJC_ASSOCIATION_RETAIN);
            CGPoint offset = CGPointMake(self.collectionView.contentOffset.x + _lineSpace*0.5, self.collectionView.contentOffset.y);
            [self.collectionView setContentOffset:offset];
    }
}

- (void)dealloc
{
    NSLog(@"%@ dealloc~~",NSStringFromClass([self class]));
}

#pragma mark - load UI

- (void)loadUI
{
    [self.view addSubview:({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.delaysContentTouches = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[GDorisPhotoBrowserContentCell class] forCellWithReuseIdentifier:@"GDorisPhotoBrowserContentCell"];
           [_collectionView registerClass:[GDorisPhotoBrowserLivePhotoCell class] forCellWithReuseIdentifier:@"GDorisPhotoBrowserLivePhotoCell"];
          [_collectionView registerClass:[GDorisPhotoBrowseGifCell class] forCellWithReuseIdentifier:@"GDorisPhotoBrowseGifCell"];
        _collectionView;
    })];
}


#pragma mark - Private Method

- (UIImageView *)currentImageView
{
    GDorisPhotoBrowserContentCell * cell = (id)[self.collectionView visibleCells].firstObject;
    return [cell containerView];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PhotoDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisAsset * asset = self.PhotoDatas[indexPath.row];
    GDorisPhotoBrowserContentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisPhotoBrowserContentCell" forIndexPath:indexPath];
    if (asset.subType == GDorisImageSubTypeLivePhoto) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GDorisPhotoBrowserLivePhotoCell" forIndexPath:indexPath];
    } else if (asset.subType == GDorisImageSubTypeGIF) {
         cell = [collectionView  dequeueReusableCellWithReuseIdentifier:@"GDorisPhotoBrowseGifCell" forIndexPath:indexPath];
    }

    [cell configData:asset forItemAtIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    cell.SingleTapHandler = ^(__kindof id  _Nonnull data) {
        [weakSelf singleTapContentHandler:data];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisPhotoBrowserContentCell * browserCell = (GDorisPhotoBrowserContentCell *)cell;
    GDorisAsset * asset = [self.PhotoDatas objectAtIndex:indexPath.item];
    [browserCell configWillDisplayCellData:asset forItemAtIndexPath:indexPath];
    [self browserWillDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisPhotoBrowserContentCell * browserCell = (GDorisPhotoBrowserContentCell *)cell;
    GDorisAsset * asset = self.PhotoDatas[indexPath.row];
    [browserCell configDidEndDisplayingCellData:asset forItemAtIndexPath:indexPath];
    [self browserDidEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(GDorisWidth, GDorisHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, _lineSpace*0.5, 0, _lineSpace*0.5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _lineSpace;
}


- (UIView *)presentedBackgroundView
{
    return _collectionView;
}

#pragma mark - override Method

- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)browserDidEndDisplayingCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)singleTapContentHandler:(GDorisAsset *)data
{
}

#pragma mark - public Method

- (NSIndexPath*)currentIndexPath
{
    NSIndexPath *indexpath = [self.collectionView indexPathsForVisibleItems].firstObject;
    return indexpath;
}

#pragma mark - GDorisZoomPresentedControllerProtocol

- (NSInteger)indexOfPresentedView
{
    NSIndexPath *indexpath = [self.collectionView indexPathsForVisibleItems].firstObject;
    GDorisAsset * asset = [self.PhotoDatas objectAtIndex:indexpath.item];
    if (asset && asset.index != indexpath.item) {
        return asset.index;
    }
    return indexpath.item;
}

- (__kindof UIView *)presentedView
{
    GDorisPhotoBrowserContentCell * cell = (id)[self.collectionView visibleCells].firstObject;
    return [cell containerView];
}

- (__kindof UIScrollView *)presentedScrollView
{
    GDorisPhotoBrowserContentCell * cell = (id)[self.collectionView visibleCells].firstObject;
    if (!cell) {
        NSIndexPath *indexpath =  [NSIndexPath indexPathForItem:self.beginIndex inSection:0];
        cell = (id)[self.collectionView cellForItemAtIndexPath:indexpath];
    }
    return [cell scrollView];
}

@end
