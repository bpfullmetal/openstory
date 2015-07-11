//
//  DailyStory.m
//  openStory
//
//  Created by Brandon Phillips on 4/11/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "DailyStory.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface DailyStory ()

@end

@implementation DailyStory

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

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"daily story appear");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    userProfile= [[ProfileView alloc]initWithNibName:@"ProfileView" bundle:nil];
    loader = [[LoadingView alloc]init];
    likesBox = [[LikesView alloc]initWithNibName:@"LikesView" bundle:nil];
    [likesBox.view setFrame:CGRectMake(0, screenHeight - likesBox.likesBoxBottom.frame.size.height - 10, likesBox.view.frame.size.width, likesBox.likesBoxBottom.frame.size.height)];
    
    [dailyScroll setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [profileBox setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    [dailyScrollView setFrame:CGRectMake(0, 0, screenWidth*3, screenHeight)];
    [dailyScrollOne setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [dailyScrollTwo setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [dailyScrollThree setFrame:CGRectMake(screenWidth*2, 0, screenWidth, screenHeight)];
    
    [self.view layoutIfNeeded];
    
    
    startStoryView = [[StartStory alloc]initWithNibName:@"StartStory" bundle:nil];
    
    
    
    [profileBox setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    
    CGSize size = dailyScrollView.bounds.size;
    dailyScrollView.frame = CGRectMake(0, 0, size.width, size.height);
    [dailyScroll addSubview:dailyScrollView];
    dailyScroll.contentSize = size;
    dailyScroll.delegate = self;
    dailyScroll.alwaysBounceVertical = NO;
    // If you don't use self.contentView anywhere else, clear it here.
    //dailyScroll = nil;
    [self.view insertSubview:loader aboveSubview:dailyScroll];
    loader.hidden = TRUE;
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storyBoxSlideDown)
                                                 name:@"closeProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewProfileFromLikes)
                                                 name:@"showUserProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToSelectedUser)
                                                 name:@"UNLOCKUSERSTORIES99" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLikesBox)
                                                 name:@"showLikes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToSelectedUser)
                                                 name:@"goToSelectedUser" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeLikesBox)
                                                 name:@"hideLikes" object:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"daily story view will appear");
    [self getPrompt];
}

- (void)getPrompt{
    [loader loadingmessage:@"loading prompt"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSURLSession *promptSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *promptTask = [promptSession dataTaskWithURL:[NSURL URLWithString:@"http://www.fullmetalworkshop.com/openstory/getstoryprompt.php"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError* error;
            
            NSArray *promptArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            NSDictionary* promptDictionary = [promptArray objectAtIndex:0];
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int promptId = [[promptDictionary objectForKey:@"id"] intValue]; // PROMPT ID
            NSString *pId = [NSString stringWithFormat:@"%d", promptId];
            [[NSUserDefaults standardUserDefaults]setObject:pId forKey:@"fid"];
            
            NSString *promptString = [promptDictionary objectForKey:@"prompt"];
            if ([promptString rangeOfString:@"Å"].location == NSNotFound) {
                
            }else{
                promptString = [promptString stringByReplacingOccurrencesOfString:@"Å" withString:@"\""];
            }
            if ([promptString rangeOfString:@"ð"].location == NSNotFound) {
                
            }else{
                promptString = [promptString stringByReplacingOccurrencesOfString:@"ð" withString:@"'"];
            }
            if ([promptString rangeOfString:@"&amp;nbsp;"].location == NSNotFound) {
                
            }else{
                promptString = [promptString stringByReplacingOccurrencesOfString:@"&amp;nbsp;" withString:@" "];
            }
             
            promptView.text = promptString;
            [promptView setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
            
            promptView.textAlignment = NSTextAlignmentCenter;
            promptView.layoutManager.delegate = self;
            promptView.textColor = [UIColor whiteColor];
            
            // SET PROMPT DETAILS
            [[NSUserDefaults standardUserDefaults] setObject:[promptDictionary objectForKey:@"prompt"] forKey:@"prompt"];
            // END PROMPT DETAILS

            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
        });
    }];
    [promptTask resume];
}

