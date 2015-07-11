//
//  Tutorial.m
//  openStory
//
//  Created by Brandon Phillips on 7/8/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "Tutorial.h"

@interface Tutorial ()

@end

@implementation Tutorial

- (void)prepareToPlay{
    
}
- (void)stop{
    [timer invalidate];
}

- (void)play{
    [self startTimer];
}

- (void)pause{
    [timer invalidate];
}

- (void)beginSeekingForward{
    
}

- (void)beginSeekingBackward{
    
}

- (void)endSeeking{
    
}
- (MPContentItem *)contentItemAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}
- (NSInteger)numberOfChildItemsAtIndexPath:(NSIndexPath *)indexPath{
    return 0;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [_player stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    NSLog(@"width: %f, height: %f", screenWidth, screenHeight);
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://fullmetalworkshop.com/openstory/OpenStoryTutorialMobile.mp4"];
    _player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    //_player.view.backgroundColor = [UIColor clearColor];
    [[_player view] setFrame:CGRectMake((screenWidth/2)- (((screenHeight/4)*3)/2), (screenHeight/4)+20, ((screenHeight/4)*3), ((screenHeight/4)*3)*9/16)];
    [[_player view] setTransform:CGAffineTransformMakeRotation(M_PI / -2)];
    [self.view addSubview:_player.view];
    
    [_player play];
    [self startTimer];
    
    self.tutorialCaption = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - (screenHeight/2)-20, (screenHeight/2)-15, screenHeight, 30)];
    self.tutorialCaption.transform = CGAffineTransformMakeRotation(M_PI / -2);
    [self.view addSubview:self.tutorialCaption];
    self.tutorialCaption.text = @"Here's how you get started";
    self.tutorialCaption.textAlignment = NSTextAlignmentCenter;
    self.tutorialCaption.font = [UIFont fontWithName:@"Heiti SC" size:16.0];
    self.tutorialCaption.textColor = [UIColor whiteColor];
    
    skipButton = [[UIButton alloc]initWithFrame:CGRectMake(-30, 40, 100, 30)];
    skipButton.transform = CGAffineTransformMakeRotation(M_PI / -2);
    [skipButton setTitle:@"SKIP TUTORIAL" forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:13.0];
    skipButton.titleLabel.textColor = [UIColor whiteColor];
    [skipButton addTarget:self
                    action:@selector(skipTutorial:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:_player];

    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)skipTutorial:(id)sender{
    [[NSUserDefaults standardUserDefaults]setObject:@"read" forKey:@"readTutorial"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)videoFinished{
    [[NSUserDefaults standardUserDefaults]setObject:@"read" forKey:@"readTutorial"];
    [skipButton setTitle:@"START" forState:UIControlStateNormal];
}

- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
}

-(void)timerCalled
{
    float playbackTime = _player.currentPlaybackTime;
    if (playbackTime > 3 && playbackTime < 9){
        self.tutorialCaption.text = @"provide a username and password";
    }
    if (playbackTime >= 14 && playbackTime < 27){
        self.tutorialCaption.text = @"select your favorite genres";
    }
    if (playbackTime >= 34 && playbackTime < 41){
        self.tutorialCaption.text = @"choose a photo for your profile";
    }
    if (playbackTime >= 43 && playbackTime < 47){
        self.tutorialCaption.text = @"connect your twitter account";
    }
    if (playbackTime >= 60 && playbackTime < 64){
        self.tutorialCaption.text = @"welcome to your homescreen";
    }
    if (playbackTime >= 65 && playbackTime < 70){
        self.tutorialCaption.text = @"use settings menu to edit your profile";
    }
    if (playbackTime >= 71 && playbackTime < 76){
        self.tutorialCaption.text = @"also view tutorial and terms";
    }
    if (playbackTime >= 80 && playbackTime < 88){
        self.tutorialCaption.text = @"write to a daily prompt";
    }
    if (playbackTime >= 89 && playbackTime < 93){
        self.tutorialCaption.text = @"view today's daily stories";
    }
    if (playbackTime >= 94 && playbackTime < 99){
        self.tutorialCaption.text = @"tap icon to give an award";
    }
    if (playbackTime >= 105 && playbackTime < 113){
        self.tutorialCaption.text = @"view yesterday's winners";
    }
    if (playbackTime >= 119 && playbackTime < 130){
        self.tutorialCaption.text = @"write and submit your own story";
    }
    if (playbackTime >= 135 && playbackTime < 145){
        self.tutorialCaption.text = @"watch for nearby stories";
    }
    if (playbackTime >= 152 && playbackTime < 164){
        self.tutorialCaption.text = @"see all stories in user library";
    }
    if (playbackTime >= 166 && playbackTime < 171){
        self.tutorialCaption.text = @"have fun and get started!";
    }
    if (playbackTime >= 172 && playbackTime < 180){
        self.tutorialCaption.text = @"thanks for watching!";
    }
    // Your Code
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
