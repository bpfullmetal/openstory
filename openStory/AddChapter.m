//
//  AddChapter.m
//  openStory
//
//  Created by Brandon Phillips on 2/17/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "AddChapter.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "CCAlertView.h"

@interface AddChapter ()

@end

@implementation AddChapter

- (IBAction)submitChapter:(id)sender{
    if (lati.length != 0 && longi.length != 0){
        [self uploadText];
    }else{
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"We need your location! Go to settings and enable location access for Open Story"];
        [alert addButtonWithTitle:@"Ok" block:NULL];
        [alert show];
    }
}

- (void)getStory{
    NSURLSession *getChapterSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *chapTask = [getChapterSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getchapters.php?story=%@",selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"load story data: %@", datastring);
            NSError *error = nil;
            chapterArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            
            //NSLog(@"chapters: %@", chapterArray);
            // OPEN STORY
            self.tableOfContents.delegate = self;
            self.tableOfContents.dataSource = self;
            selectedChapterOrder = [NSString stringWithFormat:@"%d", (int)chapterArray.count];
            int newChapterOrder = selectedChapterOrder.intValue +1;
            NSString *order = [NSString stringWithFormat:@"%d", newChapterOrder];
            chapNum.text = [NSString stringWithFormat:@"%@:", order];
            NSLog(@"dhapter count: %d", (int)chapterArray.count);
            [self.tableOfContents reloadData];
            
            NSMutableArray *idList = [[NSMutableArray alloc]init];
            
            for (NSDictionary *cItem in chapterArray){
                [idList addObject:[cItem objectForKey:@"chapter_user"]];
            }
            
            [loader.spinner stopAnimating];
            loader.hidden = TRUE;
        });
    }];
    
    [chapTask resume];
}

- (void)uploadText{
    
    cTitleAlert.hidden = TRUE;
    cLengthAlert.hidden = TRUE;
    cLimitAlert.hidden = TRUE;
    
    NSString *chapterTitleTest = self.chapterTitleField.text;
    NSString *storyTextTest = self.chapterBox.text;
    
    if (chapterTitleTest.length > 0 && storyTextTest.length >= 200 ){
        
        [loader loadingmessage:@"submitting chapter"];
        loader.hidden = FALSE;
        [loader.spinner startAnimating];
    
    NSString *cTitle = [self.chapterTitleField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
    int newChapterOrder = selectedChapterOrder.intValue +1;
    NSString *order = [NSString stringWithFormat:@"%d", newChapterOrder];
    NSString *txtString = [[NSString alloc]initWithString: self.chapterBox.text];
        
        NSString *post = [NSString stringWithFormat: @"name=%@&text=%@", cTitle, txtString];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/uploadchapter.php?userId=%@&lat=%@&long=%@&order=%@&weather=%d&storyId=%@", userId, lati, longi, order, 0, selectedStory ];
    
    NSMutableURLRequest *uploadChapterRequest = [[NSMutableURLRequest alloc] init];
    [uploadChapterRequest setURL:[NSURL URLWithString:fullURL]];
    [uploadChapterRequest setHTTPMethod:@"POST"];
    [uploadChapterRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadChapterRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [uploadChapterRequest setHTTPBody:postData];
    
    /*NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [uploadChapterRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[txtString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [uploadChapterRequest setHTTPBody:body];*/
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *uploadChapterSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *uploadChapterTask = [uploadChapterSession dataTaskWithRequest:uploadChapterRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data string: %@", datastring);
        [timer invalidate];
        [loader.spinner stopAnimating];
        loader.hidden = TRUE;
            tweetView.type = CSAnimationTypeFadeIn;
            tweetView.delay = 0.0;
            tweetView.duration = 1.0;
            tweetView.hidden = false;
            [tweetView startCanvasAnimation];
        });
    }];
    
    [uploadChapterTask resume];
    }else{
        if (chapterTitleTest.length < 1){
                cTitleAlert.hidden = FALSE;
        }
        if (storyTextTest.length < 200){
            cLengthAlert.hidden = FALSE;
        }
    }
}

