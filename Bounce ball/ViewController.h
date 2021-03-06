//
//  ViewController.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/15/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>

#import "TimeBased.h"
#import "GoalBased.h"



NSArray *gameCenterData;
BOOL gameCenterEnabled;
UIAlertView *alert;
NSString *alias;
SystemSoundID toggle;
int rateCount;
BOOL showAd;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, ADBannerViewDelegate, MFMailComposeViewControllerDelegate> {
}


- (IBAction)startButton:(id)sender;
- (IBAction)gameCenterButton:(id)sender;
- (IBAction)soundsButton:(id)sender;
- (IBAction)gameTypeButton:(id)sender;
- (IBAction)lightButton:(id)sender;
- (IBAction)creditsButton:(id)sender;
- (IBAction)storeButton:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *modeOutlet;
@property (strong, nonatomic) IBOutlet UIButton *startOutlet;
@property (strong, nonatomic) IBOutlet UIButton *gamecenterOutlet;
@property (strong, nonatomic) IBOutlet UIButton *soundOutlet;
@property (strong, nonatomic) IBOutlet UIButton *lightOutlet;
@property (strong, nonatomic) IBOutlet UIButton *creditsOutlet;
@property (strong, nonatomic) IBOutlet UIButton *storeOutlet;


@property (strong, nonatomic) IBOutlet UIImageView *titleOutlet;
@property (strong, nonatomic) IBOutlet UIImageView *background;
// Disabled for test run to see about video ads
@property (strong, nonatomic) IBOutlet ADBannerView *banner;

@property (strong, nonatomic) IBOutlet UILabel *ad;




@end

