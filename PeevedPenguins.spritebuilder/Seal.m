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
    self.physicsBody.collisionType = @"seal";
}

@end