- (IBAction)tweetTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I just wrote a story using @openstoryapp #openstory"];
        [tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/open-story/id851954919"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)finishedTweeting:(id)sender{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"newChapterSave"];
    [self storyBoxSlideUp];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

    [self.navigationController popToRootViewControllerAnimated:YES];
    tweetView.hidden = true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(textView == self.chapterBox){
        NSString* newText = [self.chapterBox.text stringByReplacingCharactersInRange:range withString:text];
        NSString *trimmedText = [newText stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        int limit = 700;
        if (newText.length - trimmedText.length > 700) {
            [NSString stringWithFormat:@"you've reached the %d word limit", limit];
            cLimitAlert.hidden = TRUE;
            return NO;
        }else if(newText.length - trimmedText.length > 600){
            cLimitAlert.text = [NSString stringWithFormat:@"you're getting close to the %d word limit", limit];
            cLimitAlert.hidden = FALSE;
            return YES;
        }else if(newText.length - trimmedText.length > 610){
            cLimitAlert.hidden = TRUE;
            return YES;
        }else{
            return YES;
        }
    }
    return TRUE;
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self.chapterBox resignFirstResponder];
    [self.chapterTitleField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    startChapterLabel.hidden = TRUE;
    cTitleAlert.hidden = TRUE;
    cLengthAlert.hidden = TRUE;
    cLimitAlert.hidden = TRUE;
    int newStoryBoxHeight;
    if([[UIScreen mainScreen] bounds].size.height == 568){
        newStoryBoxHeight = 165;
    }else{
        newStoryBoxHeight = 100;
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.chapterBox setFrame:CGRectMake(self.chapterBox.frame.origin.x, self.chapterBox.frame.origin.y, self.chapterBox.frame.size.width, newStoryBoxHeight)];
    }completion:^(BOOL done){
    }];
    
    [self startTimer];
}

- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
}

-(void)timerCalled
{
    [[NSUserDefaults standardUserDefaults] setObject:self.chapterBox.text forKey:@"newChapterSave"];
    NSLog(@"saved text %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"newChapterSave"]);
    // Your Code
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"story box is ended");
    int newStoryBoxHeight;
    if([[UIScreen mainScreen] bounds].size.height == 568){
        newStoryBoxHeight = 326;
    }else{
        newStoryBoxHeight = 250;
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.chapterBox setFrame:CGRectMake(self.chapterBox.frame.origin.x, self.chapterBox.frame.origin.y, self.chapterBox.frame.size.width, newStoryBoxHeight)];
    }completion:^(BOOL done){
    }];
    [timer invalidate];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    if (selectedUser == userID){
        skipStoryButton.hidden = true;
    }else{
        skipStoryButton.hidden = FALSE;
    }
    self.chapterBox.text = @"";
    
    [self getStory];
    addButton.hidden = FALSE;
    storyNameLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"addChapterTitle"];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [cLocationManager startUpdatingLocation];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"newChapterSave"] || [[[NSUserDefaults standardUserDefaults]objectForKey:@"newChapterSave"] isEqualToString:@""]){
        
    }else{
        UIAlertView *savedStory = [[UIAlertView alloc] initWithTitle:Nil
                                                             message:@"There's a chapter saved. Do you want to resume this story or start a new one?"
                                                            delegate:self
                                                   cancelButtonTitle:@"start new"
                                                   otherButtonTitles: @"resume", nil];
        [savedStory show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    cTitleAlert.hidden = TRUE;
    cLengthAlert.hidden = TRUE;
    cLimitAlert.hidden = TRUE;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        [timer invalidate];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"newChapterSave"];
        self.chapterBox.text = @"";
        self.chapterTitleField.text = @"";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([title isEqualToString:@"resume"]){
        [self.chapterBox setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"newChapterSave"]];
        startChapterLabel.hidden = TRUE;
        [self startTimer];
    }else if([title isEqualToString:@"start new"]){
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"newChapterSave"];
    }else if([title isEqualToString:@"Yes, skip it"]){
        [self reallySkipIt];
    }
}

