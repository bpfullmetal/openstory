//
//  PointsPurchaseView.h
//  openStory
//
//  Created by Brandon Phillips on 6/3/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "PurchaseItem.h"

@interface PointsPurchaseView : UIViewController<NSLayoutManagerDelegate, UITextViewDelegate, NSURLSessionDelegate, UIAlertViewDelegate>{
    IBOutlet UITextView *pointsDescriptionBox;
    PurchaseItem *makePurchase;
}

//@property (strong, nonatomic) SKProduct *pointsproduct;
@property (strong, nonatomic) NSString *pointsID;


- (IBAction)closePurchaseView:(id)sender;

- (IBAction)purchase1000:(id)sender;
- (IBAction)purchase5000:(id)sender;
- (IBAction)purchase12000:(id)sender;
- (IBAction)purchase25000:(id)sender;

@end
