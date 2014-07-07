//
//  ModeSelect.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ModeSelect.h"

@interface ModeSelect ()

@end

@implementation ModeSelect

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
	[self updateInterface];
	[_nightMode addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
	
	// Check NSUserDefaults for state adjustment: Switch and associated image
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		_nightMode.on = YES;
		[_nightImage setBackgroundImage:[UIImage imageNamed:@"nighttoggleoff.png"] forState:UIControlStateNormal];
	}
	else {
		_nightMode.on = NO;
		[_nightImage setBackgroundImage:[UIImage imageNamed:@"nightmode.png"] forState:UIControlStateNormal];
	}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
	[self updateInterface];
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

- (IBAction)normalButton:(id)sender {
	
	ViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"gamePlay"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"toBePlayed"];
	
	CATransition* transition = [CATransition animation];
	
	transition.duration = 0.3;
	transition.type = kCATransitionFade;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:menu animated:NO];
	
}

- (IBAction)strategyButton:(id)sender {
	
	ViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"gamePlay"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"strategy" forKey:@"toBePlayed"];
	
	CATransition* transition = [CATransition animation];
	
	transition.duration = 0.3;
	transition.type = kCATransitionFade;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:menu animated:NO];

}

- (IBAction)backButton:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)stateChanged:(UISwitch *)switchState
{
	
	[self playSound];
	
	if ([switchState isOn]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"night" forKey:@"UI"];
		[_nightImage setBackgroundImage:[UIImage imageNamed:@"nighttoggleoff.png"] forState:UIControlStateNormal];
		NSLog(@"UI set to night");
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"normal" forKey:@"UI"];
		[_nightImage setBackgroundImage:[UIImage imageNamed:@"nightmode.png"] forState:UIControlStateNormal];
		NSLog(@"UI set to normal");
	}
	[self updateInterface];
}

-(void)playSound {
	
	// Create the sound ID
	NSString* path = [[NSBundle mainBundle]
					  pathForResource:@"toggle_sound" ofType:@"mp3"];
	NSURL* url = [NSURL fileURLWithPath:path];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &breaking);
 
	// Play the sound
	AudioServicesPlaySystemSound(breaking);
}

-(void)updateInterface {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_modeTitle setImage:[UIImage imageNamed:@"nightmodetitle.png"]];
		[_modeBackground setImage:[UIImage imageNamed:@"nightbackground.png"]];
		[_back setBackgroundImage:[UIImage imageNamed:@"nightback.png"] forState:UIControlStateNormal];
		
	}
	else {
		[_modeTitle setImage:[UIImage imageNamed:@"normalmodetitle.png"]];
		[_modeBackground setImage:[UIImage imageNamed:@"normalbackground.png"]];
		[_back setBackgroundImage:[UIImage imageNamed:@"normalback.png"] forState:UIControlStateNormal];
	}
}



@end
