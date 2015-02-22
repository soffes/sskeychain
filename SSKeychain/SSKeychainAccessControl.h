//
//  SSKeychainAccessControl.h
//  SSKeychain
//
//  Created by Liam Nichols on 01/09/2014.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

@import Foundation;

/** kSecAttrAccessible */
typedef NS_ENUM(NSUInteger, SSKeychainAccessibility) {
	/** kSecAttrAccessibleWhenUnlocked */
	SSKeychainAccessibilityWhenUnlocked = 1,
	
	/** kSecAttrAccessibleAfterFirstUnlock */
	SSKeychainAccessibilityAfterFirstUnlock,
	
	/** kSecAttrAccessibleAlways */
	SSKeychainAccessibilityAlways,
	
	/** kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly */
	SSKeychainAccessibilityWhenPasscodeSetThisDeviceOnly,
	
	/** kSecAttrAccessibleWhenUnlockedThisDeviceOnly */
	SSKeychainAccessibilityWhenUnlockedThisDeviceOnly,
	
	/** kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly */
	SSKeychainAccessibilityAfterFisrtUnlockThisDeviceOnly,
	
	/** kSecAttrAccessibleAlwaysThisDeviceOnly */
	SSKeychainAccessibilityAlwaysThisDeviceOnly
};

/** SecAccessControlCreateFlags */
typedef NS_OPTIONS(NSUInteger, SSKeychainCreateFlags) {
	/** kSecAccessControlUserPresence */
	SSKeychainCreateFlagUserPresence = 1UL << 0
};

extern CFTypeRef getSecAttrAccessibility(SSKeychainAccessibility ssAttr);

@interface SSKeychainAccessControl : NSObject

+ (instancetype)accessControlWithAccessibility:(SSKeychainAccessibility)accesibility flags:(SSKeychainCreateFlags)flags;

@property (nonatomic, assign) SSKeychainAccessibility accessibility;

@property (nonatomic, assign) SSKeychainCreateFlags flags;

@end
