//
//  Settings.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/25/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"

@interface Settings : ViewController {
	
}
@property (strong, nonatomic) IBOutlet UISwitch *nightMode;
@property (strong, nonatomic) IBOutlet UIImageView *settingsBackground;
@property (strong, nonatomic) IBOutlet UIImageView *settingsIcon;
- (IBAction)soundFXSwitch:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *soundFXLabel;
- (IBAction)credits:(id)sender;
- (IBAction)rate:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *creditsOutlet;
@property (strong, nonatomic) IBOutlet UIButton *rateOutlet;
@property (strong, nonatomic) IBOutlet UIButton *backOutlet;

@end
