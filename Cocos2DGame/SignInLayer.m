//
//  SignInLayer.m
//  Game
//
//  Created by Matthew Weathers on 5/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInLayer.h"

@implementation SignInLayer

+(id) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    SignInLayer *layer = [SignInLayer node];
    
    // add layer as a child to scene
    [scene addChild:layer];
    
    // return the scene
    return scene;
}

// set up the Menus
-(void) setUpMenus
{
    
	// Create some menu items
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:30.0f];
    CCMenuItemLabel *menuItem1 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Sign In With Facebook" dimensions:[@"Sign In With Facebook" sizeWithFont:font] alignment:UITextAlignmentLeft fontName:font.fontName fontSize:font.pointSize] block:^(id sender) {
        [[AccountManager sharedAccountManager] authorize];
    }];
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
    [myMenu alignItemsHorizontally];
    
	[self addChild:myMenu];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
        [[AccountManager sharedAccountManager] setDelegate:self];
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
    NSLog(@"%@", [[[AccountManager sharedAccountManager] user] userId]);
}

@end
