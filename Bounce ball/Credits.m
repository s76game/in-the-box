//
//  Credits.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/8/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Credits.h"


@interface Credits ()

@property (weak, nonatomic) id <test> delegate;

@end

@implementation Credits

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
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
	[self updateInterface];
	
	[self.delegate showLeaderboard];
}

-(void)updateInterface {
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"adsLoaded"]) {
		_AdBanner.hidden = NO;
	}
	else {
		_AdBanner.hidden = YES;
	}
	
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

-(IBAction)backButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)feedbackButton:(id)sender {
	[self mail];
}

-(IBAction)rateButton:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://appsto.re/us/i1fu1.i"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
