//
//  PurchaseItem.h
//  openStory
//
//  Created by Brandon Phillips on 7/14/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface PurchaseItem : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate, NSURLSessionDelegate>{
    int productType;
    NSMutableArray *purchasedItemIDs;
}

-(void)getProductInfo:(NSString *)productId productType:(int)type;
-(void)restorePreviousPurchases;

@property (strong, nonatomic) SKProduct *pointsproduct;
@property (strong, nonatomic) NSString *pointsID;

@end
