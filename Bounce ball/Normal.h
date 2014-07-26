//
//  Normal.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/12/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolBox/AudioToolbox.h>
#import "Menu.h"
#import "ViewController.h"

int pos1x;
int pos1y;
int pos2x;
int pos2y;
float gameTime;
int scoreNumber;
BOOL gameOver;
BOOL gameStarted;
int x;
int y;
BOOL dotDrawn;
float totalScore;

int minutesTimer;
int secondsTimer;

NSTimer *speedUpTimer;
NSTimer *timer;

static const uint32_t ballCategory     =  0x1 << 0;
static const uint32_t lineCategory     =  0x1 << 1;
static const uint32_t goalCategory     =  0x1 << 2;
static const uint32_t pointGoalCategory = 0x1 << 3;
static const uint32_t edgeCategory     =  0x1 << 4;



@interface Normal : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate, NSObject> {
	
	// Post game stuff
	UIButton *menu;
	UIButton *replay;
	UILabel *title;
	UILabel *currentScoreNumber;
	UILabel *bestScoreNumber;
	UILabel *currentScore;
	UILabel *bestScore;
	UIButton *gameCenter;
	UIButton *share;
	UIImageView *screenCrack;
	SystemSoundID breaking;
	UIView *postBackground;
	
	UIButton *start;
	
	SKShapeNode* border;
	SKShapeNode* lines;
	SKSpriteNode *line;
	SKAction *remove;
	SKSpriteNode *ball;
	UILabel *score;
	CGFloat screenWidth;
	CGFloat screenHeight;
}

@end
