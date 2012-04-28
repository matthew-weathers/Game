//
//  Base.h
//  Cocos2DGame
//
//  Created by Matthew Weathers on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class Base;

@protocol BaseDelegate <NSObject>
-(void)baseSelected:(Base *)base;
@end

@interface Base : CCSprite <CCTargetedTouchDelegate>

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) ccColor3B defaultColor;
@property (nonatomic, assign) id<BaseDelegate> delegate;
@property (nonatomic, assign) int count;
@property (nonatomic, retain) CCLabelTTF *label;
@property (nonatomic, assign) int toTag;
@property (nonatomic, assign) Team team;
@property (nonatomic, assign) BaseSize baseSize;

@property (nonatomic, assign) float regenSpeed;


-(void)setSelection:(BOOL)selection;
-(void)updateLabel:(ccTime)dt;

@end
