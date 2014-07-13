//
//  Splashscreen.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "Splashscreen.h"

@interface Splashscreen ()

@end

@implementation Splashscreen

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
	
	_quote.alpha = 0.0;
	_quote2.alpha = 0.0;
	_advanceOulet.alpha = 0.0;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bannerVisible"]) {
		_AdBanner.hidden = NO;
	}
	else {
		_AdBanner.hidden = YES;
	}
	
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		_splashImage.image = [UIImage imageNamed:@"nightbackground.png"];
		_quote.image = [UIImage imageNamed:@"nightquote1.png"];
		_quote2.image = [UIImage imageNamed:@"nightquote2.png"];
		[_advanceOulet setBackgroundImage:[UIImage imageNamed:@"normalproceed.png"] forState:UIControlStateNormal];
	}
	else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"strategy"] && ![[[NSUserDefaults standardUserDefaults] stringForKey:@"toBePlayed"] isEqualToString:@"night"]) {
		// Strategy UI Code
		_splashImage.image = [UIImage imageNamed:@"normalbackground.png"];
		_quote.image = [UIImage imageNamed:@"normalquote1.png"];
		_quote2.image = [UIImage imageNamed:@"normalquote2.png"];
		[_advanceOulet setBackgroundImage:[UIImage imageNamed:@"strategyproceed.png"] forState:UIControlStateNormal];
	}
	else {
		_splashImage.image = [UIImage imageNamed:@"normalbackground.png"];
		_quote.image = [UIImage imageNamed:@"normalquote1.png"];
		_quote2.image = [UIImage imageNamed:@"normalquote2.png"];
		[_advanceOulet setBackgroundImage:[UIImage imageNamed:@"normalproceed.png"] forState:UIControlStateNormal];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
	[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
		_quote.alpha = 1.0f;
		_advanceOulet.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0 delay:0.5 options:0 animations:^{
			_quote2.alpha = 1.0f;
		} completion:^(BOOL finished) {
			[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(advanceTimer:) userInfo:nil repeats:NO];		}];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)advanceTimer:(NSTimer *)timer {
	[self advanceScene];
}

-(void)advanceScene {
	
	if (!moved) {
		
		moved = YES;
		
		ViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
	
		CATransition* transition = [CATransition animation];
	
		transition.duration = 0.5;
		transition.type = kCATransitionFade;
	
		[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
		[self.navigationController pushViewController:menu animated:NO];
		
	}
		
}

- (IBAction)advance:(id)sender {
	[self advanceScene];
}

@end
