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
#import "PauseLayer.h"

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
        
        Base *base0 = [Base spriteWithFile: @"SmallRedBase.png"];
        base0.baseSize = small;
        base0.capacity = 30;
        base0.tag = 0;
        base0.regenSpeed = 0.9f;
        base0.team = redTeam;
        base0.position = ccp( 50, 80 );
        base0.delegate = self;
        [self addChild:base0];
        
        Base *base1 = [Base spriteWithFile: @"MediumRedBase.png"];
        base1.baseSize = medium;
        base1.capacity = 10;
        base1.regenSpeed = 1.0f;
        base1.team = redTeam;
        base1.tag = 1;
        base1.position = ccp( 50, 200 );
        base1.delegate = self;
        [self addChild:base1];
        
        Base *base2 = [Base spriteWithFile:@"LargeBlueBase.png"];
        base2.baseSize = large;
        base2.capacity = 5;
        base2.regenSpeed = 1.1f;
        base2.team = blueTeam;
        base2.tag = 2;
        base2.position = ccp( 150, 100);
        base2.delegate = self;
        [self addChild:base2];
        
        Base *base3 = [Base spriteWithFile:@"MediumBlueBase.png"];
        base3.baseSize = medium;
        base3.capacity = 5;
        base3.regenSpeed = 1.0f;
        base3.team = blueTeam;
        base3.tag = 3;
        base3.position = ccp( 250, 100);
        base3.delegate = self;
        [self addChild:base3];
        
        Base *base4 = [Base spriteWithFile:@"SmallBlueBase.png"];
        base4.baseSize = small;
        base4.capacity = 5;
        base4.regenSpeed = 0.90f;
        base4.team = blueTeam;
        base4.tag = 4;
        base4.position = ccp( 350, 100);
        base4.delegate = self;
        [self addChild:base4];
        
        // Sort the initial array based on island size (helpful for AI)
        self.bases = [NSArray arrayWithObjects:base2, base1, base3, base0, base4, nil];
        [self.bases makeObjectsPerformSelector:@selector(start)];
        
        [self schedule:@selector(nextFrame:)];
    }
    return self;
}

-(void)attackFrom:(Base *)attacker :(Base *)victim {
    int amount = attacker.count/2;
    attacker.count -= amount;
    [attacker updateLabel:0];
    
    Transport *t;
    t = [Transport spriteWithFile:@"RedArrow.png"];   
    t.team = redTeam;
    t.toTag = victim.tag;
    t.amount = amount;
    t.position = attacker.position;
    t.delegate = self;
    
    // Calculation
    CGPoint difference = ccpSub(attacker.position, victim.position);
    CGFloat rotationRadians = ccpToAngle(difference);
    CGFloat rotationDegrees = -CC_RADIANS_TO_DEGREES(rotationRadians);
    rotationDegrees += 180.0f;
    CGFloat rotateByDegrees = rotationDegrees - attacker.rotation;
                            
    CCRotateBy * turnBy = [CCRotateBy actionWithDuration:0.0f angle:rotateByDegrees];
    [t runAction:turnBy];
                    
    [self addChild:t];
                            
    [t moveToPosition:victim.position];
}

-(void)nextFrame:(ccTime)dt {
    
    NSMutableArray *redBases = [NSMutableArray array];
    NSMutableArray *blueBases = [NSMutableArray array];
    NSMutableArray *neutralBases = [NSMutableArray array];
    
    // Sort into team arrays
    for (Base *b in self.bases) {
        switch (b.team) {
            case redTeam:
                [redBases addObject:b];
                break;
            case blueTeam:
                [blueBases addObject:b];
                break;
            case neutralTeam:
                [neutralBases addObject:b];
                break;
        }
    }
    
    // If any of the red bases have enough troops to capture a blue territory, do it.
    for (Base *red in redBases) {
        for (Base *blue in blueBases) {
            if ((blue.count >= blue.capacity) && (red.count/2 > blue.count)) {
                [self attackFrom:red :blue];
            } else if (red.count/2 >= blue.count + 1.5) {
                [self attackFrom:red :blue];
            }
        }
    }
    
    // If any of the bases are at capacity, move the troops elsewhere to allow for more generation to happen
    BOOL shouldBreak = NO;
    for (Base *red in redBases) {
        if (red.count >= red.capacity) {
            for (Base *otherRed in redBases) {
                if (otherRed.count + red.count/2 < otherRed.capacity) {
                    [self attackFrom:red :otherRed];
                    shouldBreak = YES;
                    break;
                }
            }
            if (shouldBreak) break;
        }
    }

    for (Base *b in self.bases) {
        [b updateLabel:dt];
    }
//    [self.bases makeObjectsPerformSelector:@selector(updateLabel:)];
//    [self.bases makeObjectsPerformSelector:@selector(updateLabel:) withObject:[NSNumber numberWithFloat:dt]];
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
    Base *to;
    for (Base *b in self.bases) {
        if (b.tag == sprite.toTag) {
            to = b;
            break;
        }
    }
    
    float toCount = floorf(to.count);
    
    if (to.team == sprite.team) {
        to.count += sprite.amount;                
        [to updateLabel:0];        
    } else {
        if (toCount == sprite.amount) {
            to.count = 0;
            [to updateLabel:0];
            to.team = neutralTeam;
        } else if (toCount < sprite.amount) {
            to.count = sprite.amount - to.count;
            to.team = sprite.team;
            [to updateLabel:0];
        } else {
            to.count -= sprite.amount;
            [to updateLabel:0];
        }
    }
    
    if ([self isGameOver]) {
        PauseLayer *pl = [PauseLayer node];
        [self addChild:pl];
        
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
