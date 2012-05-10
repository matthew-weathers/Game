//
//  AccountManager.m
//  Game
//
//  Created by Matthew Weathers on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountManager.h"

@implementation AccountManager

static AccountManager *sharedAccountManager = nil;

@synthesize facebook = _facebook;
@synthesize user = _user;
@synthesize delegate = _delegate;

#pragma mark Singleton Methods
+ (id)sharedAccountManager {
    @synchronized(self) {
        if(sharedAccountManager == nil)
            sharedAccountManager = [[super allocWithZone:NULL] init];
    }
    return sharedAccountManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedAccountManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
- (id)init {
    if (self = [super init]) {
        self.facebook = [[Facebook alloc] initWithAppId:@"454810187868611" andDelegate:self];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [_facebook release];
    [super dealloc];
}

-(BOOL)checkAuthorization {
    return [self.facebook isSessionValid];
    if (![self.facebook isSessionValid]) {
//        [self.facebook authorize:nil];
    } else {
//        [self.facebook requestWithGraphPath:@"me" andDelegate:self];
    }
}

-(void)authorize {
    [self.facebook authorize:nil];
}
// Pre iOS 4.2 support
-(BOOL)handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
-(BOOL)openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self getUserData]; 
}
-(void)getUserData {
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}
/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
    if ([self.delegate respondsToSelector:@selector(userSignedInWithSuccess:)]) {
        [self.delegate userSignedInWithSuccess:NO];
    }
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    self.facebook = [[Facebook alloc] initWithAppId:@"454810187868611" andDelegate:self];
    self.user = nil;
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    self.facebook = [[Facebook alloc] initWithAppId:@"454810187868611" andDelegate:self];
    self.user = nil;
}


- (void)request:(FBRequest *)request didLoad:(id)result {
    User *u = [[User alloc] init];
    self.user = u;
    [u release];
    self.user.userId = [result objectForKey:@"id"];
    self.user.userName = [result objectForKey:@"name"];
    self.user.userEmail = [result objectForKey:@"email"];
    
    if ([self.delegate respondsToSelector:@selector(userSignedInWithSuccess:)]) {
        [self.delegate userSignedInWithSuccess:YES];
    }
}

@end

@implementation User

@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize userEmail = _userEmail;

@end
