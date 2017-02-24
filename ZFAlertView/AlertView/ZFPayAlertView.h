//
//  ZFPayAlertView.h
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "ZFBaseAlertView.h"

typedef void (^CompleteHandler)(NSString *password);

@interface ZFPayAlertView : ZFBaseAlertView
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subTitleLabel;
@property (nonatomic, strong, readwrite) UILabel *amountLabel;
@property (nonatomic, strong, readwrite) CompleteHandler completeHander;
@end
