//
//  GDorisWXAlbumViewController.m
//  GDoris
//
//  Created by GIKI on 2018/9/27.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisWXAlbumViewController.h"
#import "GNavigationBar.h"
#import "XCAssetsGroup.h"
#import "GDorisPhotoAlbumCell.h"
#import "UIView+GDoris.h"
#import "GDorisWXPhotoPickerController.h"
#import "XCAssetsManager.h"
#import "Masonry.h"
#import "GDorisPhotoHelper.h"
@interface GDorisWXAlbumViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray * photoDatas;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) GNavigationBar * navigationBar;
@property (nonatomic, strong) GDorisPhotoPickerConfiguration * configuration;
@property (nonatomic, strong) UIView * notAuthorizedView;
@end

@implementation GDorisWXAlbumViewController

+ (instancetype)WXAlbumViewController:(GDorisPhotoPickerConfiguration *)configuration
{
    GDorisWXAlbumViewController * album = [[GDorisWXAlbumViewController alloc] init];
    album.configuration = configuration;
    return album;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar = [GNavigationBar navigationBar];
    [self.navigationBar setNavigationEffectWithStyle:(UIBlurEffectStyleDark)];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.title = @"照片";
    self.navigationBar.titleColor = UIColor.whiteColor;
    self.navigationBar.titleFont = [UIFont boldSystemFontOfSize:18];
    GNavigationItem * cancel = [GNavItemFactory createTitleButton:@"取消" titleColor:UIColor.whiteColor highlightColor:UIColor.lightGrayColor target:self selctor:@selector(cancel)];
    self.navigationBar.rightNavigationItem = cancel;
    [self loadUI];
    [self checkAlbumAuthorizationStatus];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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


#pragma mark - Lazy load

- (UIView *)notAuthorizedView
{
    if (!_notAuthorizedView) {
        _notAuthorizedView = [[UIView alloc] init];
        [self.view addSubview:_notAuthorizedView];
        _notAuthorizedView.backgroundColor = UIColor.whiteColor;
        _notAuthorizedView.frame = self.tableView.bounds;
        UILabel * label = [UILabel new];
        label.text = @"开启相册权限,分享更好的自己";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [GDorisPhotoHelper colorWithHex:@"666666"];
        [_notAuthorizedView addSubview:label];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[GDorisPhotoHelper colorWithHex:@"666666"] forState:UIControlStateNormal];
        button.backgroundColor = [GDorisPhotoHelper colorWithHex:@"29CE85"];
        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        [button setTitle:@"去开启" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(authorizationStatusClick) forControlEvents:UIControlEventTouchUpInside];
        [_notAuthorizedView addSubview:button];
        [_notAuthorizedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.tableView);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(60);
        }];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, 40));
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(label.mas_bottom).mas_offset(25);
        }];
    }
    return _notAuthorizedView;
}


- (void)checkAlbumAuthorizationStatus
{
    XCAssetAuthorizationStatus status = [XCAssetsManager authorizationStatus];
    if (status == XCAssetAuthorizationStatusAuthorized) {
        [self loadData];
    } else if (status == XCAssetAuthorizationStatusNotAuthorized) { ///手动禁止
        self.notAuthorizedView.hidden = NO;
        [self.view bringSubviewToFront:self.notAuthorizedView];
    } else {
        [XCAssetsManager requestAuthorization:^(XCAssetAuthorizationStatus status) {
            if (status == XCAssetAuthorizationStatusAuthorized) {
                [self loadData];
            } else {
                self.notAuthorizedView.hidden = NO;
                [self.view bringSubviewToFront:self.notAuthorizedView];
            }
        }];
    }
}

- (void)loadData
{
   __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSMutableArray * arrayM = [NSMutableArray array];
        [[XCAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:weakSelf.configuration.albumType showEmptyAlbum:weakSelf.configuration.emptyAlbumEnabled showSmartAlbumIfSupported:weakSelf.configuration.samrtAlbumEnabled usingBlock:^(XCAssetsGroup * _Nonnull resultAssetsGroup) {
            if (resultAssetsGroup) {
                [arrayM addObject:resultAssetsGroup];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.photoDatas = arrayM.copy;
            [weakSelf.tableView reloadData];
        });
      
    });
}

- (void)authorizationStatusClick
{
    [GDorisPhotoHelper gotoSystemSettingPage];
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
        XCAssetsGroup *collection = self.photoDatas[indexPath.row];
        [cell configCollectionModel:collection];
        
    }
    return cell;
}

#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.photoDatas.count > indexPath.row) {
        XCAssetsGroup *collection = self.photoDatas[indexPath.row];
        GDorisWXPhotoPickerController * picker = [GDorisWXPhotoPickerController WXPhotoPickerController:self.configuration collection:collection];
        [self.navigationController pushViewController:picker animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
