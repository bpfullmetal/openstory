//
//  HomeView.h
//  openStory
//
//  Created by Brandon Phillips on 2/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartStory.h"
#import "AddChapter.h"
#import "ChapterRow.h"
#import "FeedRow.h"
#import "SignupView.h"
#import "Settings.h"
#import "MapStories.h"
#import "DailyStory.h"
#import "LoadingView.h"
#import "LikesView.h"
#import "PointsPurchaseView.h"
#import "Tutorial.h"
#import "ProfileView.h"
#import "LikesView.h"
#import "TermsView.h"
#import "PurchaseItem.h"
#import "Canvas.h"


@interface HomeView : UIViewController <NSLayoutManagerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate,  UIDocumentInteractionControllerDelegate>{
    
    UIDocumentInteractionController *docController;
    float screenHeight;
    float screenWidth;
    
    int loadMapStorySwitch;
    int typeSwitch;
    
    NSString *userID;
    
    NSDictionary *profileItem;
    PurchaseItem *purchase;
    TermsView *termsAndConditions;
    Tutorial *tutorial;
    LoadingView *loader;
    DailyStory *dailyStoryView;
    MapStories *mapView;
    SignupView *signup;
    UIImagePickerController *imagePicker;
    ChapterRow *chapRow;
    FeedRow *feedRow;
    StartStory *startStoryView;
    AddChapter *addChapterView;
    Settings *settingsView;
    PointsPurchaseView *pointsView;
    ProfileView *userProfile;
    
    int storyswitch;
    
    //CLLocationManager *locationManager;
    
    NSArray *storyArray;
    NSArray *currentStoryArray;
    NSArray *winnersArray;
    
    NSMutableArray *yourArray;
    NSMutableArray *closedArray;
    NSMutableArray *yourFeaturedArray;
    NSMutableArray *contributedArray;
    
    UIView *storyScrollContent;

    IBOutlet UIScrollView *scrollView;
    IBOutlet UIScrollView *storyScrollView;
    IBOutlet UIView *scrollContent;
    int chapterCount;
    IBOutlet UIView *tableMaskView;
    IBOutlet UIView *feedMaskView;
    IBOutlet UITextView *chapterTextBox;
    IBOutlet UIButton *startStoryButton;
    IBOutlet UIButton *mapButton;
   
    
    int checkWeatherCount;
    
    // START STORY VIEW
    
    IBOutlet UIView *profileBoxView;
    IBOutlet UIView *colorBox;
    IBOutlet UIButton *buyButton;
    IBOutlet UIButton *pdfButton;
    IBOutlet UIButton *publishStory;
    
    // FEED VIEW
    
    IBOutlet UIView *feedView;
    
    // HOME VIEW
    int allStoriesLoadType;
    IBOutlet UIView *homeView;
    IBOutlet UIButton *storyCheck;
    IBOutlet UIButton *gotStory;
    IBOutlet UIButton *allStories;
    int checkAtStart;
    IBOutlet UIButton *pointCount;
    IBOutlet UIButton *pointLabel;
    
    // AUTHOR VIEW
    IBOutlet UIView *authorView;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *storyNameLabel;
    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *addUserPhoto;
    IBOutlet UIView *storyScrollBox;
    IBOutlet UILabel *storyType;
    IBOutlet UIImageView *userProfileImage;
    IBOutlet UILabel *userProfileUsernameLabel;
    
    // CHAPTER VIEW
    IBOutlet UIView *tableOfContentsView;
    NSString *deleteChapterId;
    IBOutlet UILabel *chapterNameLabel;
    IBOutlet UIButton *reportChapter;
    UITextField *reportField;
    LikesView *likesBox;
    IBOutlet UIView *chapterTextView;
    UIButton *deleteButton;
    
    // ASK FOR LOCATION
}

- (IBAction)dailyStory:(id)sender;

- (IBAction)startStory:(id)sender;
- (IBAction)getMorePoints:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)backToStories:(id)sender;
- (IBAction)backToChapters:(id)sender;
- (IBAction)backHome:(id)sender;

- (IBAction)checkForStory:(id)sender;
- (IBAction)goToStory:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)buyStory:(id)sender;
- (IBAction)viewPDF:(id)sender;
- (IBAction)publishStory:(id)sender;

- (IBAction)startedButton:(id)sender;
- (IBAction)featuredButton:(id)sender;
- (IBAction)contributedButton:(id)sender;

- (IBAction)seeAllStories:(id)sender;

- (IBAction)logout:(id)sender;

- (IBAction)goToMap:(id)sender;

- (IBAction)reportStory:(id)sender;
- (IBAction)goToFeed:(id)sender;


@property (nonatomic, weak) IBOutlet UITableView *tableOfContents;
@property (nonatomic, weak) IBOutlet UITableView *feedTable;


@end
