//
//  NSArray+Shuffling.m
//  Game
//
//  Created by Matthew Weathers on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Shuffling.h"

@implementation NSArray (Shuffling)

-(NSArray *)shuffled
{
    // create temporary autoreleased mutable array
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id anObject in self)
    {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos];
    }
    
    return [NSArray arrayWithArray:tmpArray];  // non-mutable autoreleased copy
}


@end
