//
//  Tutorial.h
//  openStory
//
//  Created by Brandon Phillips on 7/8/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Tutorial : UIViewController<MPMediaPlayback, MPPlayableContentDataSource, MPPlayableContentDelegate>{

    float screenHeight;
    float screenWidth;
    NSTimer *timer;
    UIButton *skipButton;
    
}

@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) IBOutlet UIView *movie;
@property (nonatomic, strong) IBOutlet UILabel *tutorialCaption;

@end
