//
//  ModeSelect.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"

@interface ModeSelect : ViewController {
	SystemSoundID breaking;
}
- (IBAction)normalButton:(id)sender;
- (IBAction)backButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *modeTitle;
@property (strong, nonatomic) IBOutlet UIImageView *modeBackground;
@property (strong, nonatomic) IBOutlet UIButton *back;
@property (strong, nonatomic) IBOutlet UISwitch *nightMode;
@property (strong, nonatomic) IBOutlet UIButton *nightImage;

	

@end
