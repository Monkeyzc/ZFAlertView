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
#import "TouchIDManager.h"
#import "NSData+keyChain.h"

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
    
    
    BOOL supportTouchIDResult = [[TouchIDManager shareInstance] checkDeviceSupportTouchID];
    NSLog(@"%d", supportTouchIDResult);
    if (supportTouchIDResult) {
        UISwitch *touchIDSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), 40, 40, 60)];
        [touchIDSwitch addTarget:self action:@selector(switchTouchID:) forControlEvents: UIControlEventValueChanged];
        [self.view addSubview:touchIDSwitch];
        
        NSString *touchIDConfigure = [[NSUserDefaults standardUserDefaults] objectForKey: touchID_userDefault_key];
        touchIDSwitch.on = [touchIDConfigure isEqualToString:@"Yes"] ? YES : NO;
    }
    
    // 测试指纹数据库改变 或者删除
//    [NSData deleteDataFromKeyChainWithKey: touchID_keyChain_key];
}

- (void)clickBtn {
    
    NSString *touchIDConfigure = [[NSUserDefaults standardUserDefaults] objectForKey: touchID_userDefault_key];
    NSLog(@"touchIDConfigure: %@", touchIDConfigure);
    
    if ([touchIDConfigure isEqualToString:@"Yes"]) {
        NSLog(@"touch id功能可用");
        
        [[TouchIDManager shareInstance] verifyTouchIDWithSuccessBlock:^(NSString *password) {
            NSLog(@"验证成功: %@", password);
        } failedBlock:^(NSString *errorMessage) {
            NSLog(@"验证失败: %@", errorMessage);
        } userFallbackBlock:^{
            NSLog(@"用户点击 手动输入密码按钮");
            [self showPayView];
        }];
        
    } else {
        NSLog(@"使用手动输入密码");
        [self showPayView];
    }
    return;
}

- (void)showPayView {
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

- (void)switchTouchID:(UISwitch *)touchIDSwitch {
    if (touchIDSwitch.isOn) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [[TouchIDManager shareInstance] configureTouchIDWithSuccessBlock:^{
              NSLog(@"配置成功");
          } failedBlock:^{
              NSLog(@"配置失败");
              touchIDSwitch.on = NO;
          }];
        });
    } else {
        [[TouchIDManager shareInstance] deleteTouchIDConfigure];
    }
}

@end
