# SSKeychain

SSKeychain is a simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system Keychain on Mac OS X and iOS.

## Adding to Your Project

Simply add the following to your Podfile if you're using CocoaPods:

``` ruby
pod 'SSKeychain'
```

or Cartfile if you're using Carthage:

```
github "soffes/SSKeychain"
```

To add as a dynamic framework for iOS 8 and above:

1. Drag and drop `SSKeychain.xcodeproj` into your project.
2. Add the appropriate `SSKeychain.framework` for your platform as a **Target Dependency** in the _Build Phases_ tab.
3. Add `SSKeychain.framework` to **Link Binary With Libraries** in the _Build Phases_ tab.
4. `#import <SSKeychain/SSKeychain.h>` wherever necessary.

To add to your project the old-fashioned way:

1. Add `Security.framework` to your target.
2. Drag and drop the `SSKeychain` folder into your project.
3. `#import "SSKeychain.h"` wherever necessary.

SSKeychain requires ARC.

Note: Currently SSKeychain does not support Mac OS 10.6.

## Working with the Keychain

SSKeychain has the following class methods for working with the system keychain:

```objective-c
+ (NSArray *)allAccounts;
+ (NSArray *)accountsForService:(NSString *)serviceName;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
```

Easy as that. (See [SSKeychain.h](https://github.com/soffes/sskeychain/blob/master/SSKeychain/SSKeychain.h) and [SSKeychainQuery.h](https://github.com/soffes/sskeychain/blob/master/SSKeychain/SSKeychainQuery.h) for all of the methods.)

## Documentation

### Use prepared documentation

Read the [online documentation](http://cocoadocs.org/docsets/SSKeychain).

## Debugging

If your saving to the keychain fails, use the NSError object to handle it. You can invoke `[error code]` to get the numeric error code. A few values are defined in SSKeychain.h, and the rest in SecBase.h.

```objective-c
NSError *error = nil;
SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
query.service = @"MyService";
query.account = @"soffes";
[query fetch:&error];

if ([error code] == errSecItemNotFound) {
    NSLog(@"Password not found");
} else if (error != nil) {
	NSLog(@"Some other error occurred: %@", [error localizedDescription]);
}
```

Obviously, you should do something more sophisticated. You can just call `[error localizedDescription]` if all you need is the error message.

## Disclaimer

Working with the keychain is pretty sucky. You should really check for errors and failures. This library doesn't make it any more stable, it just wraps up all of the annoying C APIs.


## Thanks

This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors. SSKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).

A huge thanks to [Caleb Davenport](https://github.com/calebd) for leading the way on version 1.0 of SSKeychain.
