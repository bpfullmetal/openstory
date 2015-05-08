//
//  DailyStory.h
//  openStory
//
//  Created by Brandon Phillips on 4/11/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartStory.h"
#import "LoadingView.h"
#import "LikesView.h"
#import "ProfileView.h"

@interface DailyStory : UIViewController <NSURLSessionTaskDelegate, UIScrollViewDelegate, UITextViewDelegate, NSLayoutManagerDelegate>{

    ProfileView *userProfile;
    LoadingView *loader;
    StartStory *startStoryView;
    LikesView *likesBox;
    int dailyStoryType;
    
    NSDictionary *profileItem;
    
    NSArray *winnersArray;
    NSArray *currentArray;
    NSArray *todaysArray;
    float screenHeight;
    float screenWidth;

    IBOutlet UIScrollView *dailyScroll;
    IBOutlet UIView *dailyScrollView;
    
    IBOutlet UIView *profileBox;
    IBOutlet UIView *profileBoxCover;
    
    
    // SCROLL ONE:
    
    IBOutlet UITextView *promptView;
    IBOutlet UIView *dailyScrollOne;
    
    
    // SCROLL TWO:
    
    IBOutlet UIView *dailyScrollTwo;
    IBOutlet UILabel *authorUsername;
    IBOutlet UIImageView *authorImage;
    IBOutlet UILabel *storyNameLabel;
    IBOutlet UITextView *chapterTextBox;
    
    IBOutlet UIButton *prevWinnerButton;
    IBOutlet UIButton *nextWinnerButton;
    IBOutlet UIButton *nextButton;
    
    IBOutlet UIButton *profileButton;
    
    // SCROLL THREE:
    
    IBOutlet UIView *dailyScrollThree;
    IBOutlet UILabel *subAuthorUsername;
    IBOutlet UIImageView *subAuthorImage;
    IBOutlet UILabel *subStoryNameLabel;
    IBOutlet UITextView *subChapterTextBox;
    
    IBOutlet UIButton *reportChapter;
    IBOutlet UIButton *reportChapterOne;
    UITextField *reportField;
    IBOutlet UIButton *subNextSubmissionButton;
    
    IBOutlet UIButton *subProfileButton;
}

// SCROLL ONE:

- (IBAction)goToWebsite:(id)sender;
- (IBAction)writeDaily:(id)sender;
- (IBAction)getWinners:(id)sender;
- (IBAction)allSubmissions:(id)sender;

// SCROLL TWO:

- (IBAction)prevWinner:(id)sender;
- (IBAction)nextWinner:(id)sender;
- (IBAction)closeWinners:(id)sender;

// SCROLL THREE:

- (IBAction)closeSubmissions:(id)sender;
- (IBAction)closeDaily:(id)sender;
- (IBAction)reportStory:(id)sender;

@end
