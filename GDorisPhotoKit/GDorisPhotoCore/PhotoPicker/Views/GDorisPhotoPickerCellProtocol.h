//
//  GDorisPhotoPickerCellProtocol.h
//  GDoris
//
//  Created by GIKI on 2018/8/24.
//  Copyright © 2018年 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDorisAsset.h"


NS_ASSUME_NONNULL_BEGIN

@protocol GDorisPhotoPickerCellProtocol <NSObject>

- (void)configData:(GDorisAsset*)asset withIndex:(NSInteger)index;

- (UIImageView *)imageView;

@optional
@property(nonatomic, copy) BOOL (^shouldSelectHanlder)(GDorisAsset *assetModel);
@property(nonatomic, copy) void (^didSelectHanlder)(GDorisAsset *assetModel);
@property(nonatomic, copy) void (^didDeselectHanlder)(GDorisAsset *assetModel);

@end

NS_ASSUME_NONNULL_END
