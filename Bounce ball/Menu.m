//
//  Menu.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "Menu.h"

@interface Menu ()

@end

@implementation Menu

- (void)viewWillAppear:(BOOL)animated
{
	// State game has been played for this version
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	
	
	screenRect = [[UIScreen mainScreen] bounds];
	screenSize = screenRect.size;
	
	
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"normal"]) {
// Normal gameplay
			[self spaceShipScene];
	}
	else {
// Strategic gameplay
			[self normalStrategy];
	}
}

- (void)viewDidLoad {
	

	[super viewDidLoad];
	sceneView = (SKView *) self.view;
	sceneView.showsPhysics = YES;
}




- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)spaceShipScene {
	SpaceShipScene* hello = [[SpaceShipScene alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	hello.delegate = self;
	lastPlayed = @"normal";
	[spriteView presentScene: hello];
}


-(void)normalStrategy {
	NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	hello.delegate = self;
	lastPlayed = @"normalStrategy";
	[spriteView presentScene: hello];
}

-(void)showDifferentView
{
	[self.navigationController popViewControllerAnimated:YES];
	NSLog(@"Dismiss to previous view controller");
}

-(void)showScene {
	if ([lastPlayed isEqualToString:@"normalStrategy"]) {
		NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		hello.delegate = self;
		lastPlayed = @"normalStrategy";
		[spriteView presentScene: hello];
	}
	else if ([lastPlayed isEqualToString:@"normal"]) {
		SpaceShipScene* hello = [[SpaceShipScene alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		hello.delegate = self;
		lastPlayed = @"normal";
		[spriteView presentScene: hello];
	}
}


@end
