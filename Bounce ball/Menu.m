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
//		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
//			[self nightScene];
//		}
//		else {
			[self spaceShipScene];
//		}
	}
	else {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[self nightStrategy];
		}
		else {
			[self normalStrategy];
		}
	}
}

- (void)viewDidLoad {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDifferentView) name:@"showDifferenView" object:nil];
	
	[super viewDidLoad];
	sceneView = (SKView *) self.view;
	sceneView.showsPhysics = YES;
	NSLog(@"Menu loaded");
}


-(void)viewDidAppear:(BOOL)animated {
	if (returnToMenu) {
		[self showDifferentView];
		returnToMenu = NO;
	}
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)spaceShipScene {
	SpaceShipScene* hello = [[SpaceShipScene alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
//	scene.delegate = self;
	[spriteView presentScene: hello];
}

-(void)nightScene {
	NightScene* hello = [[NightScene alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	[spriteView presentScene: hello];
}

-(void)normalStrategy {
	NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	[spriteView presentScene: hello];
}

-(void)nightStrategy {
	NightStrategic* hello = [[NightStrategic alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	[spriteView presentScene: hello];
}



-(void)showDifferentView
{
	[self dismissViewControllerAnimated:YES completion:nil];
	NSLog(@"Alpha");
}


@end
