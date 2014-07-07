//
//  Settings.m
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/25/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "Settings.h"

@interface Settings ()

@end

@implementation Settings

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
	[self updateInterface];
}


-(void)updateInterface {
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		// Night UI Code
	}
	else {
		// Normal UI Code
	}
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

- (IBAction)soundFXSwitch:(id)sender {
}
- (IBAction)credits:(id)sender {
}

- (IBAction)rate:(id)sender {
}
@end
