//
//  ShareView.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/5/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "ShareView.h"

@interface ShareView ()

@end

@implementation ShareView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
	
	
	[_friendKeyBox addTarget:self
				   action:@selector(textFieldDidChange)
		 forControlEvents:UIControlEventEditingChanged];
	
	_myCode.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"sharingKey"];
}

-(void)textFieldDidChange {
	NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
	NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:_friendKeyBox.text];
	
	if ([_NumericOnly isSupersetOfSet: myStringSet] && [_friendKeyBox.text length] == 6)
	{
		//String entirely contains decimal numbers only.
		
		NSLog(@"Key:%@", _friendKeyBox.text);
	}
	else {
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)exitAction:(id)sender {
}
@end
