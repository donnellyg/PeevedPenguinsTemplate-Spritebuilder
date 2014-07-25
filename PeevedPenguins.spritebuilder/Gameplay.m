//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
}

- (void) didLoadFromCCB{
    self.userInteractionEnabled = TRUE; //scene now accepts touches
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    [self launchPenguin];
}

- (void) launchPenguin {
    CCNode *penguin = [CCBReader load:@"Penguin"];
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,130)); //manually position the penguin in the bowl of the catapult
    
    [_physicsNode addChild:penguin];
    
    // launching the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
}


@end
