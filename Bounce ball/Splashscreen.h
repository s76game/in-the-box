//
//  Splashscreen.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"

@interface Splashscreen : ViewController{
	
	BOOL moved;
	
}
@property (strong, nonatomic) IBOutlet UIImageView *splashImage;
@property (strong, nonatomic) IBOutlet UIImageView *quote;
- (IBAction)advance:(id)sender;



@end