#pragma mark - SCREEN ONE

- (IBAction)addChapter:(id)sender{
    
    [self.storyTitle setText:[[[NSUserDefaults standardUserDefaults]objectForKey:@"addChapterTitle"] uppercaseString]];
    [self storyBoxSlideUp];
    showHideButton.hidden = FALSE;
    showHideButton.transform = CGAffineTransformMakeRotation(M_PI *2);
    [showHideButton setFrame:CGRectMake((screenWidth/2)-(showHideButton.frame.size.width/2), 0, 50, 30)];
    addButton.hidden = TRUE;
}

- (IBAction)showHide:(id)sender{
    [self.chapterBox resignFirstResponder];
    if(addChapterView.frame.origin.y < 0){
        [self storyBoxSlideUp];
        NSLog(@"where is it!!?");
        [showHideButton setImage:[UIImage imageNamed:@"hideshowUp.png"] forState:UIControlStateNormal];
        //showHideButton.transform = CGAffineTransformMakeRotation(M_PI *2);
        //[showHideButton setFrame:CGRectMake((screenWidth/2)-(showHideButton.frame.size.width/2), 0, 50, 30)];
    }else{
        [self storyBoxSlideDown];
        [showHideButton setImage:[UIImage imageNamed:@"hideshow.png"] forState:UIControlStateNormal];
        //showHideButton.transform = CGAffineTransformMakeRotation(M_PI);
        //[showHideButton setFrame:CGRectMake((screenWidth/2)-(showHideButton.frame.size.width/2), screenHeight - (showHideButton.frame.size.height), 50, 30)];
    }
}

- (IBAction)backHome:(id)sender{
    [self storyBoxSlideDown];
    showHideButton.hidden = TRUE;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)profileBoxSlideDown{
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    }completion:^(BOOL done){
        [[profileBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        profileBoxView.hidden = TRUE;
    }];
}

- (void)profileBoxSlideUp{
    profileBoxView.hidden = FALSE;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBoxView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }completion:^(BOOL done){
    }];
}

- (void)storyBoxSlideDown{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [addChapterView setFrame:CGRectMake(0, -screenHeight, screenWidth, screenHeight)];
    }completion:^(BOOL done){

    }];
}

- (void)storyBoxSlideUp{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [addChapterView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }completion:^(BOOL done){
    }];
}

- (IBAction)skipChapter:(id)sender{
    UIAlertView *skipit = [[UIAlertView alloc] initWithTitle:Nil
                                                     message:@"Are you sure you want to skip this story?"
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles: @"Yes, skip it", nil];
    [skipit show];
}

