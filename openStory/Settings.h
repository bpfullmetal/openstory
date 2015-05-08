//
//  Settings.h
//  openStory
//
//  Created by Brandon Phillips on 2/21/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenreCell.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "LoadingView.h"
#import "Tutorial.h"
#import "TermsView.h"
#import "PurchaseItem.h"

@interface Settings : UIViewController<UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewAccessibilityDelegate, UIScrollViewDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    float screenWidth;
    float screenHeight;
    
    PurchaseItem *purchase;
    Tutorial *tutorialView;
    TermsView *condiShawns;
    LoadingView *loader;
    IBOutlet UIButton *suggestG;
    IBOutlet UIButton *submitGenreButton;
    IBOutlet UILabel *twitterLabel;
    
    IBOutlet UIView *bioView;
    IBOutlet UIView *userView;
    IBOutlet UIView *passwordView;
    IBOutlet UIView *genreView;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *scrollContent;
    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *addUserPhoto;
    IBOutlet UITextView *bio;
    IBOutlet UILabel *bioPlaceholder;
    IBOutlet UITextField *site;
    IBOutlet UIButton *username;
    IBOutlet UIView *sideNav;
    IBOutlet UIView *sideNavInner;
    IBOutlet UIView *tableHolder;
    IBOutlet UIButton *submitBioButton;
    
    IBOutlet UIButton *editBioButton;
    IBOutlet UIButton *changeUsernameButton;
    IBOutlet UIButton *changePasswordButton;
    IBOutlet UIButton *updateGenresButton;
    
    IBOutlet UITextField *newusername;
    IBOutlet UITextField *userpass;
    
    IBOutlet UITextField *oldPass;
    IBOutlet UITextField *newPass;
    
    UIImagePickerController *imagePicker;
    NSArray *genreArray;
    GenreCell *genreRow;
    
    NSMutableArray *previouslySelectedGenres;
    NSMutableArray *removedGenres;
    NSMutableArray *selectedGenres;
    NSMutableArray *addedGenres;

    
    UITextField *suggestionField;
    
    BOOL isDragging;
    CGPoint lastPoint;
    NSString *slideDirection;
    IBOutlet UILabel *passwordAlert;
}

// NAV BUTTONS

- (IBAction)updateBio:(id)sender;
- (IBAction)updateUserName:(id)sender;
- (IBAction)updatePassword:(id)sender;
- (IBAction)updateGenres:(id)sender;
- (IBAction)submitNameChange:(id)sender;
- (IBAction)submitPasswordChange:(id)sender;
- (IBAction)submitGenreChange:(id)sender;
- (IBAction)submitBioChange:(id)sender;
- (IBAction)twitterSwitchChanged:(id)sender;

- (IBAction)backToMain:(id)sender;
- (IBAction)closeSettings:(id)sender;

- (IBAction)suggestAGenre:(id)sender;
- (IBAction)restorePurchases:(id)sender;

- (void)placeImage;

@property (nonatomic, strong) IBOutlet ACAccountStore *accountStore;
@property (nonatomic, weak) IBOutlet UISegmentedControl *twitterSelect;
@property (nonatomic, weak) IBOutlet UITableView *genreTable;

@end
