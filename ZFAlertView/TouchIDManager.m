//
//  TouchIDManager.m
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "TouchIDManager.h"
#import <UIKit/UIKit.h>
#import <LocalAuthentication/LAContext.h>
#import "ZFPayAlertView.h"
#import "NSData+keyChain.h"
#import "SSKeychain.h"

@interface TouchIDManager()
@property (nonatomic, strong, readwrite) LAContext *context;
@end

@implementation TouchIDManager

+ (instancetype)shareInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (LAContext *)context {
    if (!_context) {
        _context = [[LAContext alloc] init];
    }
    return _context;
}

- (BOOL)checkDeviceSupportTouchID {
    //判断当前设备是否支持TouchID
    NSError *error;
    BOOL evaluateResult = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 && evaluateResult && !error) {
        return YES;
    }else{
        return NO;
    }
}

- (void)configureTouchIDWithSuccessBlock:(void (^)())successBlock failedBlock:(void (^)())failedBlock {
    
    self.context.localizedFallbackTitle = @"";
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedStringFromTable(@"Please_verify_current_fingerprint", @"melotic", nil) reply:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    ZFPayAlertView *payAlertView = [[ZFPayAlertView alloc] init];
                    payAlertView.titleLabel.text = @"请输入支付密码";
                    payAlertView.subTitleLabel.text = @"验证Touch ID";
                    payAlertView.completeHander = ^(NSString *password) {
                      // send password to server
                        NSLog(@"password: %@", password);
                        
                        //保存当前的指纹数据库状态
                        NSData *domainState = self.context.evaluatedPolicyDomainState;
                        NSLog(@"init fingerprint database domain state: %@", domainState);
                        BOOL saveResult = [domainState storeDataToKeyChainWithKey: touchID_keyChain_key];
                        if (saveResult) {
                            NSLog(@"设置touch ID 成功");
                            [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey: touchID_userDefault_key];
                            [SSKeychain setPassword: password forService: password_keyChain_Service account: password_keyChain_account];
                            
                            if (successBlock) {
                                successBlock();
                            }
                        }
                    };
                    [payAlertView show];
                });
            });
        }else{
            if (failedBlock) {
                failedBlock();
            }
        }
    }];
    
}

- (void)verifyTouchIDWithSuccessBlock: (void (^)(NSString *password))successBlock failedBlock: (void (^)(NSString *errorMessage))failedBlock userFallbackBlock: (void (^)())userFallbackBlock
{
    BOOL success = [self checkDeviceSupportTouchID];
    __block NSString *message;
    
    if (success) {
        
        self.context.localizedFallbackTitle = NSLocalizedStringFromTable(@"手动输入密码", @"melotic", nil);
        
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedStringFromTable(@"Please_verify_current_fingerprint", @"melotic", nil) reply:^(BOOL success, NSError * _Nullable error) {
            
            if (success) {
                //获取上一次指纹数据库的状态
                NSData *lastDomainState = [NSData getDataFromKeyChainWithKey: touchID_keyChain_key];
                if ([self.context.evaluatedPolicyDomainState isEqual: lastDomainState]) {
                    //从钥匙串中获取 password
                    NSString *password = [SSKeychain passwordForService:password_keyChain_Service account:password_keyChain_account];
                    if (successBlock) {
                        successBlock(password);
                    }
                }else{
                    //指纹数据库状态有改变, 锁定指纹支付功能, 用户需要重新开启指纹支付功能
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Touch ID" message:@"由于您的指纹数据改变了, 可能是您增加或者删除某个手指, 为了安全我们将暂时关闭该功能, 您可以重新开启" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                        
                        [self deleteTouchIDConfigure];
                        
                        if (failedBlock) {
                            failedBlock(@"fuck you!!!!!");
                        }
                    });
                }
            }else{
                NSLog(@"error========%@", error);
                message = [NSString stringWithFormat:@"evaluatePolicy: %@", error.localizedDescription];
                
                // 尝试次数过多, 自动关闭 touch id 功能
                if (error.code == kLAErrorUserFallback) {
                    NSLog(@"enter pin code");
                    //跳转到输入密码的界面
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (userFallbackBlock) {
                            userFallbackBlock();
                        }
                    });
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Touch ID" message:@"由于您的指纹验证失败次数过多, 我们将暂时关闭该功能, 您可以重新开启" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    });
                    [self deleteTouchIDConfigure];
                }
            }
            NSLog(@"message: %@", message);
        }];
        
    }else{
        message = [NSString stringWithFormat:@"Touch ID is unavailable"];
        NSLog(@"message: %@", message);
    }
}


- (void)deleteTouchIDConfigure {
    [NSData deleteDataFromKeyChainWithKey: touchID_keyChain_key];
    [[NSUserDefaults standardUserDefaults] setObject:@"No" forKey: touchID_userDefault_key];
    [SSKeychain deletePasswordForService: password_keyChain_Service account: password_keyChain_account];
}

@end
