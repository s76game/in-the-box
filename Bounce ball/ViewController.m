//
//  ViewController.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/15/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"

@class GameCenterManager;

@interface ViewController (){
}

@property (nonatomic) BOOL gameCenterEnabled;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;
-(void)authenticateLocalPlayer;

@end
@implementation ViewController


-(void)viewDidLoad {
	[super viewDidLoad];
	
	_banner.delegate = self;
	
	// Activate GameCenter
	_gameCenterEnabled = NO;
	[self authenticateLocalPlayer];
	[self retrieveAchievmentMetadata];

	
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	
	// First Launch Code
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasPerformedFirstLaunch"]) {
		
		// Set toBePlayed to STRAGETY
		[[NSUserDefaults standardUserDefaults] setObject:@"strategy" forKey:@"toBePlayed"];
		
		// Turn on sound effects
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];		
		
		// Set to current method isn't called again
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasPerformedFirstLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// Show tutorial code goes here
			// No Tutorial Yet :-( (maybe ever)
		
	}
}

-(NSString *)getStringFromURL:(NSString *)url {
	
	NSError *error;
	NSString *stringFromFileAtURL = [[NSString alloc]
									 initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]
									 encoding:NSUTF8StringEncoding
									 error:&error];
	if (stringFromFileAtURL == nil) {
		// an error occurred
		NSLog(@"Error reading file at %@\n%@", url, [error localizedFailureReason]);
		
	}
	return stringFromFileAtURL;
}

#pragma mark - iAd

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
	
	// Show the ad banner.
	[UIView animateWithDuration:0.5 animations:^{
		_banner.alpha = 1.0;
	}];
}
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
	
	return YES;
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
	
	// Hide the ad banner.
	[UIView animateWithDuration:0.5 animations:^{
		_banner.alpha = 0.0;
	}];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	// Update Interface State
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		// Night UI code
		[_startOutlet setBackgroundImage:[UIImage imageNamed:@"night_play.png"] forState:UIControlStateNormal];
		[_lightOutlet setBackgroundImage:[UIImage imageNamed:@"night_light.png"] forState:UIControlStateNormal];
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"night_rybel.png"] forState:UIControlStateNormal];
		[_storeOutlet setBackgroundImage:[UIImage imageNamed:@"night_store_icon.png"] forState:UIControlStateNormal];
		[_gamecenterOutlet setBackgroundImage:[UIImage imageNamed:@"night_gamecenter.png"] forState:UIControlStateNormal];
		[_titleOutlet setImage:[UIImage imageNamed:@"night_title.png"]];
		[_background setImage:[UIImage imageNamed:@"night_background.png"]];
		_ad.textColor = [UIColor whiteColor];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
	else {
		// Normal UI code
		[_startOutlet setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
		[_lightOutlet setBackgroundImage:[UIImage imageNamed:@"light.png"] forState:UIControlStateNormal];
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"rybel.png"] forState:UIControlStateNormal];
		[_gamecenterOutlet setBackgroundImage:[UIImage imageNamed:@"gamecenter.png"] forState:UIControlStateNormal];
		[_storeOutlet setBackgroundImage:[UIImage imageNamed:@"store_icon.png"] forState:UIControlStateNormal];
		[_titleOutlet setImage:[UIImage imageNamed:@"title.png"]];
		[_background setImage:[UIImage imageNamed:@"background.png"]];
		_ad.textColor = [UIColor blackColor];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
	
	// Game Mode Toggle Button
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
	
	// Sound Toggle Button
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
	
	
	//Rate My App

	if (rateCount == 10) {
		//Check if game has been played this version
		if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
			if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@CHECK",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]]) {
				// Show UIALert View
				
				alert=[[UIAlertView alloc]initWithTitle:@"Rate my app" message:@"Want to leave a rating on the App Store?"
														delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate it now", @"Give feedback", @"No, thanks", nil];
				alert.tag=101;
				[alert show];
			}
		}
		rateCount = 0;
		[[NSUserDefaults standardUserDefaults] setInteger:rateCount forKey:@"rateCount"];
	}
	else {
		rateCount = rateCount + 1;
		[[NSUserDefaults standardUserDefaults] setInteger:rateCount forKey:@"rateCount"];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// Rate my app
	if (alert.tag==101) {
		// Remind me later
		if (buttonIndex == 0) {
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		}
		// Rate it now
		else if (buttonIndex == 1){
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"reward"];
			// Open app App Store URL
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/inthebox"]];
		}
		// Leave feedback
		else if (buttonIndex == 2) {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
			[self mail];
		}
		// No Thanks
		else {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@CHECK", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		}
	}
}

