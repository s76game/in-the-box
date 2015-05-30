//
//  Splashscreen.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "Splashscreen.h"

@interface Splashscreen () {
}
@end

@implementation Splashscreen

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	// Pre-animation values
	_quote.alpha = 0.0;
	_quote2.alpha = 0.0;
	_advanceOulet.alpha = 0.0;
	
	// Update Interface
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		_splashImage.image = [UIImage imageNamed:@"night_background.png"];
		_quote.image = [UIImage imageNamed:@"night_quote1.png"];
		_quote2.image = [UIImage imageNamed:@"night_quote2.png"];
		[_advanceOulet setBackgroundImage:[UIImage imageNamed:@"night_proceed.png"] forState:UIControlStateNormal];
	}
	else {
		_splashImage.image = [UIImage imageNamed:@"background.png"];
		_quote.image = [UIImage imageNamed:@"quote1.png"];
		_quote2.image = [UIImage imageNamed:@"quote2.png"];
		[_advanceOulet setBackgroundImage:[UIImage imageNamed:@"proceed.png"] forState:UIControlStateNormal];
	}
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - iAd

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
	
	// Show the ad banner.
	[UIView animateWithDuration:0.5 animations:^{
		_AdBanner.alpha = 1.0;
	}];
}
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
	
	return YES;
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
	
	// Hide the ad banner.
	[UIView animateWithDuration:0.5 animations:^{
		_AdBanner.alpha = 0.0;
	}];
}


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	// Fade in animation
	[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
		_quote.alpha = 1.0f;
		_advanceOulet.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
			_quote2.alpha = 1.0f;
		} completion:^(BOOL finished) {
		}];
	}];
}


// Recognize swipe to advance
-(IBAction)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer {
	[self advanceScene];
}

-(IBAction)advance:(id)sender {
	[self advanceScene];
}


-(void)advanceScene {
	[self performSegueWithIdentifier:@"advance" sender:self];
}

@end
