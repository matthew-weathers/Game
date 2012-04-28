//
//  Transport.h
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
@class Transport;

@protocol TransportDelegate <NSObject>
-(void)transportFinished:(Transport *)sprite;
@end

@interface Transport : CCSprite

@property (nonatomic, assign) id<TransportDelegate> delegate;
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, assign) int toTag;
@property (nonatomic, assign) int amount;
@property (nonatomic, assign) Team team;

-(void)moveToPosition:(CGPoint)point;

@end
