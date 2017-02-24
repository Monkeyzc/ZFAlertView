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

@property (weak, nonatomic) IBOutlet UISwitch *touchIDSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BOOL supportTouchIDResult = [[TouchIDManager shareInstance] checkDeviceSupportTouchID];
    NSLog(@"%d", supportTouchIDResult);
    if (supportTouchIDResult) {
        NSString *touchIDConfigure = [[NSUserDefaults standardUserDefaults] objectForKey: touchID_userDefault_key];
        self.touchIDSwitch.on = [touchIDConfigure isEqualToString:@"Yes"] ? YES : NO;
    }
    
    // 测试指纹数据库改变 或者删除
//    [NSData deleteDataFromKeyChainWithKey: touchID_keyChain_key];
}

- (IBAction)clickBtn:(id)sender {
    
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
            
            NSString *touchIDConfigure = [[NSUserDefaults standardUserDefaults] objectForKey: touchID_userDefault_key];
            if ([touchIDConfigure isEqualToString:@"Yes"] == NO) {
                NSLog(@"提示用户开启touch id 功能");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示用户开启touch id 功能" message:@"开启touch id功能, 让您爽的飞起!" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"以后" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"用户以后设置");
                }];
                
                UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"现在设置");
                    
                    [self configureTouchID];
                }];
                
                [alert addAction: laterAction];
                [alert addAction: setAction];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        });
    };
    [payAlertView show];
}

- (void)configureTouchID {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TouchIDManager shareInstance] configureTouchIDWithSuccessBlock:^{
            NSLog(@"配置成功");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.touchIDSwitch setOn:YES animated:YES];
            });
        } failedBlock:^{
            NSLog(@"配置失败");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.touchIDSwitch setOn:NO animated:YES];
            });
         
        }];
    });
}

- (IBAction)switchTouchID:(UISwitch *)touchIDSwitch {
    if (touchIDSwitch.isOn) {
        [self configureTouchID];
    } else {
        [[TouchIDManager shareInstance] deleteTouchIDConfigure];
    }
}

@end
