//
//  StartStory.m
//  openStory
//
//  Created by Brandon Phillips on 2/7/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "StartStory.h"
#import "AppDelegate.h"
#import "CCAlertView.h"

@interface StartStory ()

@end

@implementation StartStory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

- (IBAction)finishStory:(id)sender{
    
    cTitleAlert.hidden = TRUE;
    sTitleAlert.hidden = TRUE;
    cLengthAlert.hidden = TRUE;
    cLimitAlert.hidden = TRUE;
    
    NSString *chapterTitleTest = [[NSString alloc]init];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"storyType"] isEqualToString:@"new"]){
        chapterTitleTest = self.chapterTitle.text;
    }else{
        chapterTitleTest = self.storyTitle.text;
    }
    
    NSString *storyTitleTest = self.storyTitle.text;
    NSString *storyTextTest = self.storyBox.text;
    
    if (chapterTitleTest.length > 0 && storyTitleTest.length > 0 && storyTextTest.length >= 200 ){
    [self getGenres];
    }else{
        if (self.chapterTitle.text.length < 1){
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"storyType"] isEqualToString:@"new"]){
                cTitleAlert.hidden = FALSE;
            }
        }
        if (self.storyTitle.text.length < 1){
            sTitleAlert.hidden = FALSE;
        }
        if (self.storyBox.text.length < 200){
            cLengthAlert.hidden = FALSE;
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(textView == self.storyBox){
        NSString* newText = [self.storyBox.text stringByReplacingCharactersInRange:range withString:text];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)submitStory:(id)sender{
    if (lati.length != 0 && longi.length != 0){
    //NSString *storyText = [[NSString alloc]initWithFormat: @"%@\n%@",self.chapterTitle.text, self.storyBox.text];
    NSString *storyText = [[NSString alloc]initWithFormat: @"%@", self.storyBox.text];
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString *docFile = [docDir stringByAppendingPathComponent: @"deck.txt"];
    
    [storyText writeToFile:docFile atomically:YES encoding:NSUTF8StringEncoding error:Nil];*/
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"storyType"] isEqualToString:@"new"])
       {
           [self sendtxtfile:storyText storyTitle:self.storyTitle.text chapterTitle:self.chapterTitle.text getOption:openoption];
       }else{
           [self sendtxtfile:storyText storyTitle:self.storyTitle.text chapterTitle:self.storyTitle.text getOption:2];
       }
    }else{
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"We need your location! Go to settings and enable location access for Open Story"];
        [alert addButtonWithTitle:@"Ok" block:NULL];
        [alert show];
    }
}
-(IBAction)segmentedChartButtonChanged:(id)sender
{
    UISegmentedControl *segment=(UISegmentedControl*)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:
            NSLog(@"5d selected. Index: %ld", (long)self.openSelect.selectedSegmentIndex);
            openoption = 1;
            break;
        case 1:
            NSLog(@"3m selected. Index: %ld", (long)self.openSelect.selectedSegmentIndex);
            [self setClosed];
            break;
        default:
            break;
    }
}

- (void)closedUnlocked{
    NSMutableArray *features = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"]];
    //features = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
    [features addObject:@"UNLOCKCLOSED99"];
    
    [[NSUserDefaults standardUserDefaults]setObject:features forKey:@"allFeatures"];
    UIAlertView *unlocked = [[UIAlertView alloc] initWithTitle:Nil
                                                               message:@"You can now write closed stories!"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cool!"
                                                     otherButtonTitles: nil];
    [unlocked show];
    [self setClosed];
}

- (void) setClosed{
    if (self.isViewLoaded && self.view.window) {
    NSArray *featuresArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
    if ([featuresArray containsObject:@"UNLOCKCLOSED99"]){
        openoption = 0;
    }else{
        UIAlertView *upgradeForClosed = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message:@"Writing closed stories is a paid feature. Get it now?"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Not yet"
                                                                otherButtonTitles: @"Unlock It!", nil];
        [upgradeForClosed show];
    }
    }
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (void)sendtxtfile:(NSString *)txtString storyTitle:(NSString *)getSTitle chapterTitle:(NSString *)getCTitle getOption:(int)storyOption{
    
    [loader loadingmessage:@"submitting story"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    if (selectedGenre){

    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
        NSString *post = [NSString stringWithFormat: @"name=%@&chapter=%@&text=%@", getSTitle, getCTitle, txtString];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        NSString *fId = [[NSString alloc]init];
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"storyType"] isEqualToString:@"new"]){
            fId = 0;
        }else{
            fId = [[NSUserDefaults standardUserDefaults]objectForKey:@"fid"];
        }
        
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/uploadtext.php?userId=%@&lat=%@&long=%@&order=%d&weather=%d&open=%d&genre=%@&fid=%@", userId, lati, longi, 1, 0, storyOption, selectedGenre, fId ];
    
    NSMutableURLRequest *uploadStoryRequest = [[NSMutableURLRequest alloc] init];
    [uploadStoryRequest setURL:[NSURL URLWithString:fullURL]];
    [uploadStoryRequest setHTTPMethod:@"POST"];
    [uploadStoryRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadStoryRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [uploadStoryRequest setHTTPBody:postData];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *uploadStorySession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *uploadStoryTask = [uploadStorySession dataTaskWithRequest:uploadStoryRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
        NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"datastring %@", datastring);
        
            
            tweetFinished.type = CSAnimationTypeFadeIn;
            tweetFinished.delay = 0.0;
            tweetFinished.duration = 1.0;
            tweetFinished.hidden = false;
            [tweetFinished startCanvasAnimation];
        
        
        
        loader.hidden = TRUE;
        [loader.spinner stopAnimating];
        });
    }];
    
    [uploadStoryTask resume];
    }else{
        loader.hidden = TRUE;
        [loader.spinner stopAnimating];
        
        UIAlertView *noGenre = [[UIAlertView alloc] initWithTitle:Nil
                                                           message:@"You need to select a genre"
                                                          delegate:self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles: nil];
        [noGenre show];
    }
}

