//
//  Credits.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/8/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>

@protocol test <NSObject>
-(void)showLeaderboard;
@end

@interface Credits : UIViewController <NSObject, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *credits;
@property (strong, nonatomic) IBOutlet UIImageView *creditsBackground;
@property (strong, nonatomic) IBOutlet UIButton *backOutlet;
@property (strong, nonatomic) IBOutlet UIButton *feedbackOutlet;
@property (strong, nonatomic) IBOutlet UIButton *rateOutlet;
@property (strong, nonatomic) IBOutlet ADBannerView *AdBanner;

-(IBAction)backButton:(id)sender;
-(IBAction)feedbackButton:(id)sender;
-(IBAction)rateButton:(id)sender;

@end
