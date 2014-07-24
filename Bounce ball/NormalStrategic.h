//
//  NormalStrategic.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 6/30/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolBox/AudioToolbox.h>
#import "Menu.h"

int pos1x;
int pos1y;
int pos2x;
int pos2y;
float gameTime;
NSString *goalTimeString;
int scoreNumber;
BOOL gameOver;
BOOL gameStarted;
int x;
int y;
BOOL dotDrawn;
int goalsHit;
float totalScore;
int kMinDistanceFromBall;

int goalSize;

NSTimer *speedUpTimer;
NSTimer *timer;


@protocol sceneDelegate <NSObject>
-(void)showDifferentView;
@end

@protocol resetSKScene <NSObject>
-(void)showScene;
@end

static inline CGFloat skRandf() {
	return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
	return skRandf() * (high - low) + low;
}


@interface NormalStrategic : SKScene <SKPhysicsContactDelegate, NSObject> {
	
	UIButton *menu;
	UIButton *replay;
	UILabel *hits;
	UIButton *start;
	
	SKShapeNode* border;
	SKShapeNode* lines;
	UIImageView *screenCrack;
	SystemSoundID breaking;
	SKSpriteNode *line;
	
	SKSpriteNode *goal;
	SKSpriteNode *detect;
	
	SKAction *remove;
	SKSpriteNode *ball;
	UILabel *score;
	CGFloat screenWidth;
	CGFloat screenHeight;
}

@end