- (IBAction)finishedTweet:(id)sender{
    [self finishSubmitting];
}

- (void)finishSubmitting{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"newStorySave"];
    
    self.storyTitle.text = @"";
    self.chapterTitle.text = @"";
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    selectedGenre = nil;
    tweetFinished.hidden = true;
}

- (IBAction)tweetTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    
                    break;
                case SLComposeViewControllerResultDone:
                    [self finishSubmitting];
                    break;
                default:
                    break;
            }
        };
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Yes"])
    {
        [timer invalidate];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"newStorySave"];
        self.storyTitle.text = @"";
        self.storyBox.text = @"";
        self.chapterTitle.text = @"";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([title isEqualToString:@"resume"]){
        [self.storyBox setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"newStorySave"]];
        startStoryLabel.hidden = TRUE;
        [self startTimer];
    }else if([title isEqualToString:@"Unlock It!"]){
        [purchase getProductInfo:@"UNLOCKCLOSED99" productType:2];
    }else if([title isEqualToString:@"Not yet"]){
        [self.openSelect setSelectedSegmentIndex:0];
        openoption = 1;
    }
}

- (IBAction)back:(id)sender{
    selectedGenre = nil;
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void) getGenres{
    [loader loadingmessage:@"loading genres"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/genres.php?id=0";
    
    NSURLSession *genreSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *genreTask = [genreSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"datastring %@", datastring);
            NSError *error = nil;
            genreArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            if (genreArray.count > 0){
            self.genreTable.delegate = self;
            self.genreTable.dataSource = self;
            [self.genreTable reloadData];
            [scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            }else{
                UIAlertView *connection = [[UIAlertView alloc] initWithTitle:Nil
                                                                  message:@"Your internet connection is weak. Your story will auto save for you to submit when you have better signal."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles: nil];
                [connection show];
            }
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
        });
    }];
    [genreTask resume];
}

#pragma mark - Table view setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return genreArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"GenreCell" bundle:nil];
    [self.genreTable registerNib:nib forCellReuseIdentifier:@"genreReuse"];
    self.genreTable.backgroundColor = [UIColor clearColor];
    self.genreTable.separatorColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.3];
    genreRow = [self.genreTable dequeueReusableCellWithIdentifier:@"genreReuse" forIndexPath:indexPath];
    genreRow.backgroundColor = [UIColor clearColor];
    NSDictionary *item = [genreArray objectAtIndex:indexPath.row];
    NSString *genreName = [item objectForKey:@"genre_name"];
    genreRow.genreLabel.text = [genreName uppercaseString];
    genreRow.genreLabel.textColor = [UIColor whiteColor];
    
    NSString *currentRowId = [item objectForKey:@"genre_id"];
    
    if([selectedGenre isEqualToString: currentRowId])
    {
        genreRow.accessoryType = UITableViewCellAccessoryCheckmark;
        genreRow.selected = YES;
    }
    else
    {
        genreRow.accessoryType = UITableViewCellAccessoryNone;
        genreRow.selected = NO;
    }
    
    return genreRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [genreArray objectAtIndex:indexPath.row];
    selectedGenre = [item objectForKey:@"genre_id"];

    
    [self.genreTable reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.storyBox resignFirstResponder];
    [self.storyTitle resignFirstResponder];
    [self.chapterTitle resignFirstResponder];
}

- (void)configureScrollView {
    CGSize size = scrollContent.bounds.size;
    scrollContent.frame = CGRectMake(0, 0, size.width, size.height);
    [scrollView addSubview:scrollContent];
    scrollView.contentSize = size;
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = NO;
    //scrollView.scrollEnabled = NO;
    // If you don't use self.contentView anywhere else, clear it here.
    scrollContent = nil;
    [self.view insertSubview:loader aboveSubview:scrollView];
    loader.hidden = TRUE;
}

