//
//  Gameplay.h
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Gameplay : CCSprite

- (void) didLoadFromCCB;
- (void) touchBegan:(UITouch* )touch withEvent:(UIEvent *)event;
- (void) launchPenguin;

@end
