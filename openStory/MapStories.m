//
//  MapStories.m
//  openStory
//
//  Created by Brandon Phillips on 3/16/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "MapStories.h"
#import "AppDelegate.h"
#import "StoryPin.h"

#define METERS_PER_MILE 1609.344

@interface MapStories ()

@end

@implementation MapStories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D userCLoc = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude);
    [self getLocations:userCLoc];

}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:
(MKUserLocation *)userLocation
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    /*_mapView.centerCoordinate =
    userLocation.location.coordinate;
    currentLocation = userLocation;
    NSLog(@"got location");*/
    //NSLog(@"user lat: %f long: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)getLocations:(CLLocationCoordinate2D)mapLocation{
    //[self.mapView removeAnnotations:[self.mapView annotations]];
    
    [arrayOfNewAnnotations removeAllObjects];
    [arrayOfAnnotations removeAllObjects];
    NSString *locLat = [NSString stringWithFormat:@"%f", mapLocation.latitude];
    NSString *locLong = [NSString stringWithFormat:@"%f", mapLocation.longitude];
    NSURLSession *locationsSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *locationsTask = [locationsSession dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getstoryloc.php?lati=%@&longi=%@", locLat, locLong]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *chapterText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"location data: %@", datastring);
            NSError *error = nil;
            NSArray *storyLocationArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            for(NSDictionary *item in storyLocationArray){
                CLLocationCoordinate2D storyCoord = CLLocationCoordinate2DMake([[item objectForKey:@"lat"] floatValue], [[item objectForKey:@"lon"] floatValue]);
                NSString *genreTitle = [item objectForKey:@"genre"];
                NSString *storyTitle = [item objectForKey:@"title"];
                NSString *storyId = [item objectForKey:@"sid"];
                NSString *storyUser = [item objectForKey:@"user"];
                [self addStoryToMap:storyCoord storyGenre:genreTitle storyTitle:storyTitle storyId: storyId userId: storyUser];
                
            }
            NSLog(@"new annotations: %@", arrayOfNewAnnotations);
            [self.mapView addAnnotations:arrayOfAnnotations];
            
        });
    }];
    [locationsTask resume];
}

- (void)addStoryToMap:(CLLocationCoordinate2D)coord storyGenre:(NSString *)genre storyTitle:(NSString *)Stitle storyId:(NSString *)storyId userId:(NSString *)userId{
    StoryPin *StoryAnnotationView = [[StoryPin alloc] initWithCoordinate:coord title:Stitle subTitle:genre storyId:storyId user:userId];
    [arrayOfNewAnnotations addObject:StoryAnnotationView];
    BOOL pinExists = false;
    for (StoryPin *sPin in [self.mapView annotations]){
        if ( [sPin.title isEqualToString:Stitle] &&  sPin.coordinate.latitude == coord.latitude  && sPin.coordinate.longitude == coord.longitude){
            pinExists = true;
        }
    }
    if (pinExists == false){
        [arrayOfAnnotations addObject:StoryAnnotationView];
    }else{

    }
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if (annotation == mapView.userLocation){
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userIcon"];
        customPinView.image = [UIImage imageNamed:@"placeHolder.png"];
        CGRect storyIconBox = CGRectMake(0, 0, 160, 160);
        UIImage *storyIconImage = [UIImage imageNamed:@"userIcon.png"];
        
        UIGraphicsBeginImageContext(storyIconBox.size);
        [storyIconImage drawInRect:storyIconBox];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        customPinView.canShowCallout = NO;
        customPinView.image = resizedImage;
        return customPinView;
    }else{
        
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userIcon"];
        
        UIButton* aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [aButton setBackgroundImage:[UIImage imageNamed:@"mapButton.png"] forState:UIControlStateNormal];
        [aButton setTag:[[annotation description] intValue]];
        customPinView.rightCalloutAccessoryView = aButton;
        
        CGRect storyIconBox = CGRectMake(0, 0, 45, 45);
        UIImage *storyIconImage = [UIImage imageNamed:@"storyIcon.png"];
        
        UIGraphicsBeginImageContext(storyIconBox.size);
        [storyIconImage drawInRect:storyIconBox];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        customPinView.canShowCallout = YES;
        customPinView.image = resizedImage;
        return customPinView;
        
    }
    /*if([annotation isKindOfClass:[StoryPin class]]){
        
        StoryPin *storyLocation = (StoryPin *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"StoryPin"];
        
        if(annotationView == nil)
            annotationView = storyLocation.annotationView;
        else
            annotationView.annotation = annotation;
            return annotationView;
        
    }else
        return nil;*/
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    selectedStory = [NSString stringWithFormat:@"%d", (int)control.tag];
    selectedUser = [view.annotation debugDescription];
    mapStoryName = [view.annotation title];
    NSLog(@"selected user: %@", selectedUser);
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mapStoryChosen" object:self];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView * annView in views) {
        if (annView.annotation == mapView.userLocation) {
            [[annView superview] sendSubviewToBack:annView];
            annView.canShowCallout = NO;
        } else {
            [[annView superview] bringSubviewToFront:annView];
        }
    }
    
}

- (IBAction)closeMap:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)orientMap:(id)sender{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [cLocationManager startUpdatingLocation];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self getLocations:cLocationManager.location.coordinate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrayOfNewAnnotations = [[NSMutableArray alloc]init];
    arrayOfAnnotations = [[NSMutableArray alloc]init];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    self.mapView.rotateEnabled = NO;
    //NSLog(@"user location: %f", _mapView.userLocation.location.coordinate.latitude);
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        cLocation.coordinate, 2000, 2000);
    [_mapView setRegion:region animated:YES];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    //7
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    //8
    static NSString *identifier = @"StoryAnnotation";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        //9
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }else {
        annotationView.annotation = annotation;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
        annotationView.animatesDrop = TRUE;
        annotationView.canShowCallout = YES;
        annotationView.calloutOffset = CGPointMake(-5, 5);
        [annotationView addSubview:imageView];
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}*/

@end
