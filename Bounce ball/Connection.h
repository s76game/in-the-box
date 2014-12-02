//
//  Connection.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 12/1/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Connection <NSObject>


@end

@interface Connection : NSObject

@property (nonatomic, weak) id<Connection> delegate;

-(void)openConnection:(NSString *)address;

@end