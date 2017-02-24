//
//  NSData+keyChain.h
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (keyChain)

- (BOOL)storeDataToKeyChainWithKey: (NSString *)key;
+ (NSData *)getDataFromKeyChainWithKey: (NSString *)key;
+ (BOOL)deleteDataFromKeyChainWithKey: (NSString *)key;

@end