- (IBAction)getWinners:(id)sender{
    [loader loadingmessage:@"getting winners"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *todaysPromptId = [[NSUserDefaults standardUserDefaults]objectForKey:@"fid"];
    int pId = [todaysPromptId intValue]-1;
    
    NSString *promptId = [NSString stringWithFormat:@"%d", pId];
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getwinners.php?pid=%@&cid=0",promptId];
    
    NSURLSession *winnersSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *winnersTask = [winnersSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            winnersArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            
            if (winnersArray.count > 0){
                dailyStoryType = 1;
                id val = [winnersArray objectAtIndex:0];
                [self loadThisStory:[[val objectForKey:@"story_id"] intValue] type:1];
            }else{
                UIAlertView *noWinners = [[UIAlertView alloc] initWithTitle:Nil
                                                                   message:@"There were no winners yesterday. Vote for today's stories so this doesn't happen again!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles: nil];
                loader.hidden = TRUE;
                [loader.spinner stopAnimating];
                [noWinners show];
            }
            
            
        });
    }];
    
    [winnersTask resume];
}

- (IBAction)allSubmissions:(id)sender{
    
    [loader loadingmessage:@"loading today's submissions"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *todaysPromptId = [[NSUserDefaults standardUserDefaults]objectForKey:@"fid"];
    NSString *currentSubmission = @"";
    if(selectedChapter){
        currentSubmission = selectedChapter;
    }else{
        currentSubmission = @"1";
    }
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getwinners.php?pid=%@&cid=%@",todaysPromptId, currentSubmission];
    
    NSURLSession *todaysSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *todaysTask = [todaysSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            todaysArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            
            if (todaysArray.count > 0){
                dailyStoryType = 2;
                id val = [todaysArray objectAtIndex:0];
                NSLog(@"array %@", val);
                [self loadThisStory:[[val objectForKey:@"story_id"] intValue] type:2];
            }else{
                UIAlertView *noSubmissions = [[UIAlertView alloc] initWithTitle:Nil
                                                                    message:@"There are no submissions for today's prompt yet. Try again later!"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles: nil];
                loader.hidden = TRUE;
                [loader.spinner stopAnimating];
                [noSubmissions show];
            }
            
            
        });
    }];
    
    [todaysTask resume];
}

- (IBAction)nextWinner:(id)sender{
    int currentIndex;
    NSLog(@"next");
    int indexCount = 0;
    for (NSDictionary *winnerItem in winnersArray)
    {
        
        if ([[winnerItem objectForKey:@"story_id"] isEqualToString:selectedStory])
            {
                currentIndex = indexCount;
                //[self loadThisStory:[[winnerItem objectForKey:@"story_id"] intValue] type:1];
            }
        indexCount ++;
    }
    //NSLog(@"current index: %d and array count: %d", currentIndex, ((int)winnersArray.count) -2);
    if (currentIndex == ((int)winnersArray.count -1)){
        nextWinnerButton.hidden = TRUE;
    }else{
    NSDictionary *item = [winnersArray objectAtIndex:(currentIndex +1)];
    prevWinnerButton.hidden = FALSE;
    [self loadThisStory:[[item objectForKey:@"story_id"] intValue] type:1];
    }
}

- (IBAction)prevWinner:(id)sender{
    int currentIndex;
    int indexCount = 0;
    for (NSDictionary *winnerItem in winnersArray)
    {
        if ([[winnerItem objectForKey:@"story_id"] isEqualToString:selectedStory])
        {
            currentIndex = indexCount;
            //[self loadThisStory:[[winnerItem objectForKey:@"story_id"] intValue] type:1];
        }
        indexCount ++;
    }
    if (currentIndex == 1){
        prevWinnerButton.hidden = TRUE;
    }
    
    NSDictionary *item = [winnersArray objectAtIndex:(currentIndex -1)];
    nextWinnerButton.hidden = FALSE;
    [self loadThisStory:[[item objectForKey:@"story_id"] intValue] type:1];
}

