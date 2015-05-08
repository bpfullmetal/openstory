//
//  LoadingView.m
//  openStory
//
//  Created by Brandon Phillips on 4/19/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *loadingCover = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        loadingCover.backgroundColor = [UIColor blackColor];
        loadingCover.alpha = 0.8;
        
        UIView *loadingBox = [[UIView alloc]initWithFrame:CGRectMake(100, [[UIScreen mainScreen] bounds].size.height/2 - 70, 120, 140)];
        loadingBox.backgroundColor = [UIColor whiteColor];
        loadingBox.alpha = 0.8;
        
        self.spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, [[UIScreen mainScreen] bounds].size.height/2 - 30, 20, 20)];
        self.spinner.color = [UIColor whiteColor];
        
        loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2, 320, 30)];
        loadingLabel.text = self.loadingmessage;
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.textColor = [UIColor whiteColor];
        [loadingLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        
        
        [self addSubview:loadingCover];
        //[self insertSubview:loadingBox aboveSubview:loadingCover];
        [self insertSubview:self.spinner aboveSubview:loadingBox];
        [self insertSubview:loadingLabel aboveSubview:loadingBox];
    }
    return self;
}

- (void)loadingmessage:(NSString *)loadingmessage{
    loadingLabel.text = loadingmessage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
