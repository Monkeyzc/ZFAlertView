//
//  ZFBaseAlertView.h
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface ZFBaseAlertView : UIView

@property (nonatomic, assign, readwrite) BOOL allowTapBackgroundToDimiss; // default is true
@property (nonatomic, strong, readwrite) UIWindow *window;

- (void)configureSubviews;
- (void)show;
- (void)dismiss;
@end
