//
//  ZFBaseAlertView.m
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "ZFBaseAlertView.h"

@interface ZFBaseAlertView()
@end

@implementation ZFBaseAlertView

- (instancetype)init {
    if (self = [super init]) {

        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        
        self.allowTapBackgroundToDimiss = YES;
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
//    NSLog(@"ZFBaseAlertView - configureSubviews");
}

- (void)show {
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    if (self.allowTapBackgroundToDimiss) {
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
    }
}

- (void)dismiss {
//    NSLog(@"dimiss");
//    self.window = nil;
}

@end
