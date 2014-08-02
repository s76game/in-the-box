//
//  ViewController.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/15/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"
@class GameCenterManager;

@interface ViewController ()

@property (nonatomic) BOOL gameCenterEnabled;
@property(assign, nonatomic) BOOL showsCompletionBanner;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;
-(void)authenticateLocalPlayer;

@end
@implementation ViewController



#pragma mark iAd Code

-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[banner setAlpha:1];
	[UIView commitAnimations];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adsLoaded"];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	[banner setAlpha:0];
	[UIView commitAnimations];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adsLoaded"];
}


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
	
	_gameCenterEnabled = NO;
	_showsCompletionBanner = YES;
	
	
	[self authenticateLocalPlayer];
	[self retrieveAchievmentMetadata];
	
	// Debugging Purposes Only
	_resetGameCenterOutlet.hidden = YES;
	
	_banner.delegate = self;
	
	
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	if (IPAD) {
		_ball.layer.cornerRadius = 87.5;
	} else {
		_ball.layer.cornerRadius = 37.5;
	}

	
#pragma mark First Launch Code
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"]) {
		
		NSLog(@"First Launch!");
		
		// Set toBePlayed to normal
		[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"toBePlayed"];
		
		// Turn on sound effects
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];
		
		// Keep the intro on
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"intro"];
		
		
		// Set to current method isn't called again
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// Show tutorial code goes here
			// No Tutorial!!!!! :-)
		
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

-(void)viewDidAppear:(BOOL)animated {
	[self checkGameCenterStaus];
}


-(void)viewWillAppear:(BOOL)animated {
	
	[self checkGameCenterStaus];
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		// Night UI code
		[_mode setBackgroundImage:[UIImage imageNamed:@"nightmodebutton.png"] forState:UIControlStateNormal];
		[_play setBackgroundImage:[UIImage imageNamed:@"nightplaybutton.png"] forState:UIControlStateNormal];
		[_settings setBackgroundImage:[UIImage imageNamed:@"nightsettings"] forState:UIControlStateNormal];
		[_frame setImage:[UIImage imageNamed:@"nighttitle.png"]];
		[_background setImage:[UIImage imageNamed:@"nightbackground.png"]];
	}
	else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"strategy"] && ![[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"night"]) {
		// Strategy UI Code
		[_mode setBackgroundImage:[UIImage imageNamed:@"strategymodebutton.png"] forState:UIControlStateNormal];
		[_play setBackgroundImage:[UIImage imageNamed:@"strategyplaybutton.png"] forState:UIControlStateNormal];
		[_settings setBackgroundImage:[UIImage imageNamed:@"normalsettings"] forState:UIControlStateNormal];
		[_frame setImage:[UIImage imageNamed:@"strategytitle.png"]];
		[_background setImage:[UIImage imageNamed:@"normalbackground.png"]];
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
														delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate it now", @"Give feedback", @"No, thanks", nil];
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
	else if (buttonIndex == 2) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		NSLog(@"Feedback");
		[self mail];
	}
	else {
		NSLog(@"No, thanks");
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	}
}

-(void)mail {
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		
		mailer.mailComposeDelegate = self;
		
		[mailer setSubject:@"Feedback/Suggestions Inside The Box"];
		
		NSArray *toRecipients = [NSArray arrayWithObjects:@"rybelllc@gmail.com", nil];
		[mailer setToRecipients:toRecipients];
		
		NSString *emailBody = @"Leave your feedback or suggestions here and we will do our best to take them into consideration and make the app even better! If you want support regarding the app then go to http://www.rybel-llc.com/support Thank you for the feedback!";
		[mailer setMessageBody:emailBody isHTML:YES];
		
		[self presentViewController:mailer animated:YES completion:nil];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Incompatibility"
														message:@"Your device doesn't support the mail composer sheet"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
	}
}

- (IBAction)gameCenterButton:(id)sender {
	[self showLeaderboardAndAchievements:NO];
}

- (IBAction)resetGameCenter:(id)sender {
	// Development only, DO NOT INCLUDE
	// Resets game center achivevments
	[self resetAchievements];
}

#pragma mark Game Center

-(void)checkGameCenterStaus {
	if (!gameCenterEnabled) {
		_gamecenterOutlet.hidden = YES;
	}
	else {
		_gamecenterOutlet.hidden = NO;
	}
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	[gameCenterViewController dismissViewControllerAnimated:YES completion:^{
		[self checkGameCenterStaus];
	}];
	
}

-(void)showLeaderboard {
	[self showLeaderboardAndAchievements:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
	GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
	
	gcViewController.gameCenterDelegate = self;
	
	if (shouldShowLeaderboard) {
		gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
		gcViewController.leaderboardIdentifier = @"com.rybel.in-the-box";;
	}
	else{
		gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
	}
	
	[self presentViewController:gcViewController animated:YES completion:nil];
}


-(void)authenticateLocalPlayer{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
		if (viewController != nil) {
			[self presentViewController:viewController animated:YES completion:nil];
		}
		else{
			if ([GKLocalPlayer localPlayer].authenticated) {
				_gameCenterEnabled = YES;
				
				// Get the default leaderboard identifier.
				[[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
					
					if (error != nil) {
						NSLog(@"%@", [error localizedDescription]);
					}
					else{
						leaderboardIdentifier = @"com.rybel.in-the-box";;
					}
				}];
				
				NSLog(@"Gamecenter Enabled");
				gameCenterEnabled = YES;
				[self checkGameCenterStaus];
			}
			
			else{
				NSLog(@"Gamecenter Not Enabled");
				gameCenterEnabled = NO;
				[self checkGameCenterStaus];
			}
		}
	};
}


- (void) resetAchievements
{
	NSLog(@"Attempt to reset game center achievements");
	// Clear all progress saved on Game Center.
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
	 {
		 if (error != nil){
			 NSLog(@"Error: %@", error);
		 }
			 
    }];
}

- (void) retrieveAchievmentMetadata
{
	[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:
	 ^(NSArray *descriptions, NSError *error) {
		 if (error != nil)
		 {
			 NSLog(@"Error: %@", error);
		 }
		 if (descriptions != nil)
		 {
			 gameCenterData = descriptions;
		 }
	 }];
}

@end
