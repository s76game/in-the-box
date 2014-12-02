//
//  OpenConnection.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/1/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "OpenConnection.h"

@implementation OpenConnection

-(void)openURL:(NSString *)url {
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"GET"]; // This might be redundant, I'm pretty sure GET is the default value
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	[connection start];
}

-(NSString *)getStringFromURL:(NSString *)url {

	NSError *error;
	NSString *stringFromFileAtURL = [[NSString alloc]
									 initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]
									 encoding:NSUTF8StringEncoding
									 error:&error];
	if (stringFromFileAtURL == nil) {
		// an error occurred
		NSLog(@"Error reading file at %@\n%@", url, [error localizedFailureReason]);
	}
	
	return stringFromFileAtURL;
	
}

//
//Code to implement class
//
//OpenConnection *_openConnection;
//
//_openConnection = [[OpenConnection alloc] init];
//NSLog(@"%@", [_openConnection getStringFromURL:@"http://192.168.1.246/~ryan/index.php"]);
//

@end
