//
//  DismissSegue.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/7/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

-(void)perform {
	
	UIViewController *sourceViewController = self.sourceViewController;
	[sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	
}

@end