- (IBAction)home:(id)sender{
    if (self.storyBox.text.length > 25){
        UIAlertView *yousure = [[UIAlertView alloc] initWithTitle:Nil
                                                             message:@"This story has not been submitted. Are you sure you want to leave?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                                   otherButtonTitles: @"Yes", nil];
        [yousure show];
    }else{
        [timer invalidate];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (IBAction)showPrompt:(id)sender{
    UIAlertView *showprompt = [[UIAlertView alloc] initWithTitle:Nil
                                                         message:[[NSUserDefaults standardUserDefaults] objectForKey:@"prompt"]
                                                     delegate:self
                                            cancelButtonTitle:@"Hide"
                                            otherButtonTitles: nil];
    [showprompt show];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    startStoryLabel.hidden = TRUE;
    int newStoryBoxHeight;
    if([[UIScreen mainScreen] bounds].size.height == 568){
        newStoryBoxHeight = 165;
    }else{
        newStoryBoxHeight = 100;
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.storyBox setFrame:CGRectMake(self.storyBox.frame.origin.x, self.storyBox.frame.origin.y, self.storyBox.frame.size.width, newStoryBoxHeight)];
    }completion:^(BOOL done){
    }];
    
    [self startTimer];
}

- (void)startTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerCalled) userInfo:nil repeats:YES];
}

-(void)timerCalled
{
    [[NSUserDefaults standardUserDefaults] setObject:self.storyBox.text forKey:@"newStorySave"];
    NSLog(@"saved text %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"newStorySave"]);
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
        [self.storyBox setFrame:CGRectMake(self.storyBox.frame.origin.x, self.storyBox.frame.origin.y, self.storyBox.frame.size.width, newStoryBoxHeight)];
    }completion:^(BOOL done){
    }];
    [timer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated{
    self.storyBox.text = @"";
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"storyType"] isEqualToString:@"new"])
    {
        self.chapterTitle.hidden = FALSE;
        featuredPromptButton.hidden = TRUE;
    }else{
        self.chapterTitle.hidden = TRUE;
        featuredPromptButton.hidden = FALSE;
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [cLocationManager startUpdatingLocation];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"newStorySave"]){
        UIAlertView *savedStory = [[UIAlertView alloc] initWithTitle:Nil
                                                             message:@"There's a story saved. Do you want to resume this story or start a new one?"
                                                            delegate:self
                                                   cancelButtonTitle:@"start new"
                                                   otherButtonTitles: @"resume", nil];
        [savedStory show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    loader = [[LoadingView alloc]init];
    purchase = [[PurchaseItem alloc]init];
    
    /*if([[UIScreen mainScreen] bounds].size.height != 568){
        [self.storyBox setFrame:CGRectMake(self.storyBox.frame.origin.x, self.storyBox.frame.origin.y, self.storyBox.frame.size.width, self.storyBox.frame.size.height - 75)];
        [startStoryLabel setFrame:CGRectMake(startStoryLabel.frame.origin.x, startStoryLabel.frame.origin.y -20, startStoryLabel.frame.size.width, startStoryLabel.frame.size.height)];
        [finishStoryButton setFrame:CGRectMake(finishStoryButton.frame.origin.x, finishStoryButton.frame.origin.y -85, finishStoryButton.frame.size.width, finishStoryButton.frame.size.height)];
        [genreGradientBox setFrame:CGRectMake(genreGradientBox.frame.origin.x, genreGradientBox.frame.origin.y, genreGradientBox.frame.size.width, genreGradientBox.frame.size.height - 75)];
        [self.genreTable setFrame:CGRectMake(genreGradientBox.frame.origin.x, 0, genreGradientBox.frame.size.width, genreGradientBox.frame.size.height)];
        [submitStoryButton setFrame:CGRectMake(submitStoryButton.frame.origin.x, submitStoryButton.frame.origin.y -85, submitStoryButton.frame.size.width, submitStoryButton.frame.size.height)];
        [cLengthAlert setFrame:CGRectMake(cLengthAlert.frame.origin.x, cLengthAlert.frame.origin.y -85, cLengthAlert.frame.size.width, cLengthAlert.frame.size.height)];
    }*/
    
    [scrollView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [scrollContent setFrame:CGRectMake(0, 0, screenWidth*2, screenHeight)];
    [editView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [genreView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    
    self.storyBox.layoutManager.delegate = self;
    self.storyBox.keyboardType = UIKeyboardTypeASCIICapable;
    self.chapterTitle.keyboardType = UIKeyboardTypeASCIICapable;
    self.storyTitle.keyboardType = UIKeyboardTypeASCIICapable;
    UIFont *font = [UIFont fontWithName:@"Heiti SC" size:12];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.openSelect setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [editView addGestureRecognizer:singleTap];
    
    [self configureScrollView];
    openoption = 1;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = genreGradientBox.bounds;
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
    genreGradientBox.layer.mask = gradient;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closedUnlocked)
                                                 name:@"UNLOCKCLOSED99" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self.storyBox resignFirstResponder];
    [self.chapterTitle resignFirstResponder];
    [self.storyTitle resignFirstResponder];
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
