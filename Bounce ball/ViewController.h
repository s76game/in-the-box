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

NSArray *gameCenterData;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, ADBannerViewDelegate, MFMailComposeViewControllerDelegate> {
	
	
}
- (IBAction)start:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *ball;
@property (strong, nonatomic) IBOutlet UIButton *mode;
@property (strong, nonatomic) IBOutlet UIButton *play;
@property (strong, nonatomic) IBOutlet UIButton *settings;
@property (strong, nonatomic) IBOutlet UIImageView *frame;
@property (strong, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet ADBannerView *banner;
- (IBAction)gameCenterButton:(id)sender;

- (IBAction)resetGameCenter:(id)sender;

@end

