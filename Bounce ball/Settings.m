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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
	[self updateInterface];
}


-(void)updateInterface {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"nightcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"nightratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"nightback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"nightbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsnighticon.png"]];
	}
	else {
		[_creditsOutlet setBackgroundImage:[UIImage imageNamed:@"normalcreditsbutton.png"] forState:UIControlStateNormal];
		[_rateOutlet setBackgroundImage:[UIImage imageNamed:@"normalratebutton.png"] forState:UIControlStateNormal];
		[_backOutlet setBackgroundImage:[UIImage imageNamed:@"normalback.png"] forState:UIControlStateNormal];
		[_settingsBackground setImage:[UIImage imageNamed:@"normalbackground.png"]];
		[_settingsIcon setImage:[UIImage imageNamed:@"settingsicon.png"]];
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

- (IBAction)soundFXSwitch:(id)sender {
	
}
- (IBAction)credits:(id)sender {
}

- (IBAction)rate:(id)sender {
}
@end
