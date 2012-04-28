//
//  RectangleLayer.m
//  Game
//
//  Created by Matthew Weathers on 4/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RectangleLayer.h"


@implementation RectangleLayer

@synthesize initialPoint = _initialPoint;
@synthesize currentPoint = _currentPoint;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	RectangleLayer *layer = [RectangleLayer node];
	
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
        self.isTouchEnabled = YES;
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

-(void) ccDrawFilledRect:(CGPoint)v1 :(CGPoint)v2 {
	CGPoint poli[]={v1, CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(0.0f, 0.65f, 0.35f, 0.3f);
    glLineWidth(1.0f);
    
	glVertexPointer(2, GL_FLOAT, 0, poli);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

- (void)draw
{
    [super draw];
    [self ccDrawFilledRect:self.initialPoint :self.currentPoint];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    self.initialPoint = [[CCDirector sharedDirector] convertToGL:point];
    self.currentPoint = self.initialPoint;    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.currentPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.initialPoint = ccp(0.0f, 0.0f);
    self.currentPoint = self.initialPoint;
}

@end
