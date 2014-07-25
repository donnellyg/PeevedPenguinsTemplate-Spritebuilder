//
//  Seal.m
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void) didLoadFromCCB {
    CCLOG(@"Seal Loaded");
    self.physicsBody.collisionType = @"seal";
    exit(0);
}

@end
