//
//  SignInLayer.h
//  Game
//
//  Created by Matthew Weathers on 5/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AccountManager.h"

@interface SignInLayer : CCLayer <AccountManagerDelegate>

+(CCScene *) scene;

@end
