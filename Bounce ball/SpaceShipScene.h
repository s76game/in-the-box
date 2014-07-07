//
//  SpaceShipScene.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/15/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolBox/AudioToolbox.h>
#import "Menu.h"

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

static const uint32_t ballCategory     =  0x1 << 0;
static const uint32_t lineCategory     =  0x1 << 1;
static const uint32_t edgeCategory     =  0x1 << 2;

@interface SpaceShipScene : SKScene <SKPhysicsContactDelegate, NSObject> {
	
	UIButton *menu;
	UIButton *replay;
	UILabel *hits;
	UIButton *start;
	
	UIImageView *screenCrack;
	SystemSoundID breaking;
	SKSpriteNode *line;
	SKAction *remove;
	SKSpriteNode *ball;
	UILabel *score;
	CGFloat screenWidth;
	CGFloat screenHeight;
}

@end
