//
//  TouchIDManager.h
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *touchID_keyChain_key = @"touch_ID_manger_account_alter_view_key_chain";
static NSString *touchID_userDefault_key = @"touch_ID_manger_account_alter_view_user_default";
static NSString *password_keyChain_Service = @"password_keyChain_Service";
static NSString *password_keyChain_account = @"password_keyChain_account";

typedef void (^ConfigureSuccessBlock)();

@interface TouchIDManager : NSObject
+ (instancetype)shareInstance;
- (BOOL)checkDeviceSupportTouchID;

- (void)configureTouchIDWithSuccessBlock: (void (^)())successBlock failedBlock: (void (^)())failedBlock;

- (void)verifyTouchIDWithSuccessBlock: (void (^)(NSString *password))successBlock failedBlock: (void (^)(NSString *errorMessage))failedBlock userFallbackBlock: (void (^)())userFallbackBlock;

- (void)deleteTouchIDConfigure;

@end
