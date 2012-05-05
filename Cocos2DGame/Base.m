//
//  Base.m
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Base.h"

@implementation Base

@synthesize selected = _selected;
@synthesize defaultColor = _defaultColor;
@synthesize delegate = _delegate;
@synthesize count = _count;
@synthesize capacity = _capacity;
@synthesize label =_label;
@synthesize team = _team;
@synthesize regenSpeed = _regenSpeed;
@synthesize baseSize = _baseSize;

- (BOOL)containsTouchLocation:(UITouch *)touch
{
    return CGRectContainsPoint(self.textureRect, [self convertTouchToNodeSpace:touch]);
}

- (id)init 
{
    if (self = [super init]) {
        self.defaultColor = self.color;
    }
    
    return self;
}

-(void)start {
    self.label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", self.count] fontName:@"Marker Felt" fontSize:24.0];
    self.label.position = self.position;
    [self.parent addChild:self.label];  
}

-(void)setTeam:(Team)team {
    _team = team;
    
    NSString *string = BASE_NAME_FOR_TEAM(team);
//    NSString *string = FILENAME_FOR_TEAM_SIZE(self.team, self.baseSize);
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:string];
    [self setTexture: tex];        

    if (team != neutralTeam) {
        [self unschedule:@selector(updateLabel:)];
      //  [self schedule:@selector(updateLabel:) interval:self.regenSpeed];
    }
}
- (void)onEnter
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}   

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self containsTouchLocation:touch]) {
        return YES;
    }
    return NO;
}
- (void) updateHighlight {
    self.selected ? [self setColor:ccGRAY] : [self setColor:self.defaultColor];
}

- (void) setSelection:(BOOL)selection {
    self.selected = selection;
    [self updateHighlight];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self containsTouchLocation:touch]) {
        [self.delegate baseSelected:self];
    }
}

- (void)updateLabel:(ccTime)dt {
    if (self.team == neutralTeam) return;
    
    if (self.count < self.capacity) {
        self.count += self.regenSpeed*dt;
        [self.label setColor:ccWHITE];
    } else if (self.count == self.capacity - 1) {
        self.count += dt;
        [self.label setColor:ccGRAY];
    } else {
        [self.label setColor:ccGRAY];
    }
    [self.label setString:[NSString stringWithFormat:@"%1.0f", self.count]];
}

@end
