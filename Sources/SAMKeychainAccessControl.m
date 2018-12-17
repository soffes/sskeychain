//
//  SAMKeychainAccessControl.m
//  SAMKeychain
//
//  Created by Liam Nichols on 01/09/2014.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "SAMKeychainAccessControl.h"

@implementation SAMKeychainAccessControl

+ (instancetype)accessControlWithAccessibility:(SAMKeychainAccessibility)accesibility flags:(SAMKeychainCreateFlags)flags {
	SAMKeychainAccessControl *accessControl = [self new];
	accessControl.accessibility = accesibility;
	accessControl.flags = flags;
	return accessControl;
}

@end

CFTypeRef getSecAttrAccessibility(SAMKeychainAccessibility ssAttr) {
	switch (ssAttr) {
		case SAMKeychainAccessibilityAlways: return kSecAttrAccessibleAlways;
		case SAMKeychainAccessibilityWhenUnlocked: return kSecAttrAccessibleWhenUnlocked;
		case SAMKeychainAccessibilityAfterFirstUnlock: return kSecAttrAccessibleAfterFirstUnlock;
		case SAMKeychainAccessibilityAlwaysThisDeviceOnly: return kSecAttrAccessibleAlwaysThisDeviceOnly;
		case SAMKeychainAccessibilityWhenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
		case SAMKeychainAccessibilityWhenPasscodeSetThisDeviceOnly: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
		case SAMKeychainAccessibilityAfterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
		default: return NULL;
	}
}
