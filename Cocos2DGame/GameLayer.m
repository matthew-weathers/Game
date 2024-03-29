//
//  GameLayer.m
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GameLayer.h"
#import "Player.h"
#import "RectangleLayer.h"
#import "PauseLayer.h"
#import "NSArray+Shuffling.h"
#import "Level.h"

@implementation GameLayer

@synthesize bases = _bases;
@synthesize transports = _transports;
@synthesize player = _player;
@synthesize rectLayer = _rectLayer;
@synthesize teamsPlaying = _teamsPlaying;
@synthesize pt = _pt;
@synthesize perc = _perc;
@synthesize levelName = _levelName;

+(id)nodeWithGameLevel:(Level *)level {
    return  [[[self alloc] initWithGameLevel:level] autorelease];
}

-(id)initWithGameLevel:(Level *)level {
	if((self=[super init])) {
        Player *tempPlayer = [[Player alloc] init];
        self.player = tempPlayer;
        [tempPlayer release];
        
        self.player.team = blueTeam;
        
        RectangleLayer *rectLayer = [RectangleLayer node];
        [self addChild:rectLayer z:1];
        self.rectLayer = rectLayer;
        self.rectLayer.delegate = self;
        
        self.levelName = level.levelName;
        self.teamsPlaying = level.teamsPlaying;
        
        NSMutableArray *tempBases = [NSMutableArray arrayWithCapacity:level.basesDictionaries.count];
        for (NSDictionary *baseDictionary in level.basesDictionaries) {
            Base *base = [Base spriteWithFile:@"grayBase.png"];
            base.capacity = [[baseDictionary objectForKey:@"capacity"] intValue];
            base.tag = [[baseDictionary objectForKey:@"tag"] intValue];
            base.regenSpeed = [[baseDictionary objectForKey:@"regenSpeed"] floatValue];
            base.position = ccp([[baseDictionary objectForKey:@"positionX"] intValue], [[baseDictionary objectForKey:@"positionY"] intValue]);
            base.count = [[baseDictionary objectForKey:@"count"] intValue];
            base.team = [[baseDictionary objectForKey:@"team"] intValue];
            base.delegate = self;
            
            base.scale = (float)base.capacity/50.0f;
            [self addChild:base];
            [tempBases addObject:base];
        }
        
        self.bases = tempBases;
        self.transports = [NSMutableArray array];
        
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
    [self.bases shuffled];
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
    BOOL playerDead = YES;    

    for (Base *base in self.bases) {
        if (base.team == self.player.team) {
            playerDead = NO;
            break;
        }
    }
    
    if (playerDead) return YES;
    
    BOOL opponentsDead = YES;
    for (Base *base in self.bases) {
        if (base.team != neutralTeam && base.team != self.player.team) {
            opponentsDead = NO;
            break;
        }
    }
    
    return opponentsDead;
}

-(void)transportFinished:(Transport *)sprite {
    Base *b = (Base *)[self getChildByTag:sprite.toTag];
             
    float toCount = floorf(b.count);
            
    if (b.team == sprite.team) {
        b.count += sprite.amount;        
    } else {
        if (toCount == sprite.amount) {
            b.count = 0;
            b.team = neutralTeam;
        } else if (toCount < sprite.amount) {
            b.count = sprite.amount - b.count;
            b.team = sprite.team;
        } else {
            b.count -= sprite.amount;
        }
    }
    [b updateLabel:0];
    
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
