//
//  GameLayer.m
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "Player.h"
#import "RectangleLayer.h"

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize bases = _bases;
@synthesize player = _player;
@synthesize rectLayer = _rectLayer;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    RectangleLayer *rectLayer = [RectangleLayer node];
    [scene addChild:rectLayer z:1];
    
    // 'layer' is an autorelease object.
    GameLayer *layer = [[[GameLayer alloc] initWithRectangleLayer:rectLayer] autorelease];
    [scene addChild:layer];
    
	// return the scene
	return scene;
}

-(id)initWithRectangleLayer:(RectangleLayer *)rectLayer {    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        self.player = [Player new];
        self.player.team = blueTeam;
        self.rectLayer = rectLayer;
        self.rectLayer.delegate = self;
        
        Base *base0 = [Base spriteWithFile: @"SmallGrayBase.png"];
        base0.baseSize = small;
        base0.capacity = 10;
        base0.tag = 0;
        base0.regenSpeed = 1.0f;
        base0.team = neutralTeam;
        base0.position = ccp( 50, 80 );
        base0.delegate = self;
        [self addChild:base0];
        
        Base *base1 = [Base spriteWithFile: @"MediumRedBase.png"];
        base1.baseSize = medium;
        base1.capacity = 15;
        base1.regenSpeed = 0.90f;
        base1.team = redTeam;
        base1.tag = 1;
        base1.position = ccp( 50, 200 );
        base1.delegate = self;
        [self addChild:base1];
        
        Base *base2 = [Base spriteWithFile:@"LargeBlueBase.png"];
        base2.baseSize = large;
        base2.capacity = 20;
        base2.regenSpeed = 0.80f;
        base2.team = blueTeam;
        base2.tag = 2;
        base2.position = ccp( 150, 100);
        base2.delegate = self;
        [self addChild:base2];
        
        self.bases = [NSArray arrayWithObjects:base0, base1, base2, nil];
        
        [self.bases makeObjectsPerformSelector:@selector(start)];
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

-(void)baseSelected:(Base *)base {
    BOOL shouldSelect = YES;
    
    for (Base *b in self.bases) {
        if (b.selected && ![b isEqual:base]) {
            int amount = b.count/2;
            b.count -= amount;
            [b updateLabel:0];
            
            [b setSelection:NO];
            [base setSelection:NO];
            
            // move half of time to cocosGuy
            shouldSelect = NO;
            
            Transport *t;
            if (b.team == redTeam) {
                t = [Transport spriteWithFile:@"RedArrow.png"];   
            } else if (b.team == blueTeam) {
                t = [Transport spriteWithFile:@"BlueArrow.png"];
            }
            t.team = b.team;
            t.toTag = base.tag;
            t.amount = amount;
            t.position = b.position;
            t.delegate = self;
            
            // Calculation
            CGPoint difference = ccpSub(b.position, base.position);
            CGFloat rotationRadians = ccpToAngle(difference);
            CGFloat rotationDegrees = -CC_RADIANS_TO_DEGREES(rotationRadians);
            rotationDegrees += 180.0f;
            CGFloat rotateByDegrees = rotationDegrees - b.rotation;
            
            CCRotateBy * turnBy = [CCRotateBy actionWithDuration:0.0f angle:rotateByDegrees];
            [t runAction:turnBy];
            
            [self addChild:t];
            
            [t moveToPosition:base.position];
        }
    }
    
    if (shouldSelect && (base.team == self.player.team)) {
        [base setSelection:!base.selected];
    }
}

-(BOOL)isGameOver {
    BOOL red = NO;
    BOOL blue = NO;
    
    for (Base *guy in self.bases) {
        if (guy.team == redTeam) red = YES;
        if (guy.team == blueTeam) blue = YES;
        if (red && blue) break;
    }
    
    if (red && blue) {
        return NO;
    } else {
        return YES;
    }
}

-(void)transportFinished:(Transport *)sprite {
    Base *to = [self.bases objectAtIndex:sprite.toTag];
    
    if (to.team == sprite.team) {
        to.count += sprite.amount;                
        [to updateLabel:0];        
    } else {
        if (to.count == sprite.amount) {
            to.count = 0;
            to.team = neutralTeam;
            [to updateLabel:0];
        } else if (to.count < sprite.amount) {
            to.count = sprite.amount - to.count;
            to.team = sprite.team;
            [to updateLabel:0];
        } else {
            to.count -= sprite.amount;
            [to updateLabel:0];
        }
    }
    
    if ([self isGameOver]) {
        [[CCDirector sharedDirector] pause];
    }
}

- (void)highlightEndedWithInitialPoint:(CGPoint)initPoint finalPoint:(CGPoint)finalPoint {
    CGFloat x, y, width, height;
    if (initPoint.x > finalPoint.x) {
        x = finalPoint.x;
        width = initPoint.x - finalPoint.x;
    } else {
        x = initPoint.x;
        width = finalPoint.x - initPoint.x;
    }
    
    if (initPoint.y > finalPoint.y) {
        y = finalPoint.y;
        height = initPoint.y - finalPoint.y;
    } else {
        y = initPoint.y;
        height = finalPoint.y - initPoint.y;
    }
    
    CGRect rect = CGRectMake(x, y, width, height);
    
    for (Base *b in self.bases) {
        if (CGRectIntersectsRect(rect, [b boundingBox]) && self.player.team == b.team) {
            [b setSelection:YES];
        } else {
            [b setSelection:NO];
        }
    }
}

@end
