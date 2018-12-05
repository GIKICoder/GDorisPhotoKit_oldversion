//
//  GDorisAlbumViewController.m
//  GDoris
//
//  Created by GIKI on 2018/8/8.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import "GDorisAlbumViewController.h"
#import "GDorisPhotoKitManager.h"
#import "GDorisCollection.h"
#import "GDorisPhotoAlbumCell.h"
@interface GDorisAlbumViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray * photoDatas;
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation GDorisAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    [self loadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


@end