#pragma mark - Buttons

- (IBAction)startButton:(id)sender {
	// Play Game
	ViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"gamePlay"];
	
	CATransition* transition = [CATransition animation];
	
	transition.duration = 0.3;
	transition.type = kCATransitionReveal;
	transition.subtype = kCATransitionFromTop;
	transition.duration = 1.0;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:menu animated:NO];
}

-(IBAction)soundsButton:(id)sender {
	// Toggle Sounds
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
	// Toggle Game Modes
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
	// Toggle Night Mode
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

- (IBAction)storeButton:(id)sender {
}


-(void)playSound {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		NSString* path = [[NSBundle mainBundle]
						  pathForResource:@"toggle_sound" ofType:@"mp3"];
		NSURL* url = [NSURL fileURLWithPath:path];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &toggle);
		AudioServicesPlaySystemSound(toggle);
	}
	else {
		// Log to console when sound disabled
		NSLog(@"***Toggle Sound***");
	}
}

-(void)mail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate = self;
		[mailer setSubject:@"Feedback/Suggestions For Inside The Box"];
		NSArray *toRecipients = [NSArray arrayWithObjects:@"rybelllc@gmail.com", nil];
		[mailer setToRecipients:toRecipients];
		NSString *emailBody = @"Leave your feedback or suggestions here!";
		[mailer setMessageBody:emailBody isHTML:YES];
		[self presentViewController:mailer animated:YES completion:nil];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Incompatibility"
														message:@"We were unable to send your email :-("
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles: nil];
		[alert show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Mail: Cancelled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail: Saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail: Sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail: Failed");
			break;
		default: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Failure" message:@":-(" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show];
			}
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GameCenter

-(IBAction)gameCenterButton:(id)sender {
	// Check for GameCenter authorization
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Game Center Not Enabled!"
														  message:@"Please login for Game Center use."
														 delegate:nil
												cancelButtonTitle:@"Ok"
												otherButtonTitles:nil];
		[message show];
	}
	else {
		GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
		if (gameCenterController != nil) {
			gameCenterController.gameCenterDelegate = self;
			gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
			UIViewController *vc = self.view.window.rootViewController;
			[vc presentViewController: gameCenterController animated: YES completion:nil];
		}
	}
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	// Dismiss GameCenter Leaderboard on user action
	[gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showLeaderboard {
	[self showLeaderboardAndAchievements:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard {
	// Get Leaderboard Information
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

-(void)retrieveAchievmentMetadata {
	// Get Achievement Infomation
	[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler: ^(NSArray *descriptions, NSError *error) {
		if (descriptions != nil) {
			gameCenterData = descriptions;
		}
	}];
}

-(void)authenticateLocalPlayer{
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
		if (viewController != nil) {
			[self presentViewController:viewController animated:YES completion:nil];
		}
		else {
			if ([GKLocalPlayer localPlayer].authenticated) {
				_gameCenterEnabled = YES;
				[[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
					if (error != nil) {
						NSLog(@"%@", [error localizedDescription]);
					}
					else{
						leaderboardIdentifier = @"com.rybel.in-the-box";;
					}
				}];
				alias = [GKLocalPlayer localPlayer].alias;
				gameCenterEnabled = YES;
			}
			else {
				NSLog(@"Gamecenter Not Enabled");
				gameCenterEnabled = NO;
			}
		}
	};
}

// Used in Development Only
-(void)resetAchievements {
	// Should never be called
	NSLog(@"Attempt to reset game center achievements");
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
		 if (error != nil){
			 NSLog(@"Error: %@", error);
		 }
    }];
}

@end