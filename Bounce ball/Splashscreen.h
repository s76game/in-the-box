//
//  Splashscreen.h
//  Bounce ball
//
//  Created by Ryan Cobelli on 6/23/14.
//  Copyright (c) 2014 Rybel. All rights reserved.
//

#import "ViewController.h"
#import "OpenConnection.h"

@interface Splashscreen : ViewController{
	
	BOOL moved;
	
}
@property (strong, nonatomic) IBOutlet UIImageView *splashImage;
@property (strong, nonatomic) IBOutlet UIImageView *quote;
@property (strong, nonatomic) IBOutlet UIImageView *quote2;
- (IBAction)advance:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *advanceOulet;
@property (strong, nonatomic) IBOutlet ADBannerView *AdBanner;



@end
