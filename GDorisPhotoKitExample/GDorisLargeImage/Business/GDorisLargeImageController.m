//
//  GDorisLargeImageController.m
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/6.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import "GDorisLargeImageController.h"
#import "GDorisLargeImageView.h"
#import "GDorisTiledImageBuilder.h"
#import "PhotoScrollerCommon.h"
@interface GDorisLargeImageController ()
@property (nonatomic, strong) GDorisLargeImageView * imageView_large;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) NSMutableArray * tileBuilders;
@property (nonatomic, assign) uint32_t         milliSeconds;
@property (nonatomic, assign) BOOL             ok2tile;
@end

@implementation GDorisLargeImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tileBuilders = [NSMutableArray array];
    self.view.backgroundColor = UIColor.whiteColor;
    self.imageView_large = [[GDorisLargeImageView alloc] init];
    [self.view addSubview:self.imageView_large];
    self.imageView_large.frame = CGRectMake(20, 100, 320, 320);
    self.imageView_large.frame = self.view.bounds;
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = self.imageView_large.bounds;
    
    [self constructStaticImages];
}

- (void)constructStaticImages
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t que = dispatch_queue_create("com.dfh.PhotoScroller", DISPATCH_QUEUE_SERIAL);
    NSUInteger multiCore = [[NSProcessInfo processInfo] processorCount] - 1;
    ///Space6
    NSString *path = [[NSBundle mainBundle] pathForResource:@"large_leaves_70mp" ofType:@"jpg"];
    [self.tileBuilders addObject:@""];
    // Normal Case
    // thread if we have multiple cores
    dispatch_group_async(group, multiCore ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) : que, ^
                         {
                             GDorisTiledImageBuilder *tb = [[GDorisTiledImageBuilder alloc] initWithImagePath:path withDecode:libjpegTurboDecoder size:CGSizeMake(320, 320) orientation:0];
                             dispatch_group_async(group, que, ^{ [self.tileBuilders replaceObjectAtIndex:0 withObject:tb]; self.milliSeconds += tb.milliSeconds; });
                         } );
    uint32_t count = 1;
    uint32_t ms = self.milliSeconds/count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          self.navigationItem.title = [NSString stringWithFormat:@"DecodeTime: %u ms", ms];
                                        
                                          self.ok2tile = YES;
                                          [self tilePages];
                                      });
                       //dispatch_release(group);
                       //dispatch_release(que);
                   } );
}

- (void)tilePages
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Space6" ofType:@"jpg"];
//    self.imageView.image = [UIImage imageWithContentsOfFile:path];
    [self.imageView_large displayObject:self.tileBuilders.firstObject];
}
@end
