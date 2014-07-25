//
//  Penguin.m
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Penguin.h"

@implementation Penguin

- (void) didLoadFromCCB {
    CCLOG(@"Penguin Loaded");
    self.physicsBody.collisionType = @"penguin";
    exit(0);
}

@end
