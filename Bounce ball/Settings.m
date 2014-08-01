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
	
	//Only hide until URL has been received
	_rateOutlet.hidden = YES;
	
	
	// Set font sizes for iPad
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
	if (IPAD) {
		[_soundFXLabel setFont:[UIFont fontWithName:@"Prototype" size:66]];
		[_introLabel setFont:[UIFont fontWithName:@"Prototype" size:66]];
	}
	
	
	// Configure switches from save
	[_soundFXOutlet addTarget:self action:@selector(stateChanged1:) forControlEvents:UIControlEventValueChanged];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		_soundFXOutlet.on = YES;
	}
	else {
		_soundFXOutlet.on = NO;
	}
	
	[_introOutlet addTarget:self action:@selector(stateChanged2:) forControlEvents:UIControlEventValueChanged];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"intro"]) {
		_introOutlet.on = YES;
	}
	else {
		_introOutlet.on = NO;
	}
	
}

-(void)playSound {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"soundFX"]) {
		// Create the sound ID
		NSString* path = [[NSBundle mainBundle]
						  pathForResource:@"toggle_sound" ofType:@"mp3"];
		NSURL* url = [NSURL fileURLWithPath:path];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &breaking);
		
		// Play the sound
		AudioServicesPlaySystemSound(breaking);
	}
	else {
		NSLog(@"***Breaking Sound***");
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
	[self updateInterface];
}


-(void)updateInterface {
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"adsLoaded"]) {
		_AdBanner.hidden = NO;
	}
	else {
		_AdBanner.hidden = YES;
	}
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"nightcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"nightratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"nightback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"nightbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsnighticon.png"]];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"nightfeedbackbutton.png"] forState:UIControlStateNormal];
		[_label setTextColor:[UIColor whiteColor]];
	}
	else {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"normalcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"normalratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"normalback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"normalbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsicon.png"]];
		[_feedbackOutlet setBackgroundImage:[UIImage imageNamed:@"strategyfeedbackbutton.png"] forState:UIControlStateNormal];
		[_label setTextColor:[UIColor blackColor]];
	}
	
	if (![MFMailComposeViewController canSendMail])
	{
		_feedbackOutlet.hidden = YES;
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

-(void)stateChanged1:(UISwitch *)switchState {
	if (switchState.isOn) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundFX"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundFX"];
	}
	[self playSound];
}

-(void)stateChanged2:(UISwitch *)switchState {
	if (switchState.isOn) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"intro"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"intro"];
	}
	[self playSound];
}


- (IBAction)feedback:(id)sender {
	
	[self achievementComplete:@"judge" percentComplete:100];
	
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		
		mailer.mailComposeDelegate = self;
		
		[mailer setSubject:@"Feedback/Suggestions Inside The Box"];
		
		NSArray *toRecipients = [NSArray arrayWithObjects:@"rybelllc@gmail.com", nil];
		[mailer setToRecipients:toRecipients];
		
		NSString *emailBody = @"Leave your feedback or suggestions here and we will do our best to take them into consideration and make the app even better! If you want support regarding the app then go to http://www.rybel-llc.com/support Thank you for the feedback!";
		[mailer setMessageBody:emailBody isHTML:YES];
		
		[self presentViewController:mailer animated:YES completion:nil];
//	}
//	else
//	{
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Incompatibility"
//														message:@"Your device doesn't support the mail composer sheet"
//													   delegate:nil
//											  cancelButtonTitle:@"OK"
//											  otherButtonTitles: nil];
//		[alert show];
//	}
}

- (IBAction)credits:(id)sender {
	[self achievementComplete:@"credits" percentComplete:100];
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
	
	[self achievementComplete:@"judge" percentComplete:100];
	
	// Open appstore app URL
	
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"OUR URL HERE"]];
}

#pragma mark Game Center Code

- (void)achievementComplete:(NSString *)achievementID percentComplete: (int)percent {
	GKAchievement *achievement1 = [[GKAchievement alloc] initWithIdentifier: [NSString stringWithFormat:@"%@", achievementID]];
	achievement1.percentComplete = percent;
	achievement1.showsCompletionBanner = YES;
	NSArray *achievementsToComplete = [NSArray arrayWithObjects:achievement1, nil];
	NSLog(@"Attempt to report %@", achievement1.identifier);
	[GKAchievement reportAchievements: achievementsToComplete withCompletionHandler:^(NSError *error)
	 {
		 if (error != nil)
		 {
			 NSLog(@"Error in reporting achievements: %@", error);
		 }
	 }];
}



@end
