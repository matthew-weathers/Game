//
//  Level.h
//  Game
//
//  Created by Matthew Weathers on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject

@property (nonatomic, copy) NSString *levelName;
@property (nonatomic, retain) NSArray *basesDictionaries;
@property (nonatomic, retain) NSArray *teamsPlaying;

@end
