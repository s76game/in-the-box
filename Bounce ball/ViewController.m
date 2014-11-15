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
	[UIView setAnimationDuration:0];
	[banner setAlpha:1];
	[UIView commitAnimations];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adsLoaded"];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0];
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
	_banner.delegate = self;
	
	[self authenticateLocalPlayer];
	[self retrieveAchievmentMetadata];
	
	
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


	
#pragma mark First Launch Code
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"]) {
		
		NSLog(@"First Launch!");
		
		// Set toBePlayed to STRAGETY
		[[NSUserDefaults standardUserDefaults] setObject:@"strategy" forKey:@"toBePlayed"];
		
		// Turn on sound effects
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];		
		
		// Set to current method isn't called again
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// Show tutorial code goes here
			// No Tutorial Yet
		
	}
	else {
#pragma mark Update First Launch
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]]) {
		NSLog(@"Update launch %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
		
		NSString *updateText = [NSString stringWithFormat:@"Update Text"];
		
		UIAlertView *update = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Update %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] message:[NSString stringWithFormat:@"%@", updateText] delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
		[update show];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
	
	
	}
}
	}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


#pragma mark Play Button
- (IBAction)startButton:(id)sender {
	
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
		[_startOutlet setBackgroundImage:[UIImage imageNamed:@"night_play.png"] forState:UIControlStateNormal];
		[_lightOutlet setBackgroundImage:[UIImage imageNamed:@"night_light.png"] forState:UIControlStateNormal];
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"night_rybel.png"] forState:UIControlStateNormal];
		[_gamecenterOutlet setBackgroundImage:[UIImage imageNamed:@"night_gamecenter.png"] forState:UIControlStateNormal];
		[_titleOutlet setImage:[UIImage imageNamed:@"night_title.png"]];
		[_background setImage:[UIImage imageNamed:@"night_background.png"]];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
	else {
		// Normal UI code
		[_startOutlet setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		[_lightOutlet setBackgroundImage:[UIImage imageNamed:@"light.png"] forState:UIControlStateNormal];
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"rybel.png"] forState:UIControlStateNormal];
		[_gamecenterOutlet setBackgroundImage:[UIImage imageNamed:@"gamecenter.png"] forState:UIControlStateNormal];
		[_titleOutlet setImage:[UIImage imageNamed:@"title.png"]];
		[_background setImage:[UIImage imageNamed:@"background.png"]];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
	
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"strategy"]) {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[_modeOutlet setBackgroundImage:[UIImage imageNamed:@"night_strategy.png"] forState:UIControlStateNormal];
		}
		else {
			[_modeOutlet setBackgroundImage:[UIImage imageNamed:@"strategy.png"] forState:UIControlStateNormal];
		}
	}
	else {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[_modeOutlet setBackgroundImage:[UIImage imageNamed:@"night_timed.png"] forState:UIControlStateNormal];
		}
		else {
			[_modeOutlet setBackgroundImage:[UIImage imageNamed:@"timed.png"] forState:UIControlStateNormal];
		}
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[_soundOutlet setBackgroundImage:[UIImage imageNamed:@"night_sound_on.png"] forState:UIControlStateNormal];
		}
		else {
			[_soundOutlet setBackgroundImage:[UIImage imageNamed:@"sound_on.png"] forState:UIControlStateNormal];
		}
	}
	else {
		if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
			[_soundOutlet setBackgroundImage:[UIImage imageNamed:@"night_sound_off.png"] forState:UIControlStateNormal];
		}
		else {
			[_soundOutlet setBackgroundImage:[UIImage imageNamed:@"sound_off.png"] forState:UIControlStateNormal];
		}
	}
	
	
#pragma mark Rate my app code

	//Check if game has been played this version
	if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
		if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@CHECK",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
			// Show UIALert View
			
			alert=[[UIAlertView alloc]initWithTitle:@"Rate my app" message:@"If you enjoy using Inside the Box would you mind taking a moment to rate it? It won't take more than a minute. Thanks for the support!"
														delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate it now", @"Give feedback", @"No, thanks", nil];
			alert.tag=101;
			[alert show];
		}
	}
	
	
}


