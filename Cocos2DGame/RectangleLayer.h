//
//  RectangleLayer.h
//  Game
//
//  Created by Matthew Weathers on 4/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol RectangleLayerDelegate
-(void)highlightEndedWithInitialPoint:(CGPoint)initPoint finalPoint:(CGPoint)finalPoint;
@end

@interface RectangleLayer : CCLayer 

@property (nonatomic, assign) CGPoint initialPoint;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) id<RectangleLayerDelegate> delegate;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(CCScene *) scene;
@end
