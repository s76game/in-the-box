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

@protocol sceneDelegate <NSObject>
-(void)showDifferentView;
@end

@protocol resetSKScene <NSObject>
-(void)showScene;
@end

@interface Normal : SKScene <SKPhysicsContactDelegate, NSObject> {
	
	UIButton *menu;
	UIButton *replay;
	UILabel *hits;
	UIButton *start;
	
	SKShapeNode* border;
	SKShapeNode* lines;
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
