//
//  GDorisBasePhotoBrowserController.m
//  GDoris
//
//  Created by GIKI on 2018/8/14.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisBasePhotoBrowserController.h"
#import <objc/runtime.h>
#import "GDorisPhotoBrowserContentCell.h"
#import "GDorisPhotoBrowserAnimationCell.h"
#import "GDorisPhotoBrowserControllerInternal.h"
#import "GDorisPhotoBrowserVideoCell.h"
#import "GDorisPhotoPickerBrowserCell.h"
#define GDorisWidth ([[UIScreen mainScreen] bounds].size.width)
#define GDorisHeight ([[UIScreen mainScreen] bounds].size.height)
@interface GDorisBasePhotoBrowserController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * PhotoDatas;
@property (nonatomic, assign) NSUInteger  currentIndex;
@end

@implementation GDorisBasePhotoBrowserController

#pragma mark - init Method

- (instancetype)initWithPhotoItems:(NSArray<id<IGDorisPhotoItem>> *)photoItems index:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.PhotoDatas = photoItems;
        self.beginIndex = index;
        self.lineSpace = 20;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"请通过initWithPhotoItems:index:制定构造器初始化GDorisBasePhotoBrowserController");
    }
    return self;
}

#pragma mark - life Cycle Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUI];
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveFirstLoadImage:) name:kDorisPhotoZoomImageKey object:nil];
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
        [self scrollerCollectionViewWithIndex:self.beginIndex];
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
        [_collectionView registerClass:[GDorisPhotoBrowserAnimationCell class] forCellWithReuseIdentifier:@"GDorisPhotoBrowserAnimationCell"];
        [_collectionView registerClass:[GDorisPhotoBrowserVideoCell class] forCellWithReuseIdentifier:@"GDorisPhotoBrowserVideoCell"];
        [_collectionView registerClass:[GDorisPhotoPickerBrowserCell class] forCellWithReuseIdentifier:@"GDorisPhotoPickerBrowserCell"];
        
        _collectionView;
    })];
}

#pragma mark - kDorisPhotoZoomImageKey

- (void)ReceiveFirstLoadImage:(NSNotification *)notication
{
    UIImage * image = (UIImage *)notication.object;
    if (self.beginIndex >= self.PhotoDatas.count) {
        return;
    }
    id<IGDorisPhotoItem> photoItem = [self.PhotoDatas objectAtIndex:self.beginIndex];
    if (image && [image isKindOfClass:[UIImage class]] && [photoItem respondsToSelector:@selector(thumbImage)]) {
        photoItem.thumbImage = image;
    }
}

#pragma mark - Private Method

- (void)scrollerCollectionViewWithIndex:(NSInteger)index
{
    if (objc_getAssociatedObject(self, _cmd)) return;
    else objc_setAssociatedObject(self, _cmd, @"FirstLoadScrollerCollectionKey", OBJC_ASSOCIATION_RETAIN);
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
    CGPoint offset = CGPointMake(self.collectionView.contentOffset.x + _lineSpace*0.5, self.collectionView.contentOffset.y);
    [self.collectionView setContentOffset:offset];
}

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
    if (self.PhotoDatas.count <= indexPath.row) {
        return nil;
    }
    id<IGDorisPhotoItem> object = [self.PhotoDatas objectAtIndex:indexPath.row];

    NSString * Identifier = NSStringFromClass(GDorisPhotoPickerBrowserCell.class);
    if (object && [object respondsToSelector:@selector(isVideo)] && object.isVideo) {
        Identifier = NSStringFromClass(GDorisPhotoBrowserVideoCell.class);
    }
    GDorisPhotoBrowserContentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell configData:object forItemAtIndexPath:indexPath];
    cell.SingleTapHandler = ^(__kindof id  _Nonnull data) {
        [weakSelf singleTapContentHandler:data];
    };
    [self browserDidDisplayCell:cell forItemAtIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.PhotoDatas.count <= indexPath.row) {
        return;
    }
    self.currentIndex = indexPath.item;
    GDorisPhotoBrowserContentCell * browserCell = (GDorisPhotoBrowserContentCell *)cell;
    id  object = [self.PhotoDatas objectAtIndex:indexPath.row];
    [browserCell configWillDisplayCellData:object forItemAtIndexPath:indexPath];
    [self browserWillDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.PhotoDatas.count <= indexPath.row) {
        return;
    }
    GDorisPhotoBrowserContentCell * browserCell = (GDorisPhotoBrowserContentCell *)cell;
     id  object = [self.PhotoDatas objectAtIndex:indexPath.row];
    [browserCell configDidEndDisplayingCellData:object forItemAtIndexPath:indexPath];
    [self browserDidEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
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

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / GDorisWidth;
    [self browserDidEndDeceleratingWithIndex:index];
}

- (UIView *)presentedBackgroundView
{
    return _collectionView;
}

#pragma mark - override Method

/**
 图片浏览器滚动位置
 用于显示当前图片的index
 @param index 当前图片的index
 */
- (void)browserDidEndDeceleratingWithIndex:(NSInteger)index
{}

- (void)browserDidDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{}

- (void)browserWillDisplayCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{}

- (void)browserDidEndDisplayingCell:(__kindof UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{}

- (void)singleTapContentHandler:(id)data
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
    id<IGDorisPhotoItem> photo = [self.PhotoDatas objectAtIndex:indexpath.item];
    if (photo && photo.itemIndex != indexpath.item) {
        return photo.itemIndex;
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
