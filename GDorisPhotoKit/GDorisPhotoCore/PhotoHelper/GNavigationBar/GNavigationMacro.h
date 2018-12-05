//
//  GNavigationMacro.h
//  GNavigationBar
//
//  Created by GIKI on 2017/4/5.
//  Copyright © 2017年 GIKI. All rights reserved.
//

#ifndef GNavigationMacro_h
#define GNavigationMacro_h


/**
 调试开关,可方便查看每个元素布局

 @breif 禁止打开该开关提交.只可在开发中调试使用!!!
 */
#define G_NAVI_DEBUG 0

/**
 导航容器 相对于屏幕左右边的间距padding
 */
#define G_NAVI_LEFT_PADDING 12
#define G_NAVI_RIGHT_PADDING 12

/**
 导航容器 左右按钮之间的间距
 */
#define G_NAVI_LEFTITEM_PADDING 15
#define G_NAVI_RIGHTITEM_PADDING 15

/**
 导航容器 默认按钮大小
 */
#define G_NAVI_ITEM_SIZE CGSizeMake(20,20)

/**
 导航容器 文字按钮相关设置宏

 */

#define G_NAVI_TITLEBUTTON_COLOR [UIColor blackColor]
#define G_NAVI_TITLEBUTTON_COLOR_HIGH [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1.0]
#define G_NAVI_TITLEBUTTON_FONT [UIFont systemFontOfSize:16]
/**
 导航容器 背景颜色
 */
#define G_NAVI_BACKGROUND_COLOR @"F8F9FA"
/**
 导航容器 标题颜色与字号
 */
#define G_NAVI_TITLE_COLOR @"1B1B1B"

#define G_NAVI_TITLE_FONT 18

#define G_NAVI_BACK_IMAGE @"titlebar_bt_back01"
#define G_NAVI_BACK_IMAGE_HIGH @"titlebar_bt_back02"

#define G_SCREEN_WIDTH        ([[UIScreen mainScreen] bounds].size.width)
#define G_SCREEN_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define G_SCREEN_MAX_LENGTH   (MAX(G_SCREEN_WIDTH, G_SCREEN_HEIGHT))
#define G_SCREEN_MIN_LENGTH   (MIN(G_SCREEN_WIDTH, G_SCREEN_HEIGHT))
#define G_IS_IPHONE_X         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && G_SCREEN_MAX_LENGTH == 812.0)
#define G_IS_IPHONE_XR        ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && G_SCREEN_MAX_LENGTH == 896.0 && [[UIScreen mainScreen] scale] == 2.0)
#define G_IS_IPHONE_MAX       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && G_SCREEN_MAX_LENGTH == 896.0 && [[UIScreen mainScreen] scale] == 3.0)
#define G_IS_IPHONE_FOREHEAD  (G_IS_IPHONE_X || G_IS_IPHONE_XR || G_IS_IPHONE_MAX)

/// 导航栏高度 44
#define GNavBarContentHeight (44.0f)
/// 隐藏状态栏的情况下 也有值
#define GStatusBarHeight (G_IS_IPHONE_FOREHEAD ? (44.f) :(20.0f))

#define G_NAV_HEIGHT (GNavBarContentHeight+GStatusBarHeight)

//导航按钮附着类型
typedef NS_ENUM(NSUInteger, GNavItemAttachStyle) {
    GNavItemAttachStyle_left, 
    GNavItemAttachStyle_center,
    GNavItemAttachStyle_right,
};


#define GNAVColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define GNAVColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

// 随机色
#define GNAVRandomColor GNAVColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


#endif /* GNavigationMacro_h */
