//
//  OpenConnection.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/1/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OpenConnection : NSObject

-(void)openURL:(NSString *)url;
-(NSString *)getStringFromURL:(NSString *)url;

@end
