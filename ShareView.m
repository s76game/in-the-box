//
//  ShareView.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/13/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//


#import "ShareView.h"
#import "OpenConnection.h"


@interface ShareView () {
	OpenConnection *_openConnection;
}

@end

@implementation ShareView

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	_friendKeyBox.delegate = self;
	
	[_myCode setTitle:[NSString stringWithFormat:@"%i",(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"sharingKey"]] forState:UIControlStateNormal];
	
	_pasteButtonOutlet.alpha = 0;
	validKey = NO;
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(dismissKeyboard)];
	
	[self.view addGestureRecognizer:tap];
	
	self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
	
	
	[_friendKeyBox addTarget:self
				   action:@selector(textFieldDidChange)
		 forControlEvents:UIControlEventEditingChanged];
	
	_myCode.titleLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"sharingKey"];
}

-(void)viewWillAppear:(BOOL)animated {
	
	self.friendKeyBox.layer.borderWidth = 1.0f;
	self.friendKeyBox.layer.cornerRadius = 15;
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		self.view.layer.contents = (id)[UIImage imageNamed:@"night_background.png"].CGImage;
		[_exit setBackgroundImage:[UIImage imageNamed:@"night_exit.png"] forState:UIControlStateNormal];
		[_pasteButtonOutlet setBackgroundImage:[UIImage imageNamed:@"paste-100-white.png"] forState:UIControlStateNormal];
		_friendExplain.textColor = [UIColor whiteColor];
		_myExplain.textColor = [UIColor whiteColor];
		_friendKeyBox.keyboardAppearance = UIKeyboardAppearanceDark;
		_friendKeyBox.textColor = [UIColor whiteColor];
		self.friendKeyBox.layer.borderColor = [[UIColor whiteColor] CGColor];
		[_myCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	else {
		self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
		[_exit setBackgroundImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
		[_pasteButtonOutlet setBackgroundImage:[UIImage imageNamed:@"paste-100.png"] forState:UIControlStateNormal];
		_friendExplain.textColor = [UIColor blackColor];
		_myExplain.textColor = [UIColor blackColor];
		_friendKeyBox.keyboardAppearance = UIKeyboardAppearanceLight;
		_friendKeyBox.textColor = [UIColor blackColor];
		self.friendKeyBox.layer.borderColor = [[UIColor blackColor] CGColor];
		[_myCode setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
}

-(void)dismissKeyboard {
	[_friendKeyBox resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	if ([pasteboard containsPasteboardTypes: [NSArray arrayWithObject:@"public.utf8-plain-text"]]) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 
		_pasteButtonOutlet.alpha = 1;
 
		[UIView commitAnimations];
	}
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
 
	_pasteButtonOutlet.alpha = 0;
 
	[UIView commitAnimations];
}

-(void)textFieldDidChange {
	NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
	NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:_friendKeyBox.text];
	
	if ([_NumericOnly isSupersetOfSet: myStringSet] && [_friendKeyBox.text length] == 6)
	{
		//String entirely contains decimal numbers only.
		
		NSLog(@"Key:%@", _friendKeyBox.text);
		
		validKey = YES;
	}
	else {
		validKey = NO;
	}
}

- (void)textFieldShouldReturn:(UITextField *)textField{
	if (validKey) {
		[self dismissKeyboard];
		if ([self checkKey] && ![[[NSUserDefaults standardUserDefaults] arrayForKey:@"previousShares"] containsObject:_friendKeyBox.text] && ![[NSUserDefaults standardUserDefaults] integerForKey:@"sharingKey"]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yay!"
															message:@"You have earned a gem to entering a valid code!"
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
			[[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"]+1 forKey:@"gems"];
			NSMutableArray *previousShares = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"previousShares"]];
			[previousShares addObject:_friendKeyBox.text];
			[[NSUserDefaults standardUserDefaults] setObject:previousShares forKey:@"previousShares"];
			[_openConnection openURL:[NSString stringWithFormat:@"http://rybel-llc.com/in-the-box/sharing/sharing.php?key=%@", _friendKeyBox.text]];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
															message:@"The key you entered was either already used by this device or is not a real code."
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)copyAction:(id)sender {
	NSArray *objectsToShare = [NSArray arrayWithObject:[NSString stringWithFormat:@"%i", (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"sharingKey"]]];
	
	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypeAirDrop];
	controller.excludedActivityTypes = excludedActivities;
	[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)exitAction:(id)sender {
	[self dismissKeyboard];
}

-(IBAction)pasteText:(id)sender {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	
 if ([pasteboard containsPasteboardTypes: [NSArray arrayWithObject:@"public.utf8-plain-text"]]) {
	 _friendKeyBox.text = pasteboard.string;
	 [self textFieldDidChange];
	 
 }
}

-(BOOL)checkKey {
	
	_openConnection = [[OpenConnection alloc] init];
	NSString *validKey = [_openConnection getStringFromURL:[NSString stringWithFormat:@"http://rybel-llc.com/in-the-box/sharing/checkkey.php?key=%@", _friendKeyBox.text]];
	
	if ([validKey isEqualToString:@"No"]) {
		return NO;
	}
	else if ([validKey isEqualToString:@"Yes"]) {
		return YES;
	}
	else {
		return NO;
	}
}


@end