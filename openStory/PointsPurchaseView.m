//
//  PointsPurchaseView.m
//  openStory
//
//  Created by Brandon Phillips on 6/3/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "PointsPurchaseView.h"

@interface PointsPurchaseView ()

@end

@implementation PointsPurchaseView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (IBAction)closePurchaseView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)purchase1000:(id)sender {
    
    self.pointsID =
    @"1000PTS99C";
    
    [makePurchase getProductInfo:self.pointsID productType:1];
}

- (IBAction)purchase5000:(id)sender {
    
    self.pointsID =
    @"5000PTS399C";
    
    [makePurchase getProductInfo:self.pointsID productType:1];
}

- (IBAction)purchase12000:(id)sender {
    
    self.pointsID =
    @"12000PTS999C";
    
    [makePurchase getProductInfo:self.pointsID productType:1];
}

- (IBAction)purchase25000:(id)sender {
    
    self.pointsID =
    @"25000PTS1999C";
    
    [makePurchase getProductInfo:self.pointsID productType:1];
}


/*-(void)getProductInfo
{
    
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:self.pointsID]];
        request.delegate = self;
        
        [request start];
    }
    else
        NSLog(@"%@", @"Please enable In App Purchase in Settings");
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
                                                              message:[NSString stringWithFormat:@"The points purchase package: %@ is currently unavailable. Check back soon!", product.productIdentifier]
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles: nil];
        [unavailable show];
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self addPoints];
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue]
                 finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

- (void)addPoints{
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
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertView *pointsAdded = [[UIAlertView alloc] initWithTitle:Nil
                                                                message:[NSString stringWithFormat: @"%@ points have been added!", pointsToAdd]
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles: nil];
            [pointsAdded show];
            
            
        });
    }];
    
    [addPointsTask resume];
}*/

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    makePurchase = [[PurchaseItem alloc]init];
    pointsDescriptionBox.layoutManager.delegate = self;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closePurchaseView:)
                                                 name:@"pointsPurchased" object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
