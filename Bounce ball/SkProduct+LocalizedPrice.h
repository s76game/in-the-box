//
//  SkProduct+LocalizedPrice.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 11/24/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end