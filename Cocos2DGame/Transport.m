//
//  Transport.m
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Transport.h"
#define SPEED 60.0f

@implementation Transport

@synthesize delegate = _delegate;
@synthesize label = _label;
@synthesize toTag = _toTag;
@synthesize amount = _amount;
@synthesize team = _team;

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    return CGRectContainsPoint(self.textureRect, [self convertTouchToNodeSpace:touch]);
}

- (id)init 
{
    if (self = [super init]) {
        [self runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2.0f angle:360.0f]]];
    }
    
    return self;
}

- (void)onEnter
{
    [super onEnter];
}

- (void)onExit
{
    [super onExit];
}   

-(float)getTimeFromPoint:(CGPoint)from toPoint:(CGPoint)to speed:(float)speed {
    return sqrtf(powf(to.x-from.x, 2) + powf(to.y-from.y, 2))/speed;
}

-(void)moveToPosition:(CGPoint)point {
    self.label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", self.amount] fontName:@"Marker Felt" fontSize:12.0f];
    self.label.position = self.position;

    [self.parent addChild:self.label];
    
    float velocity = [self getTimeFromPoint:self.position toPoint:point speed:SPEED];
    
    [self.label runAction:[CCMoveTo actionWithDuration:velocity position:point]];
    [self runAction:[CCMoveTo actionWithDuration:velocity position:point]];
    [self schedule:@selector(moveFinished:) interval:velocity];
}

-(void)moveFinished:(ccTime)dt {
    [self.label removeFromParentAndCleanup:YES];
    [self removeFromParentAndCleanup:YES];
    [self.delegate transportFinished:self];
}

-(void)remove {
    [self.label removeFromParentAndCleanup:YES];
    [self removeFromParentAndCleanup:YES];
}

@end
