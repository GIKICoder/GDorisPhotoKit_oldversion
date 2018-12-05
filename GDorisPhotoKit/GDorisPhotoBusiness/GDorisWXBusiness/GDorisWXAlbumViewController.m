//
//  GDorisWXAlbumViewController.m
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXAlbumViewController.h"
#import "GNavigationBar.h"
#import "GDorisPhotoKitManager.h"
#import "GDorisCollection.h"
#import "GDorisPhotoAlbumCell.h"
#import "UIView+GDoris.h"
#import "GDorisWXPhotoPickerController.h"
@interface GDorisWXAlbumViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray * photoDatas;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) GNavigationBar * navigationBar;
@end

@implementation GDorisWXAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar = [GNavigationBar navigationBar];
    [self.navigationBar setNavigationEffectWithStyle:(UIBlurEffectStyleDark)];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.title = @"相机";
    self.navigationBar.titleColor = UIColor.whiteColor;
    self.navigationBar.titleFont = [UIFont boldSystemFontOfSize:18];
    GNavigationItem * cancel = [GNavItemFactory createTitleButton:@"取消" titleColor:UIColor.whiteColor highlightColor:UIColor.lightGrayColor target:self selctor:@selector(cancel)];
    self.navigationBar.rightNavigationItem = cancel;
    [self loadUI];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    GDorisPhotoAuthorizationStatus status = [GDorisPhotoKitManager authorizationStatus];
    if (status == GDorisPhotoAuthorizationStatus_authorize) {
        if (self.photoDatas.count <= 0) {
            [self loadData];
        }
    } else {
        [GDorisPhotoKitManager requestAuthorization:^(GDorisPhotoAuthorizationStatus status) {
            if (status == GDorisPhotoAuthorizationStatus_authorize) {
                if (self.photoDatas.count <= 0) {
                    [self loadData];
                }
            }
        }];
    }
   
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.g_width, self.view.g_height-self.navigationBar.g_height);
}

- (void)loadUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:({
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView;
    })];
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * array = [GDorisPhotoKitManager fetchAllPhotoCollections];
        if (array.count > 0) {
            __block NSMutableArray * temp = [NSMutableArray arrayWithCapacity:array.count];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PHAssetCollection class]]) {
                    [temp addObject:[GDorisCollection createCollection:obj]];
                }
            }];
            self.photoDatas = temp.copy;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}


#pragma mark -- TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDorisPhotoAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GDorisPhotoAlbumCell"];
    if (!cell) {
        cell = [[GDorisPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GDorisPhotoAlbumCell"];
    }
    if (self.photoDatas.count > indexPath.row) {
        GDorisCollection *collection = self.photoDatas[indexPath.row];
        [cell configCollectionModel:collection];
        
    }
    return cell;
}

#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.photoDatas.count > indexPath.row) {
        GDorisCollection *collection = self.photoDatas[indexPath.row];
        GDorisWXPhotoPickerController * picker = [GDorisWXPhotoPickerController wxPhotoPickerControllerDelegate:nil collection:collection];
        [self.navigationController pushViewController:picker animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
