//
//  MainMenuLayer.h
//  Game
//
//  Created by Matthew Weathers on 4/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AccountManager.h"

@interface MainMenuLayer : CCLayer <AccountManagerDelegate>

+(CCScene *) scene;

@end
