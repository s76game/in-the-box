//
//  ShareView.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/5/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "ViewController.h"

@interface ShareView : ViewController
	
@property (strong, nonatomic) IBOutlet UITextField *friendKeyBox;
@property (strong, nonatomic) IBOutlet UILabel *myCode;

@property (strong, nonatomic) IBOutlet UIButton *exit;

- (IBAction)exitAction:(id)sender;

@end
