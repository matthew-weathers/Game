//
//  AccountManager.h
//  Game
//
//  Created by Matthew Weathers on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
@class User;

@protocol AccountManagerDelegate <NSObject>
-(void)userSignedInWithSuccess:(BOOL)success;
@end

@interface AccountManager : NSObject <FBSessionDelegate, FBRequestDelegate>

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) User *user;
@property (nonatomic, assign) id<AccountManagerDelegate> delegate;

+(id)sharedAccountManager;
-(void)authorize;
-(BOOL)checkAuthorization;
-(void)getUserData;

//// Pre iOS 4.2 support
//-(void)handleOpenURL:(NSURL *)url;
//
//// For iOS 4.2+ support
//-(void)openURL:(NSURL *)url;

@end

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userEmail;

@end