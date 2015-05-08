//
//  AppDelegate.h
//  openStory
//
//  Created by Brandon Phillips on 2/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NSString *lati;
NSString *longi;
NSString *selectedStory;
NSString *selectedChapter;
NSString *selectedUser;
NSString *selectedChapterOrder;
NSArray *chapterArray;
NSArray *pullStoryArray;
NSArray *likesArray;
NSString *mapStoryName;
NSArray *mapStory;
CLLocationManager *cLocationManager;
CLLocation *cLocation;
NSTimer *backgroundTimer;
BOOL _didStartMonitoringRegion;

int storyCheck;


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSTimer *backgroundTimer;
@property (strong, nonatomic) NSMutableArray *geofences;

- (void)askForLocation;
- (void)askForNotifications;

@end