- (void) reallySkipIt{
    NSURLSession *skipSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *skipTask = [skipSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/skipchapter.php?uid=%@&sid=%@", userID, selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"askForStory"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
    
    [skipTask resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return chapterArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"ChapterRow" bundle:nil];
    [self.tableOfContents registerNib:nib forCellReuseIdentifier:@"chapterRow"];
    chapRow = [self.tableOfContents dequeueReusableCellWithIdentifier:@"chapterRow" forIndexPath:indexPath];
    chapRow.backgroundColor = [UIColor clearColor];
    NSDictionary *item = [chapterArray objectAtIndex:indexPath.row];
    chapRow.chapterRowName.text = [[item objectForKey:@"chapter_name"] uppercaseString];
    NSString *chapAuth = [item objectForKey:@"chapter_author"];
    chapRow.chapterRowAuthor.text = [chapAuth uppercaseString];
    //NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[item objectForKey:@"chapter_user_image"] options:0];
    chapRow.backgroundColor=[UIColor clearColor];
    [chapRow.chapterRowUser.layer setCornerRadius:25];
    [chapRow.chapterRowUser.layer setMasksToBounds:YES];
    if (selectedUser != userID ){
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"chapter_user"]]];
    [chapRow.chapterRowUser sd_setImageWithURL:ImageURL placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];
    }
    
    
    
    //[self downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"chapter_user"]]] completionBlock:^(BOOL succeeded, UIImage *image){
    
    /*if (succeeded) {
     UIImage *mask = [UIImage imageNamed:@"mask.png"];
     UIImage *newImage = [self maskImage:image withMask:mask];
     if (newImage){
     chapRow.chapterRowUser.image = newImage;
     }else{
     chapRow.chapterRowUser.image = [UIImage imageNamed:@"placeHolder.png"];
     }
     }*/
    
    //   }];
    
    
    chapRow.chapterRowUser.contentMode = UIViewContentModeScaleAspectFill;
    chapRow.chapterRowUser.clipsToBounds = YES;
    
    
    UIButton *profileButton = [[UIButton alloc]initWithFrame:CGRectMake(261, 6, 50, 50)];
    
    [profileButton addTarget:self
                      action:@selector(viewProfile:)
            forControlEvents:UIControlEventTouchUpInside];
    
    int buttonId = [[item objectForKey:@"chapter_user"]intValue];
    
    [profileButton setTag:buttonId];
    [chapRow.storyRowView insertSubview:profileButton aboveSubview:chapRow.chapterRowUser];
    NSLog(@"user info: %@ and current ID: %@ and chapter Id: %@", [item objectForKey:@"chapter_user"], userID, [item objectForKey:@"chapter_id"]);
    if (([[item objectForKey:@"chapter_order"] integerValue] == chapterArray.count) && ([[item objectForKey:@"chapter_user"] integerValue] == [userID integerValue])){
        
        //int buttonId = [[item objectForKey:@"chapter_id"]intValue];
    }
    
    return chapRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [loader loadingmessage:@"getting chapter"];
    [loader.spinner startAnimating];
    loader.hidden = FALSE;
    
    NSDictionary *item = [chapterArray objectAtIndex:indexPath.row];
    selectedChapter = [item objectForKey:@"chapter_id"];
    //NSString *chapterOrder = [item objectForKey:@"chapter_order"];
    [self showChapterText:(int)indexPath.row];
    if ([[item objectForKey:@"chapter_user"] isEqualToString:userID]){
        reportChapter.hidden = true;
    }else{
        reportChapter.hidden = false;
    }
    NSLog(@"selected");
}

- (void) viewProfileFromLikes{
    if (self.isViewLoaded && self.view.window) {
        NSLog(@"selectee user: %@", selectedUser);
        [profileBoxView addSubview:userProfile.view];
        [userProfile makeProfile:selectedUser type:2];
        
        
        
        [self profileBoxSlideUp];
    }
}

- (void) viewProfile:(id)sender{
    
    UIButton *temp = sender;
    int uidint = (int)temp.tag;
    NSString *uid = [NSString stringWithFormat:@"%d", uidint];
    
    [profileBoxView addSubview:userProfile.view];
    [userProfile makeProfile:uid type: 1];
    
    [self profileBoxSlideUp];
}

- (void)showChapterText:(int)theId{
    
    chapterTextBox.backgroundColor = [UIColor clearColor];
    chapterTextBox.layoutManager.delegate = self;
    NSDictionary *item = [chapterArray objectAtIndex:theId];
    //NSString *cId = [item objectForKey:@"chapter_id"];
    //NSString *cOrder = [item objectForKey:@"chapter_order"];
    NSString *cName = [item objectForKey:@"chapter_name"];
    NSString *cText = [item objectForKey:@"chapter_text"];
    [loader.spinner stopAnimating];
    loader.hidden = TRUE;
    chapterNameLabel.text = cName;
    chapterTextBox.text = cText;
    chapterTextBox.textColor = [UIColor whiteColor];
    [scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"fid"];
    
    [self getLikes];
}

#pragma mark - SCREEN TWO

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

- (void)getLikes{
    [likesBox.view removeFromSuperview];
    [likesBox getChapterLikes];
    [chapterTextView insertSubview:likesBox.view atIndex:999];
}

