//
//  StoryPin.m
//  openStory
//
//  Created by Brandon Phillips on 3/16/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "StoryPin.h"

@implementation StoryPin

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *)genre storyId:(NSString *)storyId user:(NSString *)userId {
    if ((self = [super init])) {
        self.coordinate =coordinate;
        self.titleLabel = title;
        self.subTitle = genre;
        self.descriptionLabel = storyId;
        self.debugDescriptionLabel = userId;
        
    }
    return self;
}

- (NSString *)subtitle {
    return self.subTitle;
}

- (NSString *)title {
    return self.titleLabel;
}
- (NSString *)description {
    return self.descriptionLabel;
}
- (NSString *)debugDescription {
    return self.debugDescriptionLabel;
}

/*- (MKAnnotationView *)annotationView{
    NSLog(@"annotation view title: %@", self.class);
    
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:(id)self reuseIdentifier:@"StoryPin"];
    
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"x.png"];
    

    return annotationView;
}*/


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
