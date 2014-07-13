//
//  Settings.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/25/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "Settings.h"

@interface Settings ()

@end

@implementation Settings

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
	
	[_soundFXOutlet addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
	
	//Only hide until URL has been received
	_rateOutlet.hidden = YES;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		_soundFXOutlet.on = YES;
	}
	else {
		_soundFXOutlet.on = NO;
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"Alpha");
	[self updateInterface];
}


-(void)updateInterface {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"nightcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"nightratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"nightback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"nightbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsnighticon.png"]];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"nightratebutton.png"] forState:UIControlStateNormal];
		[_label setTextColor:[UIColor whiteColor]];
	}
	else {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"normalcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"normalratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"normalback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"normalbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsicon.png"]];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"normalratebutton.png"] forState:UIControlStateNormal];
		[_label setTextColor:[UIColor blackColor]];
	}
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

-(void)stateChanged:(UISwitch *)switchState {
	if (_soundFXOutlet.isOn) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundFX"];
	}
}


- (IBAction)feedback:(id)sender {
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

// Goes along with mail modal view controller
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
		 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Failure" message:@"Sending Failed - Unknown Error"
														delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		 [alert show];
	 }
		 
		 break;
 }
 [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rate:(id)sender {
	
	// Open appstore app URL
	
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"OUR URL HERE"]];
}
@end
