//
//  ViewController.m
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "ViewController.h"
#import "ZFPayAlertView.h"
#import "SVProgressHUD.h"

@interface ViewController ()
@property (nonatomic, strong, readwrite) ZFPayAlertView *payAlertView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, 40, 80, 80)];
    btn.backgroundColor = [UIColor purpleColor];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)clickBtn {
    ZFPayAlertView *payAlertView = [[ZFPayAlertView alloc] init];
    payAlertView.titleLabel.text = @"请输入密码";
    payAlertView.subTitleLabel.text = @"手机充值";
    payAlertView.amountLabel.text = @"$1,000";
    payAlertView.completeHander  = ^(NSString * password) {
        NSLog(@"password: %@", password);
        [SVProgressHUD show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    };
    [payAlertView show];
}

@end
