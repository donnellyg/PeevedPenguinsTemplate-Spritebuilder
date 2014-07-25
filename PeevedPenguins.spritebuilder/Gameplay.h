//
//  Gameplay.h
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

- (void) didLoadFromCCB;
- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event; //user dragged finger off screen
- (void) releaseCatapult;
- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB;
- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair wildcard:(CCNode *)nodeA wildcard:(CCNode *)nodeB;




- (void) launchPenguin;

@end
