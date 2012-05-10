//
//  LevelMenuLayer.m
//  Game
//
//  Created by Matthew Weathers on 5/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelMenuLayer.h"
#import "Level.h"
#import "Base.h"
#import "GameLayer.h"

@implementation LevelMenuLayer

+(id) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    LevelMenuLayer *layer = [LevelMenuLayer node];

    // add layer as a child to scene
    [scene addChild: layer];

    // return the scene
    return scene;
}

// set up the Menus
-(void) setUpMenus
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    NSArray *levelsArray = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"levels"];
    
    CCMenu *menu = [CCMenu menuWithItems:nil];
    
    for (NSDictionary *levelDictionary in levelsArray) {
        Level *level = [[Level alloc] init];
        level.levelName = [levelDictionary objectForKey:@"levelName"];
        level.basesDictionaries = [levelDictionary objectForKey:@"bases"];
        level.teamsPlaying = [levelDictionary objectForKey:@"teamsPlaying"];
        
        [menu addChild:[CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:level.levelName fontName:@"Helvetica Neue" fontSize:20.0f] block:^(id sender) {
            CCTransitionFade *fade = [CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer nodeWithGameLevel:level] withColor:ccWHITE];
            [[CCDirector sharedDirector] pushScene:fade];
        }]];
    }
    
    [menu addChild:[CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Back" fontName:@"Helvetica Neue" fontSize:20.0f] block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }]];
    
	// Arrange the menu items vertically
	[menu alignItemsVertically];
    
	// add the menu to your scene
	[self addChild:menu];
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

@end
