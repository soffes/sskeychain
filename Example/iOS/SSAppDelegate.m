//
//  SSAppDelegate.m
//  SSKeychain
//
//  Created by Sam Soffes on 9/7/13.
//  Copyright (c) 2013-2014 Sam Soffes. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSKeychain.h"

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
//	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
//	query.service = @"serviceName";
//	query.account = @"accountName";
//	query.password = @"securedPassword";
//	query.useNoAuthenticationUI = @YES;
//	query.accessControl = [SSKeychainAccessControl accessControlWithAccessibility:SSKeychainAccessibilityWhenUnlockedThisDeviceOnly flags:SSKeychainCreateFlagUserPresence];
//	
//	
//	NSError *error = nil;
//	BOOL result = [query save:&error];

	
	
	
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = @"serviceName";
	query.account = @"accountName";

	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		NSError *error = nil;
		BOOL result = [query fetch:&error];
		NSLog(@"Result: %@", result ? @"Success" : @"Failure");
		NSLog(@"Error: %@", error);
		NSLog(@"Data: %@", query.passwordData);
	});
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
