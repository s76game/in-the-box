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
	// Store game has been played for this version
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	
	
	screenRect = [[UIScreen mainScreen] bounds];
	screenSize = screenRect.size;
	
	
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"normal"]) {
// Normal gameplay
			[self normal];
	}
	else {
// Strategic gameplay
			[self strategy];
	}
}

- (void)viewDidLoad {
	
	[self setNotificationListeners];
	[super viewDidLoad];
	sceneView = (SKView *) self.view;
	sceneView.showsFPS = [[NSUserDefaults standardUserDefaults] boolForKey:@"FPS"];
}

-(void)setNotificationListeners {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showDifferentView)
												 name:@"GameOverNotification"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showScene)
												 name:@"showScene"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showShareTime)
												 name:@"shareTime"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showShareGoal)
												 name:@"shareGoal"
											   object:nil];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	NSLog(@"Memory Warning!!!");
}

-(void)normal {
	Normal* scene = [[Normal alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	lastPlayed = @"normal";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: scene];
}


-(void)strategy {
	NSLog(@"Charlie");
	NormalStrategic* scene = [[NormalStrategic alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	lastPlayed = @"strategy";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: scene];
	NSLog(@"Delta");
}



-(void)showDifferentView
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showScene {
	NSLog(@"Bravo");
	if ([lastPlayed isEqualToString:@"strategy"]) {
		NSLog(@"Strategy");
		NormalStrategic* hello = [[NormalStrategic alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		lastPlayed = @"strategy";
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
		[spriteView presentScene: hello];
	}
	else if ([lastPlayed isEqualToString:@"normal"]) {
		Normal* hello = [[Normal alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
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
	
	NSArray *objectsToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"Check out my high score of %01d:%02d for Inside The Box! https://appsto.re/us/i1fu1.i", minutesTimerHigh, secondsTimerHigh]];
	
	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypeAirDrop];
	controller.excludedActivityTypes = excludedActivities;
	[self presentViewController:controller animated:YES completion:nil];
	
	[self showDifferentView];
}

-(void)showShareGoal {
	
	int highScore = [[NSUserDefaults standardUserDefaults] floatForKey:@"highScoreGoals"];
	
	NSArray *objectsToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"Check out my high score of %i Goals for Inside The Box! https://appsto.re/us/i1fu1.i", highScore]];
	
	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypeAirDrop];
	controller.excludedActivityTypes = excludedActivities;
	[self presentViewController:controller animated:YES completion:nil];
	
	[self showDifferentView];
}

@end
