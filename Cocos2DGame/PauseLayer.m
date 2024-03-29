//
//  PauseLayer.m
//  Game
//
//  Created by Matthew Weathers on 4/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PauseLayer.h"


@implementation PauseLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PauseLayer *layer = [PauseLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
      	// Create some menu items
        CCMenuItemLabel *menuItem1 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Begin" fontName:@"Marker Felt" fontSize:44.0f] block:^(id sender) {
//            CCTransitionFade *fade = [CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] withColor:ccWHITE];
//            [[CCDirector sharedDirector] pushScene:fade];
        }];
        
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsVertically];
        
        // add the menu to your scene
        [self addChild:myMenu];
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

@end
