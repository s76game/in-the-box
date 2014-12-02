//
//  Connection.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/1/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Connection.h"

@implementation Connection
	
-(void)openConnection:(NSString *)address {
	NSString *url =[NSString stringWithFormat:@"%@", address];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"GET"]; // This might be redundant, I'm pretty sure GET is the default value
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	[connection start];
	[self getContents];
	
}

-(void)getContents {
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.246/~ryan/index.php"]];
	NSError *error;
	NSString *stringFromFileAtURL = [[NSString alloc]
									 initWithContentsOfURL:URL
									 encoding:NSUTF8StringEncoding
									 error:&error];
	if (stringFromFileAtURL == nil) {
		// an error occurred
		NSLog(@"Error reading file at %@\n%@",
			  URL, [error localizedFailureReason]);
		// implementation continues ...
	}
	else {
		NSLog(@"%@", stringFromFileAtURL);
	}
}

@end