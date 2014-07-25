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
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
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
    _physicsNode.debugDraw = TRUE;
    
    // Set collision delegate to self (Gameplay now implements CCPhysicsCollisionDelegate)
    _physicsNode.collisionDelegate = self;
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    //[self launchPenguin]; //OLD IMPLEMENTATION
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    //[_physicsNode addChild:_mouseJoint];
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(20,125) restLength:0.f stiffness:3000.f damping:150.f];
        
        //Create a penguin and place it in the catapult
        _currentPenguin = [CCBReader load:@"Penguin"];
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(20,125)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
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
        CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
        
    }
}

- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    CCLOG(@"Something collided with a seal!");
    NSLog(@"Something collided with a seal! (NSLOG");
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
