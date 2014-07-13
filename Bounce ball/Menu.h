//
//  Menu.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"
#import "Normal.h"
#import "NormalStrategic.h"

BOOL returnToMenu;
NSString *lastPlayed;

@interface Menu : ViewController <SKSceneDelegate> {
	CGRect screenRect;
	CGSize screenSize;
	SKView *spriteView;
	SKView *sceneView;
}

@end
