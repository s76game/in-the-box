//
//  Credits.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/8/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Credits.h"

@interface Credits ()

@end

@implementation Credits

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	[self updateInterface];
}

#pragma mark - iAd

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
	
	// Show the ad banner.
	[UIView animateWithDuration:0.5 animations:^{
		_AdBanner.alpha = 1.0;
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
		_AdBanner.alpha = 0.0;
	}];
}


-(void)updateInterface {
	// Night Mode vs Normal
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_credits setImage:[UIImage imageNamed:@"night_credits.png"]];
		[_creditsBackground setImage:[UIImage imageNamed:@"night_background.png"]];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"night_exit.png"] forState:UIControlStateNormal];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"night_feedback.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"night_rate.png"] forState:UIControlStateNormal];
	}
	else {
		[_credits setImage:[UIImage imageNamed:@"credits.png"]];
		[_creditsBackground setImage:[UIImage imageNamed:@"background.png"]];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"feedback.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"rate.png"] forState:UIControlStateNormal];
	}
}

#pragma mark - Buttons

-(IBAction)backButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)rateButton:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/inthebox"]];
}

-(IBAction)feedbackButton:(id)sender {
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

@end