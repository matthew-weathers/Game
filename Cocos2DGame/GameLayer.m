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
#import "NSMutableArray+Shuffling.h"

// HelloWorldLayer implementation
@implementation GameLayer


@synthesize bases = _bases;
@synthesize transports = _transports;
@synthesize player = _player;
@synthesize rectLayer = _rectLayer;
@synthesize teamsPlaying = _teamsPlaying;
@synthesize pt = _pt;
@synthesize perc = _perc;

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
        
        self.bases = [NSMutableArray array];
        self.transports = [NSMutableArray array];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
        NSArray *levelsArray = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"levels"];
        
        NSDictionary *level = [levelsArray objectAtIndex:0];
        
        int tag = 0;
        for (NSDictionary *baseDictionary in [level objectForKey:@"bases"]) {
            Base *base = [Base spriteWithFile:@"grayBase.png"];
            base.team = [[baseDictionary objectForKey:@"team"] intValue];
            base.capacity = [[baseDictionary objectForKey:@"capacity"] intValue];
            base.tag = tag;
            base.regenSpeed = [[baseDictionary objectForKey:@"regenSpeed"] floatValue];
            base.position = ccp([[baseDictionary objectForKey:@"positionX"] intValue], [[baseDictionary objectForKey:@"positionY"] intValue]);
            base.delegate = self;
            
            [self addChild:base];
            [self.bases addObject:base];
            tag++;
        }        
        
        // Declare the teams that are playing
        self.teamsPlaying = [level objectForKey:@"teamsPlaying"];
        
        [self.bases makeObjectsPerformSelector:@selector(start)];
        
        [self schedule:@selector(nextFrame:)];
        [self schedule:@selector(makeDecision:) interval:5.0f];
    }
    return self;
}

-(void)attackFrom:(Base *)attacker :(Base *)victim {
    int amount = attacker.count/2;
    attacker.count -= amount;
    [attacker updateLabel:0];
    
    NSString *filename = TRANSPORT_NAME_FOR_TEAM(attacker.team);
    Transport *t = [Transport spriteWithFile:filename];
    t.team = attacker.team;
    t.toTag = victim.tag;
    t.amount = amount;
    t.position = attacker.position;
    t.delegate = self;
    [self.transports addObject:t];
    
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
    if (self.perc >= 100) self.perc = 0;
    
    self.perc += 1;
    [self.pt setPercentage:self.perc];
    
    for (Base *b in self.bases) {
        [b updateLabel:dt];
    }
}

-(void)makeDecision:(ccTime)dt forTeam:(Team)team {
    [self.bases shuffle];
    NSMutableArray *teamBases = [NSMutableArray array];
    NSMutableArray *otherBases = [NSMutableArray array];
    NSMutableArray *neutralBases = [NSMutableArray array];
    
    // Sort into team arrays
    for (Base *b in self.bases) {
        if (b.team == team) {
            [teamBases addObject:b];
        } else if (b.team == neutralTeam) {
            [neutralBases addObject:b];
        } else {
            [neutralBases addObject:b];
        }
    }
    
    for (NSArray *bases in teamBases) {
        // If any of the red bases have enough troops to capture a blue territory, do it.
        for (Base *aiBase in otherBases) {
            for (Base *base in otherBases) {
                if ((base.count >= base.capacity) && ((int)aiBase.count/2 > (int)base.count)) {
                    [self attackFrom:aiBase :base];
                } else if (aiBase.count/2 > base.count + sqrtf(powf(base.position.x-aiBase.position.x, 2) + powf(base.position.y-aiBase.position.y, 2))/60.0) {
                    [self attackFrom:aiBase :base];
                }
            }
        }
        
        // If any of the bases are at capacity, move the troops elsewhere to allow for more generation to happen
        for (Base *aiBase in teamBases) {
            if (aiBase.count >= aiBase.capacity) {
                for (Base *allyBase in teamBases) {
                    if (allyBase.count + aiBase.count/2 < allyBase.capacity) {
                        [self attackFrom:aiBase :allyBase];
                    }
                }
            }
        }
        
        // If any of the bases are at capacity, move the troops to a gray base that can be overtaken
        for (Base *aiBase in teamBases) {
            if (aiBase.count >= aiBase.capacity) {
                for (Base *neutral in neutralBases) {
                    if (aiBase.count/2 >= neutral.count) {
                        [self attackFrom:aiBase :neutral];
                    }
                }
            }
        }
    }

}

-(void)makeDecision:(ccTime)dt {
    [self makeDecision:dt forTeam:redTeam];
    [self makeDecision:dt forTeam:greenTeam];
    [self makeDecision:dt forTeam:yellowTeam];
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
            [b setSelection:NO];
            [base setSelection:NO];
            
            // move half of time to cocosGuy
            shouldSelect = NO;
            
            [self attackFrom:b :base];
        }
    }
    
    if (shouldSelect && (base.team == self.player.team)) {
        [base setSelection:!base.selected];
    }
}

-(BOOL)isGameOver {
    Team teamFound = neutralTeam;
    
    BOOL playerDead = YES;    

    for (Base *base in self.bases) {
        if (base.team == self.player.team) playerDead = NO;
    }
    if (playerDead) return playerDead;
    
    for (Base *base in self.bases) {
        if ([self.teamsPlaying containsObject:[NSNumber numberWithInt:base.team]]) {
            if (teamFound == neutralTeam) teamFound = base.team;
            
            if (teamFound != base.team) return NO;
        }
    }
    
    return YES;
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
        
        [self.transports makeObjectsPerformSelector:@selector(remove)];
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
