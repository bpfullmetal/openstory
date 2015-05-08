//
//  StoryPin.h
//  openStory
//
//  Created by Brandon Phillips on 3/16/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StoryPin : MKAnnotationView<MKAnnotation>

@property (strong, nonatomic) NSString *subTitle;
@property (strong, nonatomic) NSString *titleLabel;
@property (strong, nonatomic) NSString *descriptionLabel;
@property (strong, nonatomic) NSString *debugDescriptionLabel;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *)genre storyId: (NSString *)storyId user:(NSString *)userId;
//- (MKAnnotationView *)annotationView;
@end
