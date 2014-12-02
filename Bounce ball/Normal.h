//
//  Normal.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/12/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Menu.h"
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

int pos1x;
int pos1y;
int pos2x;
int pos2y;
int scoreiPad;
int startiPad;
int speediPad;
float gameTime;
int scoreNumber;
BOOL gameOver;
BOOL gameStarted;
int x;
int y;
BOOL dotDrawn;
float totalScore;
int countingAnimation;
BOOL night;
BOOL touchStarted;

int timesRevived;
int triggered;
int previousCost;

int gemSize;
BOOL gemSpawned;

BOOL gameEnded;

int minutesTimer;
int secondsTimer;

NSTimer *speedUpTimer;
NSTimer *timer;
NSTimer *countingTimer;

static const uint32_t ballCategory     =  0x1 << 0;
static const uint32_t lineCategory     =  0x1 << 1;
static const uint32_t goalCategory     =  0x1 << 2;
static const uint32_t pointGoalCategory = 0x1 << 3;
static const uint32_t edgeCategory     =  0x1 << 4;
static const uint32_t gemCategory     =  0x1 << 5;



@interface Normal : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate, NSObject> {
	
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
	UILabel *gemCost;
	UIImageView *gemCostImage;
	UIImageView *gemCountImage;

	// UI stuff
	SKShapeNode* border;
	SKShapeNode* lines;
	SKSpriteNode *line;
	SKSpriteNode *gemSprite;
	SKAction *remove;
	SKSpriteNode *ball;
	UILabel *score;
	CGFloat screenWidth;
	CGFloat screenHeight;
	UIButton *pause;
	UILabel *tapToStart;
	
	SKAction *wait;
	
	SKEmitterNode *tail;
	SKEmitterNode *explosion;
	
	CGPoint old;
}

@end
