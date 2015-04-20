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


- (void)viewWillAppear:(BOOL)animated {
	// Save that game has been played
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	
	// Determine screen size
	screenRect = [[UIScreen mainScreen] bounds];
	screenSize = screenRect.size;
	
	// Load right game mode
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"normal"]) {
		[self normal];
	}
	else {
		[self strategy];
	}
}

- (void)viewDidLoad {
	[self setNotificationListeners];
	[super viewDidLoad];
	
	// Set Debugging view here
	sceneView = (SKView *) self.view;
	
	// Check settings to show FPS or naw
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

-(void)normal {
	// Load TimeBased Game
	TimeBased* scene = [[TimeBased alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	lastPlayed = @"normal";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: scene];
}


-(void)strategy {
	// Load GoalBased Game
	GoalBased* scene = [[GoalBased alloc] initWithSize:screenSize];
	spriteView = (SKView *) self.view;
	lastPlayed = @"strategy";
	[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
	[spriteView presentScene: scene];
}



-(void)showDifferentView {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showScene {
	if ([lastPlayed isEqualToString:@"strategy"]) {
		// Load GoalBased game
		GoalBased* hello = [[GoalBased alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		lastPlayed = @"strategy";
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
		[spriteView presentScene: hello];
	}
	else if ([lastPlayed isEqualToString:@"normal"]) {
		// Load TimeBased game
		TimeBased* hello = [[TimeBased alloc] initWithSize:screenSize];
		spriteView = (SKView *) self.view;
		lastPlayed = @"normal";
		[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gamesPlayed"]+1 forKey:@"gamesPlayed"];
		[spriteView presentScene: hello];
	}
}

#pragma mark - Sharing

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
