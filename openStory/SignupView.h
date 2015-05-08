//
//  SignupView.h
//  openStory
//
//  Created by Brandon Phillips on 2/8/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenreCell.h"
#import <Accounts/Accounts.h>
#import "LoadingView.h"

@interface SignupView : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIScrollViewAccessibilityDelegate, UIScrollViewDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>{
    
    float screenHeight;
    float screenWidth;
    
    NSString *userID;
    NSString *token;
    IBOutlet UILabel *twitterLabel;
    LoadingView *loader;
    UIImagePickerController *imagePicker;
    
    IBOutlet UIView *loginView;
    IBOutlet UIView *signupView;
    IBOutlet UIView *genreView;
    IBOutlet UIView *bioView;
    
    IBOutlet UIScrollView *signupScroll;
    IBOutlet UIView *scrollContent;
    
    NSArray *genreArray;
    GenreCell *genreRow;
    
    NSMutableArray *selectedGenres;
    IBOutlet UIView *tableHolder;
    IBOutlet UILabel *faveGen;
    IBOutlet UIButton *suggGen;
    IBOutlet UIButton *submitGenreButton;
    
    IBOutlet UITextField *signupUsername;
    IBOutlet UITextField *signupEmail;
    IBOutlet UITextField *signupPassword;
    
    IBOutlet UILabel *suPassResponse;
    IBOutlet UILabel *suUserResponse;
    IBOutlet UILabel *suEmailResponse;
    IBOutlet UILabel *suresponse;
    
    IBOutlet UITextField *loginUser;
    IBOutlet UITextField *loginPass;
    IBOutlet UILabel *liresponse;

    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *addUserPhoto;
    IBOutlet UITextView *bio;
    IBOutlet UITextField *site;
    IBOutlet UILabel *bioLabel;
    
    UITextField *forgotUserEmailField;
    UITextField *forgotPasswordField;
    UITextField *suggestionField;
}

- (IBAction)signup:(id)sender;
- (IBAction)submitSignup:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)loginSubmit:(id)sender;
- (IBAction)submitGenres:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)submitBio:(id)sender;
- (IBAction)skipGenre:(id)sender;
- (IBAction)skipBio:(id)sender;
- (IBAction)forgotUser:(id)sender;
- (IBAction)forgotPass:(id)sender;
- (IBAction)twitterSwitchChanged:(id)sender;

- (IBAction)suggestGenre:(id)sender;

- (void)placeImage: (UIImage *)image;

@property (nonatomic, weak) IBOutlet UITableView *genreTable;
@property (nonatomic, strong) IBOutlet ACAccountStore *accountStore;
@property (nonatomic, weak) IBOutlet UISegmentedControl *twitterSelect;

@end
