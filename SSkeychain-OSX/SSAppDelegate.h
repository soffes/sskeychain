//
//  SSAppDelegate.h
//  SSkeychain-OSX
//
//  Created by Eldon on 12/15/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSKeychain.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow    *window;
@property (weak)   IBOutlet NSTextField *keychain;
@property (weak)   IBOutlet NSSecureTextField *currentPassword;
@property (weak)   IBOutlet NSSecureTextField *password;

- (IBAction)changePassword:(id)sender;

@end
