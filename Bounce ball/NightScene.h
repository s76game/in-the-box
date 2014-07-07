//
//  NightScene.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/28/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolBox/AudioToolbox.h>
#import "SpaceShipScene.h"

int pos1x;
int pos1y;
int pos2x;
int pos2y;
int scoreNumber;
BOOL gameOver;
int x;
int y;
BOOL dotDrawn;

//static const uint32_t ballCategory     =  0x1 << 0;
//static const uint32_t lineCategory     =  0x1 << 1;
//static const uint32_t edgeCategory     =  0x1 << 2;

@interface NightScene : SKScene <SKPhysicsContactDelegate> {
	
	UIButton *menu;
	UIButton *replay;
	UIButton *go;
	
	UIImageView *light;
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
