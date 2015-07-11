//
//  AppDelegate.m
//  openStory
//
//  Created by Brandon Phillips on 2/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeView.h"
#import "SignupView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"askForStory"];
    _didStartMonitoringRegion = FALSE;
    HomeView *home = [[HomeView alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:home];
    [navigationController setNavigationBarHidden:TRUE];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self.window setRootViewController:navigationController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if([CLLocationManager locationServicesEnabled]){
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized){
            cLocationManager = [[CLLocationManager alloc] init];
            cLocationManager.delegate = self;
            cLocationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
            cLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // 5 m
            lati = [NSString stringWithFormat:@"%f", cLocationManager.location.coordinate.latitude];
            longi = [NSString stringWithFormat:@"%f", cLocationManager.location.coordinate.longitude];
            [cLocationManager stopUpdatingLocation];
        }else{
        }
    }
    
    
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){ // PUSH NOTES ARE ENABLED
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        //[cLocationManager requestAlwaysAuthorization];
    }else{
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types == UIRemoteNotificationTypeAlert){ // PUSH NOTES ARE ENABLED
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
    }
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    
    // Test whether the receipt is present at the above path
    if(![[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]])
    {
        // Validation fails
        //exit(173);
    }
    
    return YES;
}

#pragma mark - Push Notification Methods

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{

	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

// NOT SURE WHAT THESE ARE HERE FOR.
-(void) askForLocation{
    
}

-(void) askForNotifications{
    
}

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
	/*NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You're getting a story"
                                                      message:alertValue
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
	//message.senderName = [parts objectAtIndex:0];
	[parts removeObjectAtIndex:0];
	//message.text = [parts componentsJoinedByString:@": "];*/
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations && [locations count] && !_didStartMonitoringRegion) {
        // Update Helper
        _didStartMonitoringRegion = YES;

        // Fetch Current Location
        CLLocation *location = [locations objectAtIndex:0];
        lati = [[NSString alloc] initWithFormat:@"%g", location.coordinate.latitude];
        longi = [[NSString alloc] initWithFormat:@"%g", location.coordinate.longitude];
        cLocation = location;
        [cLocationManager stopUpdatingLocation];
        
        NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/updatelocation.php?user=%@&lati=%@&longi=%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"],lati,longi];
        /*if (storyCheck == 1){
            fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/backgroundcheck.php?user=%@&lati=%@&longi=%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"],lati,longi];
        }*/
        
        NSURLSession *locationSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *locationTask = [locationSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                NSArray *fenceArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                for (NSDictionary *fence in fenceArray){
                    CLRegion *region = [self dictToRegion:fence];
                    [self.geofences addObject:region];
                    [cLocationManager startMonitoringForRegion:region];
                }
            });
        }];
        
        [locationTask resume];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    static BOOL firstTime=TRUE;
    if(firstTime)
    {
        firstTime = FALSE;
        NSSet * monitoredRegions = cLocationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             {
                 //NSString *identifer = region.identifier;
                 CLLocationCoordinate2D centerCoords =region.center;
                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                 CLLocationDistance radius = region.radius;
                 
                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                 if([currentLocationDistance floatValue] < radius)
                 {
                     
                     //stop Monitoring Region temporarily
                     [cLocationManager stopMonitoringForRegion:region];
                     
                     [self locationManager:cLocationManager didEnterRegion:region];
                     //start Monitoing Region again.
                     [cLocationManager startMonitoringForRegion:region];
                 }
             }];
        }
        //Stop Location Updation, we dont need it now.
        [cLocationManager stopUpdatingLocation];
        
    }
    
}

- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}

- (CLRegion*)dictToRegion:(NSDictionary*)dictionary
{
    NSString *identifier = [dictionary valueForKey:@"identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"distance"] doubleValue];
    
    if(regionRadius > cLocationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = cLocationManager.maximumRegionMonitoringDistance;
    }

    CLRegion * region =nil;

        region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:regionRadius
                                                identifier:identifier];
    
    return  region;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    NSMutableArray *arrayOfStoryIds = [[NSMutableArray alloc]init];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"pushnoteStories"]){
        arrayOfStoryIds = [[NSUserDefaults standardUserDefaults]objectForKey:@"pushnoteStories"];
    }
    
    if ([arrayOfStoryIds containsObject:region.identifier]){

    }else{

    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/enterregion.php?user=%@&sid=%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"],region.identifier];
    NSURLSession *enterRegionSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *enterRegionTask = [enterRegionSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [arrayOfStoryIds addObject:region.identifier];
            [[NSUserDefaults standardUserDefaults] setObject:region.identifier forKey:@"pushnoteStories"];
            
        });
    }];
    
    [enterRegionTask resume];
        
    }
    
    /*UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"You're getting a story"
                                                      message:@"alert"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];*/
}


-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/exitregion.php?user=%@&sid=%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"],region.identifier];
    NSURLSession *exitRegionSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *exitRegionTask = [exitRegionSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
        });
    }];
    
    [exitRegionTask resume];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    
    NSString *tokenString = [deviceToken description];
    
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(tokenString){

            if([[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
            NSData *sendtoken = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/sendtoken.php?token=%@&id=%@", tokenString, [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]]];
            if(sendtoken){
                //TOKEN SENT.
            }
            }
        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{

    }
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - App Starup Methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /*if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
        if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
            UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
            
            __block UIBackgroundTaskIdentifier background_task; //Create a task object
            
            background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                [application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
                background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
                
                //System will be shutting down the app at any point in time now
            }];
            
            
            //Background tasks require you to use asyncrous tasks
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //Perform your tasks that your application requires
                
                NSLog(@"\n\nRunning in the background!\n\n");
                
                NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(bgTimerCalled) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
                [[NSRunLoop currentRunLoop] run];
                
                [application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
                background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
            });
        }
    }*/
}

/*-(void)bgTimerCalled
{
    [cLocationManager startUpdatingLocation];
    storyCheck = 1;
    NSLog(@"updating location");
    // Your Code
}*/

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.backgroundTimer invalidate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.backgroundTimer invalidate];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
