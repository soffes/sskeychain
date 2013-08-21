//
//  SSKeychainTests.m
//  SSKeychainTests
//
//  Created by Sam Soffes on 10/3/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SSKeychain.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword = @"SSToolkitTestPassword";
static NSString *kSSToolkitTestsLabel = @"SSToolkitLabel";

@interface SSKeychainTests : SenTestCase

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name;

@end

@implementation SSKeychainTests

- (void)testAll {
    SSKeychainQuery *query = nil;
    NSError *error = nil;
    NSArray *accounts = nil;
    
    // create a new keychain item
    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    query.label = kSSToolkitTestsLabel;
    STAssertTrue([query saveItem:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query fetchSingleItem:&error], @"Unable to fetch keychain item: %@", error);
    STAssertEqualObjects(query.password, kSSToolkitTestsPassword, @"Passwords were not equal");
    
    // set password to a dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"number",
                                @"4 8 15 16 23 42", @"string",
                                nil];
    query.passwordObject = dictionary;
    STAssertTrue([query saveItem:&error], @"Unable to save item: %@", error);
    
    // check password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query fetchSingleItem:&error], @"Unable to fetch keychain item: %@", error);
    STAssertEqualObjects(query.passwordObject, dictionary, @"Passwords were not equal");
    
    // check all accounts
    query = [[SSKeychainQuery alloc] init];
    accounts = [query fetchItems:&error];
    STAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // check accounts for service
    query.service = kSSToolkitTestsServiceName;
    accounts = [query fetchItems:&error];
    STAssertNotNil(accounts, @"Unable to fetch accounts: %@", error);
    STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // delete password
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertTrue([query deleteItems:&error], @"Unable to delete password: %@", error);
    
    // check if saving with missing informations is handled correctly
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    query.account = kSSToolkitTestsAccountName;
    STAssertFalse([query saveItem:&error], @"Function should return NO as not all needed information is provided: %@", error);
    
    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.account = kSSToolkitTestsAccountName;
    STAssertFalse([query saveItem:&error], @"Function should return NO as not all needed information is provided: %@", error);

    query = [[SSKeychainQuery alloc] init];
    query.password = kSSToolkitTestsPassword;
    query.service = kSSToolkitTestsServiceName;
    STAssertFalse([query saveItem:&error], @"Function save should return NO if not all needed information is provided: %@", error);
    
    // check if deletion with missing information is handled correctly
    query = [[SSKeychainQuery alloc] init];
    query.account = kSSToolkitTestsAccountName;
    STAssertFalse([query deleteItems:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);

    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    STAssertFalse([query deleteItems:&error], @"Function deleteItem should return NO if not all needed information is provided: %@", error);
    
    // check if fetch handels missing information correctly
    query = [[SSKeychainQuery alloc] init];
    query.account = kSSToolkitTestsAccountName;
    STAssertFalse([query fetchSingleItem:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
    
    query = [[SSKeychainQuery alloc] init];
    query.service = kSSToolkitTestsServiceName;
    STAssertFalse([query fetchSingleItem:&error], @"Function fetch should return NO if not all needed information is provided: %@", error);
}

- (void)testSSKeychain {
    NSError *error = nil;
    
    // Test Class Methods of SSKeychain
    
    // create a new keychain item
    STAssertTrue([SSKeychain setPassword:kSSToolkitTestsPassword forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName error:&error], @"Unable to save item: %@", error);
    
    // check password
    STAssertEqualObjects([SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], kSSToolkitTestsPassword, @"Passwords were not equal");
    
    // check all accounts
    STAssertTrue([self _accounts:[SSKeychain allAccounts] containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    // check account
    STAssertTrue([self _accounts:[SSKeychain accountsForService:kSSToolkitTestsServiceName] containsAccountWithName:kSSToolkitTestsAccountName], @"Matching account was not returned");
    
    // delete password
    STAssertTrue([SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName error:&error], @"Unable to delete password: %@", error);
    
    // set password and delete it without error function
    STAssertTrue([SSKeychain setPassword:kSSToolkitTestsPassword forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], @"Unable to save item");
    STAssertTrue([SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName], @"Unable to delete password");
    
#if __IPHONE_4_0 && TARGET_OS_IPHONE
    [SSKeychain setAccessibilityType:kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
    STAssertTrue([SSKeychain accessibilityType] == kSecAttrAccessibleWhenUnlockedThisDeviceOnly, @"Unable to verify accessibilityType");
#endif
}

- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

@end
