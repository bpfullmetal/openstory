//
//  ProfileView.m
//  openStory
//
//  Created by Brandon Phillips on 7/11/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "ProfileView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface ProfileView ()

@end

@implementation ProfileView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (void)makeProfile: (NSString *)uid type: (int)type{

    NSLog(@"making profile: %@", chapterArray);
    NSArray *filtered = [[NSArray alloc]init];
    NSString *userId = [[NSString alloc]init];
    NSString *userBio = [[NSString alloc]init];
    NSString *userName = [[NSString alloc]init];
    NSString *userTwitter = [[NSString alloc]init];
    if (type == 1){
        filtered = [chapterArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(chapter_user == %@)", uid]];
        profileItem = [filtered objectAtIndex:0];
        userId = [profileItem objectForKey:@"chapter_user"];
        userBio = [profileItem objectForKey:@"chapter_user_bio"];
        userName = [profileItem objectForKey:@"chapter_author"];
        userTwitter = [profileItem objectForKey:@"chapter_user_twitter"];
    }else if(type == 2){
        filtered = [likesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(liker == %@)", uid]];
        profileItem = [filtered objectAtIndex:0];
        userId = [profileItem objectForKey:@"liker"];
        userBio = [profileItem objectForKey:@"bio"];
        userName = [profileItem objectForKey:@"likesUser"];
        userTwitter = [profileItem objectForKey:@"twitter"];
    }
    
    
    
    self.profileImage.clipsToBounds = YES;
    [self.profileImage.layer setCornerRadius:43];
    [self.profileImage.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", userId]];
    [self.profileImage sd_setImageWithURL:ImageURL placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];

    self.profileBio.layoutManager.delegate = self;
    self.profileBio.text = userBio;
    self.profileBio.textColor = [UIColor whiteColor];
    [self.profileBio setFont: [UIFont fontWithName:@"Heiti SC" size:12.0]];
    
    profileAuthor.text = userName;
    [userStoriesButton setTitle:[NSString stringWithFormat:@"SEE STORIES BY %@", [userName uppercaseString]] forState:UIControlStateNormal];
    
    NSLog(@"dictionary: %@", profileItem);
    
    if ((![userTwitter isEqualToString:@"0"]) ){
        
        [twitterNameButton setTitle:[NSString stringWithFormat:@"@%@",[userTwitter uppercaseString]] forState:UIControlStateNormal];
    }
    
    UIButton *upgradeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 320, 50)];
    [upgradeButton setTitle:@"USER STORIES" forState:UIControlStateNormal];
    selectedUser = userId;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)goToMyTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat: @"https://twitter.com/%@", [profileItem objectForKey: @"chapter_user_twitter"]]]];
}

- (void) appStoreUpgrade:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app//[B]APP NAME[/B]/id[B]APP ID[/B]?mt=8"]];
}

- (IBAction)closeProfile:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeProfile" object:self];
}

- (void)unlockStories{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToSelectedUser" object:self];
}

- (IBAction)goToUser:(id)sender{
    
    NSArray *featuresArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
    if ([featuresArray containsObject:@"UNLOCKUSERSTORIES99"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToSelectedUser" object:self];
    }else{
        UIAlertView *upgradeToSeeUserStories = [[UIAlertView alloc] initWithTitle:Nil
                                                          message:@"Access to user stories is a paid feature. Get it now?"
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles: @"Unlock It!", nil];
        [upgradeToSeeUserStories show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Unlock It!"])
    {
        [self getAccess];
    }
}

- (void)getAccess{
    [purchase getProductInfo:@"UNLOCKUSERSTORIES99" productType:2];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unlockStories)
                                                 name:@"UNLOCKUSERSTORIES99" object:nil];
    
    purchase = [[PurchaseItem alloc]init];
    profileItem = [[NSDictionary alloc] init];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
