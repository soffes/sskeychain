//
//  SSKeychainAccessControl.m
//  SSKeychain
//
//  Created by Liam Nichols on 01/09/2014.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "SSKeychainAccessControl.h"

@implementation SSKeychainAccessControl

+ (instancetype)accessControlWithAccessibility:(SSKeychainAccessibility)accesibility flags:(SSKeychainCreateFlags)flags
{
	SSKeychainAccessControl *accessControl = [self new];
	accessControl.accessibility = accesibility;
	accessControl.flags = flags;
	return accessControl;
}

@end

CFTypeRef getSecAttrAccessibility(SSKeychainAccessibility ssAttr)
{
	switch (ssAttr) {
		case SSKeychainAccessibilityAlways:
			return kSecAttrAccessibleAlways;
		
		case SSKeychainAccessibilityWhenUnlocked:
			return kSecAttrAccessibleWhenUnlocked;
			
		case SSKeychainAccessibilityAfterFirstUnlock:
			return kSecAttrAccessibleAfterFirstUnlock;
		
		case SSKeychainAccessibilityAlwaysThisDeviceOnly:
			return kSecAttrAccessibleAlwaysThisDeviceOnly;
			
		case SSKeychainAccessibilityWhenUnlockedThisDeviceOnly:
			return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
			
		case SSKeychainAccessibilityWhenPasscodeSetThisDeviceOnly:
			return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
			
		case SSKeychainAccessibilityAfterFisrtUnlockThisDeviceOnly:
			return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
			
		default:
			return NULL;
	}
}