-(IBAction)soundsButton:(id)sender {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundFX"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];
	}
	[self viewWillAppear:YES];
	[self playSound];
}

-(IBAction)gameTypeButton:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"strategy"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"toBePlayed"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:@"strategy" forKey:@"toBePlayed"];
	}
	[self viewWillAppear:YES];
	[self playSound];
}

-(IBAction)lightButton:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"UI"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:@"night" forKey:@"UI"];
	}
	[self viewWillAppear:YES];
	[self playSound];
}

-(IBAction)creditsButton:(id)sender {
	
}

-(void)playSound {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		// Create the sound ID
		NSString* path = [[NSBundle mainBundle]
						  pathForResource:@"toggle_sound" ofType:@"mp3"];
		NSURL* url = [NSURL fileURLWithPath:path];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &toggle);
		
		// Play the sound
		AudioServicesPlaySystemSound(toggle);
	}
	else {
		NSLog(@"***Toggle Sound***");
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alert.tag==101) {
		if (buttonIndex == 0) {
			NSLog(@"Remind me later");
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		}
		else if (buttonIndex == 1){
			NSLog(@"Rate it now");
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
			// Open app App Store URL
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/us/i1fu1.i"]];
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
}

-(void)mail {
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		
		mailer.mailComposeDelegate = self;
		
		[mailer setSubject:@"Feedback/Suggestions For Inside The Box"];
		
		NSArray *toRecipients = [NSArray arrayWithObjects:@"rybelllc@gmail.com", nil];
		[mailer setToRecipients:toRecipients];
		
		NSString *emailBody = @"Give us your feedback or suggestions here!";
		[mailer setMessageBody:emailBody isHTML:YES];
		
		[self presentViewController:mailer animated:YES completion:nil];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Incompatibility"
														message:@"The dark lords of email have frowned upon you"
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles: nil];
		[alert show];
	}
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
 // Notifies users about errors associated with the interface
 switch (result)
 {
	 case MFMailComposeResultCancelled:
		 NSLog(@"Cancelled");
		 break;
	 case MFMailComposeResultSaved:
		 NSLog(@"Saved");
		 break;
	 case MFMailComposeResultSent:
		 NSLog(@"Sent");
		 break;
	 case MFMailComposeResultFailed:
		 NSLog(@"Failed");
		 break;
		 
	 default:
	 {
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Failure" message:@":-("
														delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		 [alert show];
	 }
		 
		 break;
 }
 [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)gameCenterButton:(id)sender {
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Game Center not enabled!"
														  message:@"Please login for Game Center use"
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		[message show];
	} else {
		GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil)
		{
			gameCenterController.gameCenterDelegate = self;
			gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
			UIViewController *vc = self.view.window.rootViewController;
			[vc presentViewController: gameCenterController animated: YES completion:nil];
		}
	}
}

#pragma mark Game Center

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	[gameCenterViewController dismissViewControllerAnimated:YES completion:^{
		
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
				alias = [GKLocalPlayer localPlayer].alias;
				[self specialUsernames];
				gameCenterEnabled = YES;
			}
			
			else{
				NSLog(@"Gamecenter Not Enabled");
				gameCenterEnabled = NO;
			}
		}
	};
}

-(void)specialUsernames {
	if ([alias isEqualToString:@"Alpha-Rybel"]) {
		NSLog(@"SANDBOX");
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	}
	else if ([alias isEqualToString:@"Camille hensley"]) {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
	}
	else if ([alias isEqualToString:@"innovator013"]) {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
	}
	else if ([alias isEqualToString:@"_!(ConnorC)!_"]) {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:69];
	}
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
		 if (descriptions != nil)
		 {
			 gameCenterData = descriptions;
		 }
	 }];
}

@end
