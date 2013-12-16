//
//  SSAppDelegate.m
//  SSkeychain-OSX
//
//  Created by Eldon on 12/15/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSAppDelegate.h"

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString* kcPath = [NSString stringWithFormat:@"%@/Library/Keychains/test.keychain",NSHomeDirectory()];
    _keychain.stringValue = kcPath;
    
}

-(void)changePassword:(id)sender{
    NSError *error;
    if([SSKeychain changePasswordForKeychain:_keychain.stringValue from:_currentPassword.stringValue to:_password.stringValue error:&error]){
        NSLog(@"Keychain Password Updated");
        [[NSAlert alertWithMessageText:@"Keychain Pasword Updated" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""]beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:NULL];
    }
    
    if(error){
        [[NSApplication sharedApplication]presentError:error modalForWindow:self.window delegate:nil didPresentSelector:nil contextInfo:nil];
        NSLog(@"%@",error.localizedDescription);
    }
}
@end
