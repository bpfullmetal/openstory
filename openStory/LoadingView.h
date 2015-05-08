//
//  LoadingView.h
//  openStory
//
//  Created by Brandon Phillips on 4/19/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView{
    UILabel *loadingLabel;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, weak) NSString *loadingmessage;

- (void)loadingmessage:(NSString *)loadingmessage;

@end
