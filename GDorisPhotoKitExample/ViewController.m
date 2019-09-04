//
//  ViewController.m
//  GDorisPhotoKit
//
//  Created by GIKI on 2019/9/3.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "ViewController.h"
#import "GDorisWXPhotoPickerController.h"
#import "UINavigationController+XCCStatusBar.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray * datas;
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = @[
                   @{@"title":@"WXPhotoPicker",
                     @"controller":@"GDorisDraw2ViewController"
                     },
                   @{@"title":@"DorisPhotoPicker",
                     @"controller":@"GDorisDraw2ViewController"
                     }
                   ];
    [self.view addSubview:({
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView;
    })];
    [self CGDTest];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


- (void)CGDTest
{
    if ([[NSThread currentThread] isMainThread]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"4");
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"5");
        });
        [self performSelector:@selector(test2)];
        [self performSelector:@selector(test3) withObject:nil afterDelay:0];
        
        [self test1];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"6");
        });
    }
}


- (void)test1{
    NSLog(@"1");
}
- (void)test2{
    NSLog(@"2");
}
- (void)test3{
    NSLog(@"3");
}
#pragma mark -- TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
    }
    cell.textLabel.text = self.datas[indexPath.row][@"title"];
    return cell;
}

#pragma mark -- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.datas[indexPath.row][@"title"];
    if ([title isEqualToString:@"WXPhotoPicker"]) {
        GDorisWXPhotoPickerController * wxpicker = [GDorisWXPhotoPickerController WXPhotoPickerController:nil];
        [wxpicker presentPhotoPickerController:self];
        return;
    }
//    NSString *cla = self.datas[indexPath.row][@"controller"];
//    Class clazz = NSClassFromString(cla);
//    [self.navigationController pushViewController:[clazz new] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end

