//
//  MapStories.h
//  openStory
//
//  Created by Brandon Phillips on 3/16/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapStories : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>{
    
    MKUserLocation *currentLocation;
    CLGeocoder *storyPointCreator;
    NSMutableArray *arrayOfAnnotations;
    NSMutableArray *arrayOfNewAnnotations;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
