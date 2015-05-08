//
//  AddChapter.h
//  openStory
//
//  Created by Brandon Phillips on 2/17/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "ChapterRow.h"
#import "LikesView.h"
#import "ProfileView.h"
#import <Canvas.h>
#import <CSAnimation.h>
#import <Social/Social.h>

@interface AddChapter : UIViewController<NSLayoutManagerDelegate, UITextViewDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    
    float screenWidth;
    float screenHeight;
    
    IBOutlet UIView *addChapterView;
    IBOutlet UIButton *showHideButton;
    IBOutlet UIButton *addButton;
    
    IBOutlet UIView *profileBoxView;
    
    ProfileView *userProfile;
    LikesView *likesBox;
    ChapterRow *chapRow;
    LoadingView *loader;
    NSString *userID;
    NSTimer *timer;
    IBOutlet UILabel *chapNum;
    IBOutlet UILabel *startChapterLabel;
    IBOutlet UIButton *finishChapterButton;
    
    IBOutlet UILabel *cTitleAlert;
    IBOutlet UILabel *cLengthAlert;
    IBOutlet UILabel *cLimitAlert;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollContent;
    IBOutlet UIView *tableMaskView;
    
    UITextField *reportField;
    IBOutlet UIButton *reportChapter;
    
    IBOutlet UITextView *chapterTextBox;
    IBOutlet UILabel *chapterNameLabel;
    IBOutlet UIView *chapterTextView;
    IBOutlet UILabel *storyNameLabel;
    
    IBOutlet UIButton *skipStoryButton;
    
    IBOutlet CSAnimationView *tweetView;
}

- (IBAction)submitChapter:(id)sender;
- (IBAction)reportStory:(id)sender;

@property (nonatomic, weak) IBOutlet UITextView *chapterBox;
@property (nonatomic, weak) IBOutlet UITextField *chapterTitleField;
@property (nonatomic, weak) IBOutlet UILabel *storyTitle;
@property (nonatomic, weak) IBOutlet UITableView *tableOfContents;

//-(void)setChapterOrder: (int)order;

@end
