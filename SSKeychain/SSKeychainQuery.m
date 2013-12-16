//
//  SSKeychainQuery.m
//  SSKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSKeychainQuery.h"
#import "SSKeychain.h"

@implementation SSKeychainQuery

@synthesize account = _account;
@synthesize service = _service;
@synthesize label = _label;
@synthesize passwordData = _passwordData;
@synthesize keychainPassword = _keychainPassword;
@synthesize keychainPasswordNew = _keychainPasswordNew;
@synthesize keychain = _keychain;
@synthesize keychainPreferenceDomain = _keychainPreferenceDomain;

#if __IPHONE_3_0 && TARGET_OS_IPHONE
@synthesize accessGroup = _accessGroup;
#endif

#ifdef SSKEYCHAIN_SYNCHRONIZABLE_AVAILABLE
@synthesize synchronizationMode = _synchronizationMode;
#endif

#pragma mark - Public

- (BOOL)save:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

    [self deleteItem:nil];

    NSMutableDictionary *query = [self query:error];
    if(!query)return NO;

    [query setObject:self.passwordData forKey:(__bridge id)kSecValueData];
    if (self.label) {
        [query setObject:self.label forKey:(__bridge id)kSecAttrLabel];
    }
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef accessibilityType = [SSKeychain accessibilityType];
    if (accessibilityType) {
        [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
    }
#endif
    status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);

	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
	}

	return (status == errSecSuccess);
}


- (BOOL)deleteItem:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

    NSMutableDictionary *query = [self query:error];
    if(!query)return NO;

#if TARGET_OS_IPHONE
    status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
    CFTypeRef result = NULL;
    [query setObject:@YES forKey:(__bridge id)kSecReturnRef];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
#endif

    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
    }

    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
    NSMutableDictionary *query = [self query:error];
    if(!query)return NO;

    [query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];

	CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return nil;
	}

    return (__bridge_transfer NSArray *)result;
}


- (BOOL)fetch:(NSError *__autoreleasing *)error {
    OSStatus status = SSKeychainErrorBadArguments;
	if (!self.service || !self.account) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
		return NO;
	}

	CFTypeRef result = NULL;
	NSMutableDictionary *query = [self query:error];
    if(!query)return NO;

    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

	if (status != errSecSuccess && error != NULL) {
		*error = [[self class] errorWithCode:status];
		return NO;
	}

    self.passwordData = (__bridge_transfer NSData *)result;
    return YES;
}

- (BOOL)changeKeychainPassword:(NSError *__autoreleasing *)error{
    OSStatus status = SSKeychainErrorBadArguments;
    
    if (!self.keychainPasswordNew || !self.keychainPassword ||!self.keychain) {
		if (error) {
			*error = [[self class] errorWithCode:status];
		}
        return NO;
	}
    
    SecKeychainRef keychain = NULL;
    
	UInt32 currentPasswordLength = (self.keychainPassword) ? (int)[self.keychainPassword length] : 0;
	char *currentPassword = (self.keychainPassword) ? (char*)self.keychainPassword.UTF8String : NULL;

    UInt32 newPasswordLength = (self.keychainPasswordNew) ? (int)[self.keychainPasswordNew length] : 0;
    char *newPassword = (self.keychainPasswordNew) ? (char*)self.keychainPasswordNew.UTF8String : NULL;
    
    keychain = [self openKeychain:error];
    if (!keychain)
    {
        return NO;
    }
	
	(void)SecKeychainLock(keychain);

// SecKeychainChangePassword is from Apple's Private reseve <Security/SecKeychainPriv.h>
// so we'll silence the warning here.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-function-declaration"
    status = SecKeychainChangePassword(keychain, currentPasswordLength, currentPassword, newPasswordLength, newPassword);
#pragma clang diagnostic pop

    if (status != errSecSuccess)
	{
        if(error)*error = [[self class] errorWithCode:status];
        if (keychain)CFRelease(keychain);
        return NO;
    }
    
	if (keychain)CFRelease(keychain);
	return YES;
}

#pragma mark - Accessors

- (void)setPasswordObject:(id<NSCoding>)object {
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}


