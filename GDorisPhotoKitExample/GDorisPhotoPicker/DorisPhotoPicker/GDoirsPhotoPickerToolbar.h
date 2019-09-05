//
//  GDoirsPhotoPickerToolbar.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/5.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, DorisPhotoPickerToolbarType) {
    DorisPhotoPickerToolbarLeft,
    DorisPhotoPickerToolbarCenter,
    DorisPhotoPickerToolbarRight,
};

@interface GDoirsPhotoPickerToolbar : UIView
@property (nonatomic, strong, readonly) UIButton * leftButton;
@property (nonatomic, strong, readonly) UIButton * centerButton;
@property (nonatomic, strong, readonly) UIButton * rightButton;
@property (nonatomic, assign) BOOL  enabled;

@property(nonatomic, copy) void (^photoToolbarClickBlock)(DorisPhotoPickerToolbarType itemType);
@end


NS_ASSUME_NONNULL_END
