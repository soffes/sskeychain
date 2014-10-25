//
//  SSKeychain.m
//  SSKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "SSKeychain.h"

NSString *const kSSKeychainErrorDomain = @"com.samsoffes.sskeychain";
NSString *const kSSKeychainAccountKey = @"acct";
NSString *const kSSKeychainCreatedAtKey = @"cdat";
NSString *const kSSKeychainClassKey = @"labl";
NSString *const kSSKeychainDescriptionKey = @"desc";
NSString *const kSSKeychainLabelKey = @"labl";
NSString *const kSSKeychainLastModifiedKey = @"mdat";
NSString *const kSSKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
	static CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

@implementation SSKeychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup {
	return [self passwordForService:serviceName account:account accessGroup:accessGroup error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	query.accessGroup = accessGroup;
	[query fetch:error];
	return query.password;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup {
	return [self deletePasswordForService:serviceName account:account accessGroup:accessGroup error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	query.accessGroup = accessGroup;
	return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup {
	return [self setPassword:password forService:serviceName account:account accessGroup:accessGroup error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account accessGroup:(NSString *)accessGroup error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	query.password = password;
	query.accessGroup = accessGroup;
	return [query save:error];
}


+ (NSArray *)allAccounts {
	return [self accountsForService:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	return [query fetchAll:nil];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
	return SSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
	CFRetain(accessibilityType);
	if (SSKeychainAccessibilityType) {
		CFRelease(SSKeychainAccessibilityType);
	}
	SSKeychainAccessibilityType = accessibilityType;
}
#endif

@end
