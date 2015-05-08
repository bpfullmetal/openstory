//
//  PurchaseItem.m
//  openStory
//
//  Created by Brandon Phillips on 7/14/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "PurchaseItem.h"

@implementation PurchaseItem

-(void)getProductInfo:(NSString *)productId productType:(int)type
{
    [[SKPaymentQueue defaultQueue]
     addTransactionObserver:self];
    productType = type;
    
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:productId]];
        request.delegate = self;
        
        [request start];
    }
    else
        NSLog(@"%@", @"Please enable In App Purchase in Settings");
}

- (void)restorePreviousPurchases{
    [[SKPaymentQueue defaultQueue]
     addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}// Call This Function

//Then this delegate Function Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
        [self addFeature:productID restorestatus:1];
    }
    if (purchasedItemIDs.count == 0){
        UIAlertView *unavailable = [[UIAlertView alloc] initWithTitle:Nil
                                                              message: @"you have no purchases to restore"
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles: nil];
        [unavailable show];
    }
    NSLog(@"purchasedItemIds: %@", purchasedItemIDs);
}



-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"errrrrror");
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        _pointsproduct = products[0];
        NSLog(@"product found %@", _pointsproduct.productIdentifier);
        SKPayment *payment = [SKPayment paymentWithProduct:_pointsproduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        // _product = products[0];
        // _buyButton.enabled = YES;
        // _productTitle.text = _product.localizedTitle;
        // _productDescription.text = _product.localizedDescription;
    } else {
        // _productTitle.text = @"Product not found";
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        
        UIAlertView *unavailable = [[UIAlertView alloc] initWithTitle:Nil
                                                              message:[NSString stringWithFormat:@"The item: %@ is currently unavailable. Check back soon!", product.productIdentifier]
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles: nil];
        [unavailable show];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"transactions: %@", transactions);
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self addPoints];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
               
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction Restored: %@", transaction);
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
            
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction Restored: %@", transaction);
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction Failed: %@", transaction);
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

- (void)addPoints{
    
    if (productType == 1){
    NSString *pointsToAdd = [[NSString alloc]init];
    if ([_pointsproduct.productIdentifier isEqualToString:@"1000PTS99C"]){
        pointsToAdd = @"1000";
    }else if ([_pointsproduct.productIdentifier isEqualToString:@"5000PTS399C"]){
        pointsToAdd = @"5000";
    }else if ([_pointsproduct.productIdentifier isEqualToString:@"12000PTS999C"]){
        pointsToAdd = @"12000";
    }else if([_pointsproduct.productIdentifier isEqualToString:@"25000PTS1999C"]){
        pointsToAdd = @"25000";
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
    NSString *post = [NSString stringWithFormat: @"quantity=%@&user=%@", pointsToAdd, userId];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/addpoints.php";
    
    NSMutableURLRequest *addPointsRequest = [[NSMutableURLRequest alloc] init];
    [addPointsRequest setURL:[NSURL URLWithString:fullURL]];
    [addPointsRequest setHTTPMethod:@"POST"];
    [addPointsRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [addPointsRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [addPointsRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *addPointsSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *addPointsTask = [addPointsSession dataTaskWithRequest:addPointsRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"datastring %@", datastring);
        
            
            UIAlertView *pointsAdded = [[UIAlertView alloc] initWithTitle:Nil
                                                                  message:[NSString stringWithFormat: @"%@ points have been added!", pointsToAdd]
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles: nil];
            [pointsAdded show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pointsPurchased" object:self];
            
            
        });
    }];
    
    [addPointsTask resume];
    }else if (productType == 2){
        [self addFeature:_pointsproduct.productIdentifier restorestatus:0];
    }
}

- (void)addFeature: (NSString *)productIdent restorestatus:(int)status{
    NSLog(@"adding feature");
    NSString *post = [NSString stringWithFormat: @"uid=%@&fid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"], productIdent];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/addfeature.php";
    
    NSMutableURLRequest *addFeatureRequest = [[NSMutableURLRequest alloc] init];
    [addFeatureRequest setURL:[NSURL URLWithString:fullURL]];
    [addFeatureRequest setHTTPMethod:@"POST"];
    [addFeatureRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [addFeatureRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [addFeatureRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *addFeatureSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *addFeatureTask = [addFeatureSession dataTaskWithRequest:addFeatureRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"datastring %@", datastring);
            
            if ([datastring intValue] == 1){
                NSMutableArray *features = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"]];
                //features = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
                [features addObject:productIdent];
                
                NSLog(@"map unlocked");
                [[NSUserDefaults standardUserDefaults]setObject:features forKey:@"allFeatures"];
                if (status == 0){
                [[NSNotificationCenter defaultCenter] postNotificationName:productIdent object:self];
                }else{
                    NSString *message = [[NSString alloc]init];
                    if ([productIdent isEqualToString:@"UNLOCKMAP99"]){
                        message = @"Your map access has been restored";
                    }else if ([productIdent isEqualToString:@"UNLOCKUSERSTORIES99"]){
                        message = @"access to other members stories has been restored";
                    }else if([productIdent isEqualToString:@"UNLOCKCLOSED99"]){
                        message = @"ability to write 'closed stories' has been restored";
                    }
                    UIAlertView *restored = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message: message
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles: nil];
                    [restored show];
                }
            }
        });
    }];
    
    [addFeatureTask resume];
}

@end