- (id<NSCoding>)passwordObject {
    if ([self.passwordData length]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}


- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if ([self.passwordData length]) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


#pragma mark - Private

- (NSMutableDictionary *)query:(NSError *__autoreleasing *)error{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    if (self.service) {
        [dictionary setObject:self.service forKey:(__bridge id)kSecAttrService];
    }

    if (self.account) {
        [dictionary setObject:self.account forKey:(__bridge id)kSecAttrAccount];
    }
    
#if !TARGET_OS_IPHONE
    if (self.keychain){
        SecKeychainRef keychain = [self openKeychain:error];
        if(keychain){
            [dictionary setObject:(__bridge id)(keychain) forKey:(__bridge id)kSecUseKeychain];
            CFRelease(keychain);
        }else{
            return NULL;
        }
        
}
        

#endif

#if __IPHONE_3_0 && TARGET_OS_IPHONE
#if !(TARGET_IPHONE_SIMULATOR)
    if (self.accessGroup) {
        [dictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
#endif
    
#ifdef SSKEYCHAIN_SYNCHRONIZABLE_AVAILABLE
  id value;
  
  switch (self.synchronizationMode) {
    case SSKeychainQuerySynchronizationModeNo: {
      value = @NO;
      break;
    }
    case SSKeychainQuerySynchronizationModeYes: {
      value = @YES;
      break;
    }
    case SSKeychainQuerySynchronizationModeAny: {
      value = (__bridge id)(kSecAttrSynchronizableAny);
      break;
    }
  }
  
  [dictionary setObject:value forKey:(__bridge id)(kSecAttrSynchronizable)];
#endif

    return dictionary;
}

#if !TARGET_OS_IPHONE
- (SecKeychainRef)openKeychain:(NSError *__autoreleasing *)error
{
    OSStatus status;
    SecKeychainRef keychain = NULL;
    
    // if unspecified we'll set to the user domain
    if(!self.keychainPreferenceDomain)
        self.keychainPreferenceDomain = kSSKeychainUserDomain;

    if ([self.keychain isEqualToString:kSSDefaultKeychain]) {
        status = SecKeychainCopyDomainDefault(self.keychainPreferenceDomain, &keychain);
        if (status != errSecSuccess)
		{
            if(error)*error = [[self class] errorWithCode:status];
			return NULL;
		}else{
            CFRetain(keychain);
            return keychain;
        }
    }
    else if (self.keychain.UTF8String && self.keychain.UTF8String[0] != '/')
	{
		CFArrayRef dynamic = NULL;
		status = SecKeychainCopyDomainSearchList(self.keychainPreferenceDomain, &dynamic);
		if (status != errSecSuccess)
		{
            if(error)*error = [[self class] errorWithCode:status];
			return NULL;
		}
        
		else
		{
			uint32_t i;
			uint32_t count = dynamic ? (int)CFArrayGetCount(dynamic) : 0;
            
			for (i = 0; i < count; ++i)
			{
				char pathName[MAXPATHLEN];
				UInt32 ioPathLength = sizeof(pathName);
				bzero(pathName, ioPathLength);
				keychain = (SecKeychainRef)CFArrayGetValueAtIndex(dynamic, i);
				status = SecKeychainGetPath(keychain, &ioPathLength, pathName);
                if (status)
				{
                    if(error)*error = [[self class] errorWithCode:status];
					return NULL;
				}
                
                NSString* keyChainFile = [[[NSString stringWithUTF8String:pathName] lastPathComponent] stringByDeletingPathExtension];
				if ([keyChainFile isEqualToString:self.keychain]){
                    CFRetain(keychain);
					CFRelease(dynamic);
					return keychain;
				}
			}
			if(dynamic)CFRelease(dynamic);
		}
	}

	status = SecKeychainOpen(self.keychain.UTF8String, &keychain);
	if (status != errSecSuccess)
	{
		if(error)*error = [[self class] errorWithCode:status];
	}
	return keychain;
}
#endif


+ (NSError *)errorWithCode:(OSStatus) code {
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case SSKeychainErrorBadArguments: message = NSLocalizedStringFromTable(@"SSKeychainErrorBadArguments", @"SSKeychain", nil); break;

#if TARGET_OS_IPHONE
        case errSecUnimplemented: {
			message = NSLocalizedStringFromTable(@"errSecUnimplemented", @"SSKeychain", nil);
			break;
		}
        case errSecParam: {
			message = NSLocalizedStringFromTable(@"errSecParam", @"SSKeychain", nil);
			break;
		}
        case errSecAllocate: {
			message = NSLocalizedStringFromTable(@"errSecAllocate", @"SSKeychain", nil);
			break;
		}
        case errSecNotAvailable: {
			message = NSLocalizedStringFromTable(@"errSecNotAvailable", @"SSKeychain", nil);
			break;
		}
        case errSecDuplicateItem: {
			message = NSLocalizedStringFromTable(@"errSecDuplicateItem", @"SSKeychain", nil);
			break;
		}
        case errSecItemNotFound: {
			message = NSLocalizedStringFromTable(@"errSecItemNotFound", @"SSKeychain", nil);
			break;
		}
        case errSecInteractionNotAllowed: {
			message = NSLocalizedStringFromTable(@"errSecInteractionNotAllowed", @"SSKeychain", nil);
			break;
		}
        case errSecDecode: {
			message = NSLocalizedStringFromTable(@"errSecDecode", @"SSKeychain", nil);
			break;
		}
        case errSecAuthFailed: {
			message = NSLocalizedStringFromTable(@"errSecAuthFailed", @"SSKeychain", nil);
			break;
		}
        default: {
			message = NSLocalizedStringFromTable(@"errSecDefault", @"SSKeychain", nil);
		}
#else
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#endif
    }

    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:kSSKeychainErrorDomain code:code userInfo:userInfo];
}

@end
