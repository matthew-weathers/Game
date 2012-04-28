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

@interface GameLayer : CCLayer <BaseDelegate, TransportDelegate>
{
}

@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSArray *bases;
@property (nonatomic, assign) CGPoint initialPoint;
@property (nonatomic, assign) CGPoint currentPoint;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
