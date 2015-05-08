//
//  StartStory.h
//  openStory
//
//  Created by Brandon Phillips on 2/7/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenreCell.h"
#import "LoadingView.h"
#import "PurchaseItem.h"
#import <Social/Social.h>
#import <Canvas.h>
#import <CSAnimation.h>

@interface StartStory : UIViewController<UITextViewDelegate, NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, UIScrollViewDelegate, NSURLSessionDownloadDelegate, UITableViewDataSource, UITableViewDelegate, NSLayoutManagerDelegate>{
    
    LoadingView *loader;
    PurchaseItem *purchase;
    
    float screenWidth;
    float screenHeight;
    
    NSTimer *timer;
    int openoption;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollContent;
    IBOutlet UIView *editView;
    IBOutlet UIView *genreView;
    IBOutlet UILabel *startStoryLabel;
    IBOutlet UIView *genreGradientBox;
    
    IBOutlet UILabel *sTitleAlert;
    IBOutlet UILabel *cTitleAlert;
    IBOutlet UILabel *cLengthAlert;
    IBOutlet UILabel *cLimitAlert;
    
    IBOutlet UIButton *featuredPromptButton;
    
    IBOutlet UIButton *finishStoryButton;
    IBOutlet UIButton *submitStoryButton;
    
    NSString *selectedGenre;
    NSArray *genreArray;
    GenreCell *genreRow;
    
    NSString *receivedStoryId;
    
    
    IBOutlet CSAnimationView *tweetFinished;
}

@property (nonatomic, weak) IBOutlet UITextView *storyBox;
@property (nonatomic, weak) IBOutlet UITextField *chapterTitle;
@property (nonatomic, weak) IBOutlet UITextField *storyTitle;
@property (nonatomic, weak) IBOutlet UISegmentedControl *openSelect;
@property (nonatomic, weak) IBOutlet UITableView *genreTable;

- (IBAction)finishStory:(id)sender;
- (IBAction)submitStory:(id)sender;
- (IBAction)segmentedChartButtonChanged:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)home:(id)sender;
- (IBAction)showPrompt:(id)sender;

//-(void)appendText: (NSString *)storyText;

@end