- (IBAction)closeWinners:(id)sender{
    [dailyScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)closeSubmissions:(id)sender{
    [dailyScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)loadThisStory: (int)storyId type:(int)type{
    
    if (type == 1){
        currentArray = winnersArray;
    }else if (type == 2){
        currentArray = todaysArray;
    }
    selectedStory = [NSString stringWithFormat:@"%d", storyId];
    //[scrollView setContentOffset:CGPointMake(640, 0) animated:YES];
    NSArray *filtered = [currentArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(story_id == %@)", selectedStory]];
    NSDictionary *item = [filtered objectAtIndex:0];
    
    if (type == 1){
        [storyNameLabel setText:[[item objectForKey:@"story_name"]uppercaseString]];
    }else if(type == 2){
        [subStoryNameLabel setText:[[item objectForKey:@"story_name"]uppercaseString]];
    }
    
    
    NSURLSession *getChapterSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *chapTask = [getChapterSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getchapters.php?story=%@",selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSError *error = nil;
            chapterArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            NSLog(@"data string: %@", chapterArray);
                NSDictionary *item = [chapterArray objectAtIndex:0];
                NSString *cId = [item objectForKey:@"chapter_id"];
                NSString *cOrder = [item objectForKey:@"chapter_order"];
                NSString *cName = [item objectForKey:@"chapter_name"];
                selectedChapter = cId;
            
            NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"chapter_user"]]];
            
            if (type == 1){
                authorImage.contentMode = UIViewContentModeScaleAspectFill;
                authorImage.clipsToBounds = YES;
                authorImage.layer.cornerRadius = 28;
                [authorImage sd_setImageWithURL:ImageURL];
                //[authorImage setImageWithURL:ImageURL]; USE THIS IS SD_SETIMAGE DOESN'T WORK
                NSLog(@"image url: %@", ImageURL);
                authorUsername.text = [[item objectForKey:@"chapter_author"] uppercaseString];
                [profileButton addTarget:self
                                  action:@selector(viewProfile:)
                        forControlEvents:UIControlEventTouchUpInside];
                
                int buttonId = (int)[[item objectForKey:@"chapter_user"]integerValue];
                [profileButton setTag:buttonId];
            }else{
                subAuthorImage.contentMode = UIViewContentModeScaleAspectFill;
                subAuthorImage.clipsToBounds = YES;
                subAuthorImage.layer.cornerRadius = 28;
                [authorImage sd_setImageWithURL:ImageURL];
                //[subAuthorImage setImageWithURL:ImageURL]; USE THIS IS SD_SETIMAGE DOESN'T WORK
                subAuthorUsername.text = [[item objectForKey:@"chapter_author"] uppercaseString];
                [subProfileButton addTarget:self
                                  action:@selector(viewProfile:)
                        forControlEvents:UIControlEventTouchUpInside];
                if ([[item objectForKey:@"chapter_user"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]){
                    reportChapter.hidden = true;
                    reportChapterOne.hidden = TRUE;
                }else{
                    reportChapter.hidden = false;
                    reportChapterOne.hidden = false;
                }
                int buttonId = [[item objectForKey:@"chapter_user"]intValue];
                [subProfileButton setTag:buttonId];
            }
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
                [self showChapterText:cId chapterOrder:cOrder chapterName:cName];
            
        });
    }];
    
    [chapTask resume];
}

- (void)showChapterText:(NSString *)cId chapterOrder:(NSString *)cOrder chapterName:(NSString *)cName{
    
    chapterTextBox.layoutManager.delegate = self;
    subChapterTextBox.layoutManager.delegate = self;
    NSDictionary *item = [chapterArray objectAtIndex:0];
    
    if (dailyStoryType == 1){
        [self getLikes: 2];
        chapterTextBox.text = [item objectForKey:@"chapter_text"];
        chapterTextBox.textColor = [UIColor whiteColor];
        [dailyScroll setContentOffset:CGPointMake(320, 0) animated:YES];
    }else if(dailyStoryType == 2){
        [self getLikes: 3];
        subChapterTextBox.text = [item objectForKey:@"chapter_text"];
        subChapterTextBox.textColor = [UIColor whiteColor];
        if (dailyScroll.frame.origin.x != 640){
            [dailyScroll setContentOffset:CGPointMake(640, 0) animated:YES];
        }
    }
}

- (void) viewProfileFromLikes{
    if (self.isViewLoaded && self.view.window) {
        NSLog(@"selectee user: %@", selectedUser);
        [profileBox addSubview:userProfile.view];
        [userProfile makeProfile:selectedUser type:2];
        
        [self storyBoxSlideUp];
    }
}

