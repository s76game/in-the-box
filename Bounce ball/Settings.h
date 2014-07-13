//
//  Settings.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/25/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>

@interface Settings : ViewController <MFMailComposeViewControllerDelegate>{
	
}
@property (strong, nonatomic) IBOutlet UISwitch *soundFXOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *settingsBackground;
@property (strong, nonatomic) IBOutlet UIImageView *settingsIcon;
@property (strong, nonatomic) IBOutlet UILabel *soundFXLabel;
- (IBAction)feedback:(id)sender;
- (IBAction)rate:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *creditsOutlet;
@property (strong, nonatomic) IBOutlet UIButton *rateOutlet;
@property (strong, nonatomic) IBOutlet UIButton *backOutlet;
@property (strong, nonatomic) IBOutlet UIButton *feedbackOutlet;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet ADBannerView *AdBanner;

@end
