//
//  Store.h
//  Inside The Box
//
//  Created by Ryan Cobelli on 11/24/14.
//  Copyright (c) 2014 Rybel LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NSMutableArray *purchases;

#import <StoreKit/StoreKit.h>


int gems;

@interface Store : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {

	SKProduct *purchaseProduct;
	SKProductsRequest *productsRequest;
}
@property (strong, nonatomic) IBOutlet UIScrollView *Scroller;

@property (strong, nonatomic) IBOutlet UIButton *Gem15Outlet;
- (IBAction)Gem15Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem35Outlet;
- (IBAction)Gem35Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem75Outlet;
- (IBAction)Gem75Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem190Outlet;
- (IBAction)Gem190Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem285Outlet;
- (IBAction)Gem285Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem400Outlet;
- (IBAction)Gem400Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem500Outlet;
- (IBAction)Gem500Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem1250Outlet;
- (IBAction)Gem1250Action:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *Gem2750Outlet;
- (IBAction)Gem2750Action:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *ExitOutlet;
- (IBAction)ExitAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *background;

@property (strong, nonatomic) IBOutlet UILabel *gemCount;


@end