- (void) viewProfile:(id)sender{
    if (self.isViewLoaded && self.view.window) {
    UIButton *temp = sender;
    int uidint = (int)temp.tag;
    NSString *uid = [NSString stringWithFormat:@"%d", uidint];
    
    [profileBox addSubview:userProfile.view];
        [userProfile makeProfile:uid type:1];
    
    [self storyBoxSlideUp];
    }
}

- (IBAction)goToMyTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat: @"https://twitter.com/%@", [profileItem objectForKey: @"chapter_user_twitter"]]]];
}

- (void)showLikesBox{
    likesBox.likesBoxView.hidden = FALSE;
    [likesBox.view setFrame:CGRectMake(0, screenHeight - 264, likesBox.view.frame.size.width, 254)];
    likesBox.likesBoxBottom.frame = CGRectMake(0, 179, 320, 75);
}

- (void)closeLikesBox{
    likesBox.likesBoxView.hidden = TRUE;
    likesBox.likesBoxBottom.frame = CGRectMake(0, 0, 320, 75);
    [likesBox.view setFrame:CGRectMake(0, screenHeight -85, likesBox.view.frame.size.width, 254)];
}

- (void)getLikes: (int)boxNumber{
    [likesBox.view removeFromSuperview];
    [likesBox getChapterLikes];
    
    if (boxNumber == 2){
        [dailyScrollTwo insertSubview:likesBox.view belowSubview:prevWinnerButton];
    }else if (boxNumber == 3){
        [dailyScrollThree insertSubview:likesBox.view belowSubview:nextButton];
    }
}

- (void)storyBoxSlideDown{
    //[[storyBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBox setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    }completion:^(BOOL done){
        [profileBox.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

- (void)storyBoxSlideUp{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBox setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }completion:^(BOOL done){
    }];
}

- (IBAction)closeDaily:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) goToSelectedUser{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app//[B]APP NAME[/B]/id[B]APP ID[/B]?mt=8"]];
    if (likesBox.likesBoxView.hidden == FALSE){
        [self closeLikesBox];
    }
    [self storyBoxSlideDown];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)writeDaily:(id)sender{
    NSString *userID = [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"];
    NSURLSession *fSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *fTask = [fSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/fstorycheck.php?userid=%@", userID]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(datastring.intValue == 0){
                [[NSUserDefaults standardUserDefaults]setObject:@"daily" forKey:@"storyType"];
                [self.navigationController pushViewController:startStoryView animated:YES];
            }else{
                UIAlertView *comeback = [[UIAlertView alloc] initWithTitle:Nil
                                                                   message:@"You've already submitted a story for today's prompt. Come back tomorrow, or start an open story!"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles: nil];
                [comeback show];
            }
            
        });
    }];
    
    [fTask resume];
}


- (IBAction)goToWebsite:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/dailyPrompt"]];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reportStory:(id)sender{
    NSURLSession *reportCheckSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *reportCheckTask = [reportCheckSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/reportcheck.php?cid=%@&uid=%@", selectedChapter, [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int reported = [datastring intValue];
            if (reported == 0){
                UIAlertView *reportChap = [[UIAlertView alloc]
                                          initWithTitle:@"Tell us why you're reporting this chapter for removal."
                                          message:nil
                                          delegate:self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles:@"Report", nil ];
                
                reportChap.alertViewStyle = UIAlertViewStylePlainTextInput;
                reportField = [reportChap textFieldAtIndex:0];
                reportField.keyboardType = UIKeyboardTypeDefault;
                reportField.placeholder = @"Reason for reporting";
                reportField.secureTextEntry = NO;
                
                [reportChap show];
            }else if(reported == 1){
                UIAlertView *snitched = [[UIAlertView alloc] initWithTitle:Nil
                                                                   message:@"You've already reported this chapter. It is being reviewed for removal"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles: nil];
                [snitched show];
            }
        });
    }];
    
    [reportCheckTask resume];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Report"])
    {
        [self reportChapter];
    }
}

- (void)reportChapter{
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/reportchapter.php?uid=%@&cid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"], selectedChapter];
    
    NSMutableURLRequest *uploadRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    [uploadRequest setHTTPMethod:@"POST"];
    //[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [uploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    /*
     now lets create the body of the post
     */
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[reportField.text dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [uploadRequest setHTTPBody:body];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *uploadSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *uploadTask = [uploadSession dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
        //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        });
        
    }];
    [uploadTask resume];
}

@end
