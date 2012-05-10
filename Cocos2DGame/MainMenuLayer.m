//
//  MainMenuLayer.m
//  Game
//
//  Created by Matthew Weathers on 4/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "LevelMenuLayer.h"
#import "SignInLayer.h"

@implementation MainMenuLayer

+(id) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    MainMenuLayer *layer = [MainMenuLayer node];

    // add layer as a child to scene
    [scene addChild: layer];

    // return the scene
    return scene;
}

// set up the Menus
-(void) setUpMenus
{
    
	// Create some menu items
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:34.0f];
    CCMenuItemLabel *singlePlayerItemLabel = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Single Player" dimensions:[@"Single Player" sizeWithFont:font] alignment:UITextAlignmentLeft fontName:font.fontName fontSize:font.pointSize] block:^(id sender) {
        CCTransitionFade *fade = [CCTransitionFade transitionWithDuration:1.0 scene:[LevelMenuLayer scene] withColor:ccWHITE];
        [[CCDirector sharedDirector] pushScene:fade];
    }];
    

    
    CCMenuItemLabel *multiplayerItemLabel = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Find Match" dimensions:[@"Find Match" sizeWithFont:font] alignment:UITextAlignmentRight fontName:font.fontName fontSize:font.pointSize] block:^(id sender) {
        
        BOOL isAuthorized = [[AccountManager sharedAccountManager] checkAuthorization];
        if (isAuthorized) {
            [[AccountManager sharedAccountManager] setDelegate:self];
            [[AccountManager sharedAccountManager] getUserData];
        } else {
            CCTransitionFade *fade = [CCTransitionFade transitionWithDuration:1.0 scene:[SignInLayer scene] withColor:ccWHITE];
            [[CCDirector sharedDirector] pushScene:fade];
        }
        
    }];
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:singlePlayerItemLabel, multiplayerItemLabel, nil];
    
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
	// Arrange the menu items vertically
	[myMenu alignItemsHorizontallyWithPadding:size.width - (singlePlayerItemLabel.boundingBox.size.width + multiplayerItemLabel.boundingBox.size.width) - 40.0f];

    [myMenu setPosition:ccp(size.width/2.0f, font.pointSize/2.0f + 20.0f)];
//    [myMenu setAnchorPoint:ccp(240.0f, 290.0f)];
	// add the menu to your scene
	[self addChild:myMenu];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
        [self setUpMenus];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)userSignedInWithSuccess:(BOOL)success {
    if (success) {
        CCTransitionFade *fade = [CCTransitionFade transitionWithDuration:1.0 scene:[LevelMenuLayer scene] withColor:ccWHITE];
        [[CCDirector sharedDirector] pushScene:fade];
    } else {
#warning WARNING
        //Notify the user...
    }
}

@end
