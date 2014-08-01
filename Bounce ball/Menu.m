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
	NSLog(@"Memory Warning");
}

-(void)spaceShipScene {
	Normal* hello = [[Normal alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	hello.delegate = self;
	lastPlayed = @"normal";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: hello];
}


-(void)normalStrategy {
	NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	hello.delegate = self;
	lastPlayed = @"normalStrategy";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: hello];
}

-(void)showDifferentView
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showScene {
	if ([lastPlayed isEqualToString:@"normalStrategy"]) {
		NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		hello.delegate = self;
		lastPlayed = @"normalStrategy";
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
		[spriteView presentScene: hello];
	}
	else if ([lastPlayed isEqualToString:@"normal"]) {
		Normal* hello = [[Normal alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		hello.delegate = self;
		lastPlayed = @"normal";
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
		[spriteView presentScene: hello];
	}
}

-(void)showShareTime {
	
	float highScore = [[NSUserDefaults standardUserDefaults] floatForKey:@"highScoreTime"];
	
	// Parse High Score Data
	int minutesTimerHigh;
	int secondsTimerHigh;
	
	minutesTimerHigh = (int)highScore/60;
	secondsTimerHigh = (int)highScore-(minutesTimerHigh * 60);
	
	NSArray *objectsToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"Look at my High Score of %01d:%02d for Inside The Box!", minutesTimerHigh, secondsTimerHigh]];
	
	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypeAirDrop];
	controller.excludedActivityTypes = excludedActivities;
	[self presentViewController:controller animated:YES completion:nil];
	
	[self showDifferentView];
}

-(void)showShareGoal {
	
	int highScore = [[NSUserDefaults standardUserDefaults] floatForKey:@"highScoreGoals"];
	
	NSArray *objectsToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"Look at my High Score of %i Goals for Inside The Box!", highScore]];
	
	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypeAirDrop];
	controller.excludedActivityTypes = excludedActivities;
	[self presentViewController:controller animated:YES completion:nil];
	
	[self showDifferentView];
}

@end
