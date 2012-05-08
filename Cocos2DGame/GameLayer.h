//
//  GameLayer.h
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "Base.h"
#import "Transport.h"
@class Player;
#import "RectangleLayer.h"
@class Level;

@interface GameLayer : CCLayer <BaseDelegate, TransportDelegate, RectangleLayerDelegate>

@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSArray *bases;
@property (nonatomic, retain) NSMutableArray *transports;
@property (nonatomic, retain) RectangleLayer *rectLayer;
@property (nonatomic, retain) NSArray *teamsPlaying;
@property (nonatomic, retain) CCProgressTimer *pt;
@property (nonatomic, assign) float perc;
@property (nonatomic, copy) NSString *levelName;

// returns a CCScene that contains the HelloWorldLayer as the only child
-(id)initWithRectangleLayer:(RectangleLayer *)rectLayer;
+(CCScene *) scene;
+(id)nodeWithGameLevel:(Level *)level;
-(id)initWithGameLevel:(Level *)level;

@end
