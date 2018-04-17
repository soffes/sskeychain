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
	SAMKeychainAccessibilityAfterFirstUnlockThisDeviceOnly,

	/** kSecAttrAccessibleAlwaysThisDeviceOnly */
	SAMKeychainAccessibilityAlwaysThisDeviceOnly
};

/** SecAccessControlCreateFlags */
typedef NS_OPTIONS(NSUInteger, SAMKeychainCreateFlags) {
	/** kSecAccessControlUserPresence
	 User presence policy using biometry or Passcode. Biometry does not have to be available or enrolled. Item is still
	 accessible by Touch ID even if fingers are added or removed. Item is still accessible by Face ID if user is re-enrolled.
	 */
	SAMKeychainCreateFlagUserPresence 			= 1u << 0,

	/** kSecAccessControlBiometryAny
	 Constraint: Touch ID (any finger) or Face ID. Touch ID or Face ID must be available. With Touch ID
	 at least one finger must be enrolled. With Face ID user has to be enrolled. Item is still accessible by Touch ID even
	 if fingers are added or removed. Item is still accessible by Face ID if user is re-enrolled.
	 */
	SAMKeychainCreateFlagBiometryAny			CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 1,

	/** kSecAccessControlBiometryCurrentSet
	 Constraint: Touch ID from the set of currently enrolled fingers. Touch ID must be available and at least one finger must
	 be enrolled. When fingers are added or removed, the item is invalidated. When Face ID is re-enrolled this item is invalidated.
	 */
	SAMKeychainCreateFlagBiometryCurrentSet     CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 3,

	/** kSecAccessControlDevicePasscode
	 Constraint: Device passcode
	 */
	SAMKeychainCreateFlagDevicePasscode         CF_ENUM_AVAILABLE(10_11, 9_0) = 1u << 4,

	/** kSecAccessControlOr
	 Constraint logic operation: when using more than one constraint, at least one of them must be satisfied.
	 */
	SAMKeychainCreateFlagOr                     CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 14,

	/** kSecAccessControlAnd
	 Constraint logic operation: when using more than one constraint, all must be satisfied.
	 */
	SAMKeychainCreateFlagAnd                    CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 15,

	/** kSecAccessControlPrivateKeyUsage
	 Create access control for private key operations (i.e. sign operation)
	 */
	SAMKeychainCreateFlagPrivateKeyUsage        CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 30,

	/** kSecAccessControlApplicationPassword
	 Security: Application provided password for data encryption key generation. This is not a constraint but additional item
	 encryption mechanism.
	 */
	SAMKeychainCreateFlagApplicationPassword    CF_ENUM_AVAILABLE(10_12_1, 9_0) = 1u << 31,
} __OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0);

extern CFTypeRef getSecAttrAccessibility(SAMKeychainAccessibility ssAttr);

@interface SAMKeychainAccessControl : NSObject

+ (instancetype)accessControlWithAccessibility:(SAMKeychainAccessibility)accesibility flags:(SAMKeychainCreateFlags)flags;

@property (nonatomic, assign) SAMKeychainAccessibility accessibility;

@property (nonatomic, assign) SAMKeychainCreateFlags flags;

@end