- (IBAction)backToTableOfContents:(id)sender{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)configureScrollView {
    CGSize size = scrollContent.bounds.size;
    scrollContent.frame = CGRectMake(0, 0, size.width, size.height);
    [scrollView addSubview:scrollContent];
    scrollView.contentSize = size;
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = NO;
    // If you don't use self.contentView anywhere else, clear it here.
    scrollContent = nil;
}

- (void)goToSelectedUser{
    if (likesBox.likesBoxView.hidden == FALSE){
        [self closeLikesBox];
    }
    [self profileBoxSlideDown];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)replaceHeightConstraintOnView:(UIView *)view withConstant:(float)constant
{
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == view) && (constraint.firstAttribute == NSLayoutAttributeHeight)) {
            constraint.constant = constant;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    userProfile = [[ProfileView alloc]initWithNibName:@"ProfileView" bundle:nil];
    userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
    
    likesBox = [[LikesView alloc]initWithNibName:@"LikesView" bundle:nil];
    [likesBox.view setFrame:CGRectMake(0, screenHeight - likesBox.likesBoxBottom.frame.size.height - 10, likesBox.view.frame.size.width, likesBox.likesBoxBottom.frame.size.height)];
    
    [scrollView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [profileBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    [addChapterView setFrame:CGRectMake(0, -screenHeight, screenWidth, screenHeight)];
    [scrollContent setFrame:CGRectMake(0, 0, screenWidth*2, screenHeight)];
    
    [self updateViewConstraints];
    
    NSLog(@"scroll view height: %f", scrollContent.frame.size.height);
    [self.view layoutIfNeeded];
    
    [self configureScrollView];
    loader = [[LoadingView alloc]init];
    [self.view addSubview:loader];
    [self.view bringSubviewToFront:loader];
    loader.hidden = TRUE;
    
    /*if([[UIScreen mainScreen] bounds].size.height != 568){
        [self.chapterBox setFrame:CGRectMake(self.chapterBox.frame.origin.x, self.chapterBox.frame.origin.y, self.chapterBox.frame.size.width, self.chapterBox.frame.size.height - 75)];
        [startChapterLabel setFrame:CGRectMake(startChapterLabel.frame.origin.x, startChapterLabel.frame.origin.y -20, startChapterLabel.frame.size.width, startChapterLabel.frame.size.height)];
        [finishChapterButton setFrame:CGRectMake(finishChapterButton.frame.origin.x, finishChapterButton.frame.origin.y -85, finishChapterButton.frame.size.width, finishChapterButton.frame.size.height)];
        [cLengthAlert setFrame:CGRectMake(cLengthAlert.frame.origin.x, cLengthAlert.frame.origin.y -85, cLengthAlert.frame.size.width, cLengthAlert.frame.size.height)];
    }*/
    
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [addChapterView addGestureRecognizer:singleTap];
    
    
    self.chapterBox.layoutManager.delegate = self;
    self.tableOfContents.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = tableMaskView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (__bridge id)UIColor.clearColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.clearColor.CGColor,
                       nil];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:1.0/16],
                          [NSNumber numberWithFloat:15.0/16],
                          [NSNumber numberWithFloat:1],
                          nil];
    tableMaskView.layer.mask = gradient;
    
    [profileBoxView setFrame:CGRectMake(0, -screenHeight, screenWidth, screenHeight)];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLikesBox)
                                                 name:@"showLikes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeLikesBox)
                                                 name:@"hideLikes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileBoxSlideDown)
                                                 name:@"closeProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewProfileFromLikes)
                                                 name:@"showUserProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToSelectedUser)
                                                 name:@"UNLOCKUSERSTORIES99" object:nil];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)reportStory:(id)sender{
    NSURLSession *reportCheckSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *reportCheckTask = [reportCheckSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/reportcheck.php?cid=%@&uid=%@", selectedChapter, userID]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int reported = [datastring intValue];
            NSLog(@"data: %@ string: %d", datastring, reported);
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
