//
//  Menu.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"
#import "SpaceShipScene.h"
#import "NightScene.h"
#import "NormalStrategic.h"
#import "NightStrategic.h"

BOOL returnToMenu;

@interface Menu : ViewController <SKSceneDelegate> {
	CGRect screenRect;
	CGSize screenSize;
	SKView *spriteView;
	SKView *sceneView;
}

@end
