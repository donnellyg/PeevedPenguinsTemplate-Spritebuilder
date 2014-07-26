//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Gus Donnelly on 7/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Penguin.h"
#import "CCPhysics+ObjectiveChipmunk.h"

// Minimum Speed at which Next Try Granted
static const float MIN_SPEED = 5.f;

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    
    //What try is the player on currently?
    int _currentTurn;
    
    // Time the bird has been idle
    int _timeIdle;
    
    // Following action, controls screen panning
    CCAction *_followPenguin;
    
    //Waiting Penguins
    CCNode * _wp1;
    CCNode * _wp2;
    CCNode * _wp3;
    
    //NSString *levelNumber;
}

- (void) didLoadFromCCB{
    self.userInteractionEnabled = TRUE; //scene now accepts touches
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    //levelNumber = @"Level1";
    [_levelNode addChild:level];
    // ensure that nothing collides with the invisible spring nodes
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    // Show invisible physics objects:
    _physicsNode.debugDraw = FALSE;
    
    // Set collision delegate to self (Gameplay now implements CCPhysicsCollisionDelegate)
    _physicsNode.collisionDelegate = self;
    
    // Set current turn to 0
    _currentTurn = 0;
    
    _timeIdle = 0;
    
}

- (void) update:(CCTime)delta {
    
    if (!_currentPenguin.launched) return; // If the penguin hasn't been launched yet, don't go to nextAttempt.
    
    // if penguin slows to a critical point, allow next attempt
    if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED) { // ccpLength method takes the length of the velocity vector --> speed
        _timeIdle += (float)delta;
        if (_timeIdle > 2) {
            [self nextAttempt];
            return;
        }
        
    } else _timeIdle = 0;
    
    int xMin = _currentPenguin.boundingBox.origin.x;
    
    // If penguin leaves the left edge of the screen, allow next attempt
    if (xMin < self.boundingBox.origin.x) {
        [self nextAttempt];
        return;
    }
    
    int xMax = xMin + _currentPenguin.boundingBox.size.width;
    
    // If penguin leaves the right edge of the screen, allown next attempt
    
    if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
        [self nextAttempt];
        return;
    }
}

- (void) nextAttempt {
    _currentPenguin = nil;
    // Stop following the penguin
    [_contentNode stopAction:_followPenguin];
    // Now, move directly to the start of the screen (position 0,0)
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
    
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    //[self launchPenguin]; //OLD IMPLEMENTATION
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    //[_physicsNode addChild:_mouseJoint];
    if ((CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) && (_currentTurn < 3)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(20,125) restLength:0.f stiffness:3000.f damping:150.f];
        
        //Create a penguin and place it in the catapult
        _currentPenguin = (Penguin *)[CCBReader load:@"Penguin"]; //Cast to Penguin type necessary; not just a CCNode anymore.
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(20,125)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
        // Remove one of the penguins sitting on the side:
        _currentTurn ++;
        switch (_currentTurn) {
            case 1:
                [_wp1 removeFromParent];
                break;
            case 2:
                [_wp2 removeFromParent];
                break;
            case 3:
                [_wp3 removeFromParent];
                break;
        }
        
    }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
    
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [self releaseCatapult];
}

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    [self releaseCatapult];
}

- (void) releaseCatapult {
    if (_mouseJoint != nil) {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        [_penguinCatapultJoint invalidate];
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        
        // Follow the now flying penguin
        //[self launchPenguin];
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
        
        _currentPenguin.launched = TRUE;
    }
}

- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    //CCLOG(@"Something collided with a seal!");
    float energy = [pair totalKineticEnergy];
    
    if (energy > 5000.f) {
        //The following nonsense code ensures that the seal is only removed once, even if multiple things collide with it in the same frame.
        [[_physicsNode space] addPostStepBlock:^{
            [self removeSeal:nodeA];
        } key:nodeA];
    }
}

- (void) removeSeal:(CCNode *)seal {
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"SealExplosion"];
    explosion.autoRemoveOnFinish = TRUE; //automatically deletes particles once the animation is complete
    explosion.position = seal.position;
    [seal.parent addChild:explosion];
    
    [seal removeFromParent];
}


- (void) retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}



//////UNUSED METHODS/////////////////////////////////////////////////////////////////////////////
- (void) launchPenguin {
    _currentPenguin.position = ccpAdd(_catapultArm.position, ccp(16,130)); //manually position the penguin in the bowl of the catapult
    
    // launching the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [_currentPenguin.physicsBody applyForce:force];
    
    //Make the screen follow the penguin most recently launched.
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}
/////////////////////////////////////////////////////////////////////////////////////////////////

@end
