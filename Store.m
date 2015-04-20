//
//  Store.m
//  Inside The Box
//
//  Created by Ryan Cobelli on 11/24/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import "Store.h"

@interface Store ()

@end

@implementation Store

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create ScrollView for buttons
	[_Scroller setScrollEnabled:YES];
	[_Scroller setContentSize:CGSizeMake(320, 520)];
	
	// Get current count of gems
	gems = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"gems"];
	[self updateGems];
	
	// Update Interface
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"UI"] isEqualToString:@"night"]) {
		[_Gem15Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_15.png"] forState:UIControlStateNormal];
		[_Gem35Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_35.png"] forState:UIControlStateNormal];
		[_Gem75Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_75.png"] forState:UIControlStateNormal];
		[_Gem190Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_190.png"] forState:UIControlStateNormal];
		[_Gem285Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_285.png"] forState:UIControlStateNormal];
		[_Gem400Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_400.png"] forState:UIControlStateNormal];
		[_Gem500Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_500.png"] forState:UIControlStateNormal];
		[_Gem1250Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_1250.png"] forState:UIControlStateNormal];
		[_Gem2750Outlet setBackgroundImage:[UIImage imageNamed:@"night_store_2750.png"] forState:UIControlStateNormal];
		[_ExitOutlet setBackgroundImage:[UIImage imageNamed:@"night_store_exit.png"] forState:UIControlStateNormal];
		[_background setImage:[UIImage imageNamed:@"night_background.png"]];
		_gemCount.textColor = [UIColor whiteColor];
		_storeLabel.textColor = [UIColor whiteColor];
	}
	else {
		[_Gem15Outlet setBackgroundImage:[UIImage imageNamed:@"store_15.png"] forState:UIControlStateNormal];
		[_Gem35Outlet setBackgroundImage:[UIImage imageNamed:@"store_35.png"] forState:UIControlStateNormal];
		[_Gem75Outlet setBackgroundImage:[UIImage imageNamed:@"store_75.png"] forState:UIControlStateNormal];
		[_Gem190Outlet setBackgroundImage:[UIImage imageNamed:@"store_190.png"] forState:UIControlStateNormal];
		[_Gem285Outlet setBackgroundImage:[UIImage imageNamed:@"store_285.png"] forState:UIControlStateNormal];
		[_Gem400Outlet setBackgroundImage:[UIImage imageNamed:@"store_400.png"] forState:UIControlStateNormal];
		[_Gem500Outlet setBackgroundImage:[UIImage imageNamed:@"store_500.png"] forState:UIControlStateNormal];
		[_Gem1250Outlet setBackgroundImage:[UIImage imageNamed:@"store_1250.png"] forState:UIControlStateNormal];
		[_Gem2750Outlet setBackgroundImage:[UIImage imageNamed:@"store_2750.png"] forState:UIControlStateNormal];
		[_ExitOutlet setBackgroundImage:[UIImage imageNamed:@"store_exit.png"] forState:UIControlStateNormal];
		[_background setImage:[UIImage imageNamed:@"background.png"]];
		_gemCount.textColor = [UIColor blackColor];
		_storeLabel.textColor = [UIColor blackColor];
	}
	
	// Init StoreKit
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)updateGems {
	_gemCount.text = [NSString stringWithFormat:@"%i", gems];
	[[NSUserDefaults standardUserDefaults] setInteger:gems forKey:@"gems"];
}

-(void)requestProductData:(NSString *)identifier {
	NSSet *productIdentifiers = [NSSet setWithObject:[NSString stringWithFormat:@"com.rybel.IAP.%@", identifier]];
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	productsRequest.delegate = self;
	[productsRequest start];
}

#pragma mark - StoreKit

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	NSArray *products = response.products;
	purchaseProduct = [products count] == 1 ? [products firstObject] : nil;
	if (purchaseProduct) {
		NSLog(@"Store: Product title: %@" , purchaseProduct.localizedTitle);
		NSLog(@"Store: Product id: %@" , purchaseProduct.productIdentifier);
		SKProduct *product = purchaseProduct;
		SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	for (NSString *invalidProductId in response.invalidProductIdentifiers) {
		NSLog(@"Store: Invalid product id: %@" , invalidProductId);
	}
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
				NSLog(@"Store: Purchasing");
				break;
			case SKPaymentTransactionStateDeferred:
				NSLog(@"Store: Deferred");
				break;
			case SKPaymentTransactionStateFailed:
				NSLog(@"Store: Failed");
				break;
			case SKPaymentTransactionStatePurchased: {
				NSLog(@"Store: Purchased");
				[[SKPaymentQueue defaultQueue]finishTransaction:transaction];
				NSString* quantity = [[purchaseProduct.localizedTitle stringByReplacingOccurrencesOfString:@"Gems" withString:@""] stringByReplacingOccurrencesOfString:@" " withString: @""];
				gems = gems + (int)[quantity integerValue];
				[self updateGems];
				break;
			}
			case SKPaymentTransactionStateRestored:
				NSLog(@"Store: Restored");
				break;
			default:
				// For debugging
				NSLog(@"Store: Unexpected transaction state %@", @(transaction.transactionState));
				break;
		}
	}
}



#pragma mark - Buttons

-(IBAction)Gem15Action:(id)sender {
	[self requestProductData:@"gem_15"];
}

-(IBAction)Gem35Action:(id)sender {
	[self requestProductData:@"gem_35"];
}

-(IBAction)Gem75Action:(id)sender {
	[self requestProductData:@"gem_75"];
}

-(IBAction)Gem190Action:(id)sender {
	[self requestProductData:@"gem_190"];
}

-(IBAction)Gem285Action:(id)sender {
	[self requestProductData:@"gem_285"];
}

-(IBAction)Gem400Action:(id)sender {
	[self requestProductData:@"gem_400"];
}

-(IBAction)Gem500Action:(id)sender {
	[self requestProductData:@"gem_500"];
}

-(IBAction)Gem1250Action:(id)sender {
	[self requestProductData:@"gem_1250"];
}

-(IBAction)Gem2750Action:(id)sender {
	[self requestProductData:@"gem_2750"];
}

-(IBAction)ExitAction:(id)sender {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end