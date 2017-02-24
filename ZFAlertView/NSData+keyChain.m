//
//  NSData+keyChain.m
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "NSData+keyChain.h"

@implementation NSData (keyChain)

- (BOOL)storeDataToKeyChainWithKey:(NSString *)key {
    
    [NSData deleteDataFromKeyChainWithKey: key];
    
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                 (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked,
                                 (__bridge id)kSecValueData: self,
                                 (__bridge id)kSecAttrAccount: key
                                 };
    OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
    
    if (status != errSecSuccess) {
        NSString *message = [NSString stringWithFormat:@"SecItemAdd status: %@", [self keychainErrorToString:status]];
        NSLog(@"keychain add Item message: %@", message);
    } else {
        NSLog(@"添加成功");
    }
    return status == errSecSuccess ? YES : NO;
}

+ (BOOL)deleteDataFromKeyChainWithKey:(NSString *)key {
    // setup keychain query properties
    NSDictionary *deletableItemsQuery = @{
                                          (__bridge id)kSecAttrAccount:        key,
                                          (__bridge id)kSecClass:              (__bridge id)kSecClassGenericPassword,
                                          (__bridge id)kSecMatchLimit:         (__bridge id)kSecMatchLimitAll,
                                          (__bridge id)kSecReturnAttributes:   (id)kCFBooleanTrue
                                          };
    
    CFArrayRef itemList = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)deletableItemsQuery, (CFTypeRef *)&itemList);
    // each item in the array is a dictionary
    NSArray *itemListArray = (__bridge NSArray *)itemList;
    
    NSLog(@"------");
    NSLog(@"----- %@", itemListArray);
    
    // 不在key chain 中
    if (itemListArray.count == 0) {
        NSLog(@"不在key chain 中");
        return YES;
    } else {
        NSMutableDictionary *deleteQuery =  [[itemListArray firstObject] mutableCopy];
        [deleteQuery setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        // do delete
        status = SecItemDelete((__bridge CFDictionaryRef)deleteQuery);

        if (status == errSecSuccess || status == errSecItemNotFound) {
            NSLog(@"删除成功");
            return YES;
        } else {
            NSString *message = [NSString stringWithFormat:@"SecItem delete status: %@", [self keychainErrorToString: status]];
            NSLog(@"keychain delete Item message: %@", message);
            return NO;
        }
    }
}

+ (NSData *)getDataFromKeyChainWithKey:(NSString *)key {
    NSDictionary *readQuery = @{
                                (__bridge id)kSecAttrAccount: key,
                                (__bridge id)kSecReturnData: (id)kCFBooleanTrue,
                                (__bridge id)kSecClass:      (__bridge id)kSecClassGenericPassword
                                };
    
    CFDataRef dataRef = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)readQuery, (CFTypeRef *)&dataRef);
    if(osStatus == noErr) {
        NSData *data = (__bridge NSData *)dataRef;
        return data;
    }
    else {
        return nil;
    }
}

- (NSString *)keychainErrorToString:(OSStatus)error {
    return [NSData keychainErrorToString: error];
}

+ (NSString *)keychainErrorToString:(OSStatus)error {
    NSString *message = [NSString stringWithFormat:@"%ld", (long)error];
    
    switch (error) {
        case errSecSuccess:
            message = @"success";
            break;
            
        case errSecDuplicateItem:
            message = @"error item already exists";
            break;
            
        case errSecItemNotFound :
            message = @"error item not found";
            break;
            
        case errSecAuthFailed:
            message = @"error item authentication failed";
            break;
            
        default:
            break;
    }
    
    return message;
}
@end
