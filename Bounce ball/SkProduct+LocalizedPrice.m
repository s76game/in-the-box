//
//  SkProduct+LocalizedPrice.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 11/24/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

// SKProduct+LocalizedPrice.m
#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:self.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:self.price];
	return formattedString;
}

@end
