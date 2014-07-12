//
//  ViewController.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/15/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end
@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_ball.layer.cornerRadius = 37.5;
	
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"]) {
		
		// Set toBePlayed to normal
		[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"toBePlayed"];
		
		// Turn of sound effects
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];
		
		
		// Set the "hasPerformedFirstLaunch" key so this block won't execute again
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// Tutorial code goes here
		
		
	}
	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)start:(id)sender {
	
	
	ViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"gamePlay"];
	
	CATransition* transition = [CATransition animation];
	
	transition.duration = 0.3;
	transition.type = kCATransitionReveal;
	transition.subtype = kCATransitionFromTop;
	transition.duration = 1.0;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:menu animated:NO];


}



-(void)viewWillAppear:(BOOL)animated {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		// Night UI code
		[_mode setBackgroundImage:[UIImage imageNamed:@"nightmodebutton.png"] forState:UIControlStateNormal];
		[_play setBackgroundImage:[UIImage imageNamed:@"nightplaybutton.png"] forState:UIControlStateNormal];
		[_settings setBackgroundImage:[UIImage imageNamed:@"nightsettings"] forState:UIControlStateNormal];
		[_frame setImage:[UIImage imageNamed:@"nighttitle.png"]];
		[_background setImage:[UIImage imageNamed:@"nightbackground.png"]];
	}
	else {
		// Normal UI code
		[_mode setBackgroundImage:[UIImage imageNamed:@"normalmodebutton.png"] forState:UIControlStateNormal];
		[_play setBackgroundImage:[UIImage imageNamed:@"normalplaybutton.png"] forState:UIControlStateNormal];
		[_settings setBackgroundImage:[UIImage imageNamed:@"normalsettings"] forState:UIControlStateNormal];
		[_frame setImage:[UIImage imageNamed:@"normaltitle.png"]];
		[_background setImage:[UIImage imageNamed:@"normalbackground.png"]];
	}
	
#pragma mark Rate my app code
	
	//Check if game has been played this version
	if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@CHECK",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
			// Show UIALert View
			
			UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Rate my app" message:@"If you enjoy using Inside the Box would you mind taking a moment to rate it? It won't take more than a minute. Thanks for the support!"
														delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate it now",@"No, thanks", nil];
			[alert show];
		}
	}
	
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSLog(@"Remind me later");
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	}
	else if (buttonIndex == 1){
		NSLog(@"Rate it now");
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		// Open app App Store URL
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
	}
	else {
		NSLog(@"No, thanks");
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	}
}


#pragma mark Game Center
//- (IBAction)gameCenter:(id)sender {
//	[self showGameCenter];
//}
//
//- (void) showGameCenter
//{
//	GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
//	if (gameCenterController != nil)
//	{
//		gameCenterController.gameCenterDelegate = self;
//		[self presentViewController: gameCenterController animated: YES completion:nil];
//	}
//}
//
//- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
//{
//	[self dismissViewControllerAnimated:YES completion:nil];
//}
//
//-(void)authenticateLocalPlayer
//{
//	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
//	__weak GKLocalPlayer *blockLocalPlayer = localPlayer;
//	
//	//Block is called each time GameKit automatically authenticates
//	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
//	{
//		[self setLastError:error];
//		if (viewController)
//		{
//			self.authenticationViewController = viewController;
//			[self disableGameCenter];
//		}
//		else if (blockLocalPlayer.isAuthenticated)
//		{
//			[self authenticatedPlayer:blockLocalPlayer];
//		}
//		else
//		{
//			[self disableGameCenter];
//		}
//	};
//}
//
//-(void)authenticatedPlayer:(GKLocalPlayer*)localPlayer
//{
//	self.isAuthenticated = YES;
//	[[NSNotificationCenter defaultCenter]postNotificationName:AUTHENTICATED_NOTIFICATION object:nil];
//	[[GKLocalPlayer localPlayer]registerListener:self];
//	NSLog(@"Local player:%@ authenticated into game center",localPlayer.playerID);
//}
//
//-(void)disableGameCenter
//{
//	//A notification so that every observer responds appropriately to disable game center features
//	self.isAuthenticated = NO;
//	[[NSNotificationCenter defaultCenter]postNotificationName:UNAUTHENTICATED_NOTIFICATION object:nil];
//	NSLog(@"Disabled game center");
//}
//
//- (void) loadPlayerData: (NSArray *) identifiers
//{
//	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
//		if (error != nil)
//		{
//			// Handle the error.
//		}
//		if (players != nil)
//		{
//			// Process the array of GKPlayer objects.
//		}
//	}];
//}

@end
