//
//  Credits.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/8/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "ViewController.h"

@protocol test <NSObject>
-(void)showLeaderboard;
@end

@interface Credits : ViewController <NSObject>
@property (strong, nonatomic) IBOutlet UIImageView *credits;
@property (strong, nonatomic) IBOutlet UIImageView *creditsBackground;
@property (strong, nonatomic) IBOutlet UIButton *creditsBack;
@property (strong, nonatomic) IBOutlet ADBannerView *AdBanner;

@end
