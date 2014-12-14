//
//  ShareView.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/13/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "ViewController.h"

BOOL validKey;

@interface ShareView : ViewController

@property (strong, nonatomic) IBOutlet UITextField *friendKeyBox;
@property (strong, nonatomic) IBOutlet UIButton *myCode;
@property (strong, nonatomic) IBOutlet UIButton *exit;
@property (strong, nonatomic) IBOutlet UIButton *pasteButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *searchOutlet;

-(IBAction)pasteText:(id)sender;
- (IBAction)copyAction:(id)sender;

@end
