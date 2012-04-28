//
//  Transport.m
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Transport.h"

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

-(void)moveToPosition:(CGPoint)point {
    self.label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", self.amount] fontName:@"Marker Felt" fontSize:24.0];
//    self.label.position = self.position;
    [self addChild:self.label];
    [self runAction:[CCMoveTo actionWithDuration:2.0 position:point]];
    [self schedule:@selector(moveFinished:) interval:2.0];
}

-(void)moveFinished:(ccTime)dt {
    [self removeFromParentAndCleanup:YES];
    [self.delegate transportFinished:self];
}

@end
