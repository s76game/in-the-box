//
//  Dismiss.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/13/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Dismiss.h"

@implementation Dismiss

- (void)perform {
	UIViewController *sourceViewController = self.sourceViewController;
	[sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
