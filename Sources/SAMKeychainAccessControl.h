//
//  SAMKeychainAccessControl.h
//  SAMKeychain
//
//  Created by Liam Nichols on 01/09/2014.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

@import Foundation;
@import Security;

/** kSecAttrAccessible */
typedef NS_ENUM(NSUInteger, SAMKeychainAccessibility) {
	/** kSecAttrAccessibleWhenUnlocked */
	SAMKeychainAccessibilityWhenUnlocked = 1,

	/** kSecAttrAccessibleAfterFirstUnlock */
	SAMKeychainAccessibilityAfterFirstUnlock,

	/** kSecAttrAccessibleAlways */
	SAMKeychainAccessibilityAlways,

	/** kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly */
	SAMKeychainAccessibilityWhenPasscodeSetThisDeviceOnly,

	/** kSecAttrAccessibleWhenUnlockedThisDeviceOnly */
	SAMKeychainAccessibilityWhenUnlockedThisDeviceOnly,

	/** kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly */
	SAMKeychainAccessibilityAfterFisrtUnlockThisDeviceOnly,

	/** kSecAttrAccessibleAlwaysThisDeviceOnly */
	SAMKeychainAccessibilityAlwaysThisDeviceOnly
};

/** SecAccessControlCreateFlags */
typedef NS_OPTIONS(NSUInteger, SAMKeychainCreateFlags) {
	/** kSecAccessControlUserPresence */
	SAMKeychainCreateFlagUserPresence = 1UL << 0
};

extern CFTypeRef getSecAttrAccessibility(SAMKeychainAccessibility ssAttr);

@interface SAMKeychainAccessControl : NSObject

+ (instancetype)accessControlWithAccessibility:(SAMKeychainAccessibility)accesibility flags:(SAMKeychainCreateFlags)flags;

@property (nonatomic, assign) SAMKeychainAccessibility accessibility;

@property (nonatomic, assign) SAMKeychainCreateFlags flags;

@end
