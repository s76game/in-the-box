//
//  NormalStrategic.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 6/30/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
#import "Menu.h"


int pos1x;
int pos1y;
int pos2x;
int pos2y;
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
NSTimer *countingTimer;
int countingAnimation;

int timesRevived;
int triggered;
int previousCost;

int goalSize;
int gemSize;

NSTimer *speedUpTimer;
NSTimer *timer;

// Menu View Controller Delegates
@protocol sceneDelegate <NSObject>
-(void)showDifferentView;
@end

@protocol resetSKScene <NSObject>
-(void)showScene;
@end

@protocol shareTimeDelegate <NSObject>
-(void)showShareTime;
@end

@protocol shareGoalDelegate <NSObject>
-(void)showShareGoal;
@end




static inline CGFloat skRandf() {
	return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
	return skRandf() * (high - low) + low;
}


@interface NormalStrategic : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate, NSObject> {
	
	// Post game stuff
	UIButton *menu;
	UIButton *replay;
	UIButton *rate;
	UIButton *gameCenter;
	UIButton *share;
	UILabel *currentScoreNumber;
	UILabel *bestScoreNumber;
	UILabel *bestScore;
	SystemSoundID breaking;
	UIImageView *postBackground;
	UIImageView *bigImage;
	
	// Pause menu stuff
	UIImageView *pauseBackground;
	UIImageView *bigPauseImage;
	UIButton *pauseContinue;
	UIButton *pauseRestart;
	UIButton *pauseExit;
	
	// Revive Menu stuff
	UIButton *reviveButton;
	UIButton *continueButton;
	UIImageView *reviveAngel;
	UILabel *gemCount;
	UIImageView *gem;
	
	// In game stuff
	SKShapeNode* border;
	SKShapeNode* lines;
	SKSpriteNode *line;
	SKSpriteNode *gemSprite;
	SKSpriteNode *goal;
	SKSpriteNode *detect;
	
	SKAction *remove;
	
	// UI Stuff
	SKSpriteNode *ball;
	UILabel *score;
	UIButton *start;
	CGFloat screenWidth;
	CGFloat screenHeight;
	UIButton *pause;
	UILabel *tapToStart;
	
	SKEmitterNode *explosion;
}

@end
