//
//  Credits.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 7/8/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Credits.h"

@interface Credits ()

@end

@implementation Credits

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
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
	[self updateInterface];
}

-(void)updateInterface {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_credits setImage:[UIImage imageNamed:@"nightcredits.png"]];
		[_creditsBackground setImage:[UIImage imageNamed:@"nightbackground.png"]];
	}
	else {
		[_credits setImage:[UIImage imageNamed:@"normalcredits.png"]];
		[_creditsBackground setImage:[UIImage imageNamed:@"normalbackground.png"]];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
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

@end
