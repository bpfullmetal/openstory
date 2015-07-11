//
//  HomeView.m
//  openStory
//
//  Created by Brandon Phillips on 2/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "HomeView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "CCAlertView.h"
#import <CSAnimationView.h>

@interface HomeView ()

@end

@implementation HomeView

@synthesize tableOfContents;
@synthesize feedTable;

#pragma mark - Selected User From Likes

- (void)goToSelectedUser{
    if (likesBox.likesBoxView.hidden == FALSE){
        [self closeLikesBox];
    }
    [self getAllStories:selectedUser];
    [self profileBoxSlideDown];
}

#pragma mark - Get Stories of Selected  User

- (void)getAllStories:(NSString *)userId{
    
    [loader loadingmessage:@"getting stories"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getuserstories.php?user=%@",userId];
    
    NSURLSession *storySession = [NSURLSession sharedSession];
    NSURLSessionDataTask *storyTask = [storySession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            storyArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            if (storyArray.count > 0){
                [self divideStories];
                [scrollView setContentOffset:CGPointMake(screenWidth * 2, 0) animated:YES];
            }else{
                loader.hidden = TRUE;
                [loader.spinner stopAnimating];
                if (allStoriesLoadType == 1){
                    
                    if (selectedUser == userID){
                        CCAlertView *alert = [[CCAlertView alloc]
                                          initWithTitle:nil
                                          message:@"You have no stories. Start a new one?"];
                        [alert addButtonWithTitle:@"Yeah!" block:^{
                        [[NSUserDefaults standardUserDefaults]setObject:@"new" forKey:@"storyType"];
                        [self.navigationController pushViewController:startStoryView animated:YES];
                        }];
                        [alert addButtonWithTitle:@"Cancel" block:NULL];
                        [alert show];
                    }else{
                        CCAlertView *alert = [[CCAlertView alloc]
                                              initWithTitle:nil
                                              message:@"This user doesn't have any stories yet."];
                        [alert addButtonWithTitle:@"Yeah!" block:^{
                            [[NSUserDefaults standardUserDefaults]setObject:@"new" forKey:@"storyType"];
                            [self.navigationController pushViewController:startStoryView animated:YES];
                        }];
                        [alert addButtonWithTitle:@"Cancel" block:NULL];
                        [alert show];
                    }
                    
                }else if(allStoriesLoadType == 2){
                    [scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
                }
            }
            
        });
    }];
    
    [storyTask resume];
    
}

#pragma mark - Setup Scroll


- (void)divideStories{
    yourArray = [[NSMutableArray alloc]init];
    yourFeaturedArray = [[NSMutableArray alloc]init];
    contributedArray = [[NSMutableArray alloc]init];
    closedArray = [[NSMutableArray alloc]init];
    
    for (NSDictionary *item in storyArray){
        if([[item objectForKey:@"own_story"] isEqualToString:@"1"] && ([[item objectForKey:@"story_status"]isEqualToString:@"1"] )){
            [yourArray addObject:item];
        }else if([[item objectForKey:@"own_story"] isEqualToString:@"1"] && [[item objectForKey:@"story_status"]isEqualToString:@"2"]){
            [yourFeaturedArray addObject:item];
        }else if([[item objectForKey:@"own_story"] isEqualToString:@"1"] && [[item objectForKey:@"story_status"]isEqualToString:@"0"]){
            [closedArray addObject:item];
        }else{
            [contributedArray addObject:item];
        }
    }
    NSURLSession *getUsernameSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *getUsernameTask = [getUsernameSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getusername.php?uid=%@",selectedUser]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *username = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [userProfileUsernameLabel setText:username];
        });
    }];
    
    [getUsernameTask resume];
    [self setupStoryScroll:yourArray];
}

- (IBAction)startedButton:(id)sender{
    if( typeSwitch != 1){
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyScrollBox setTransform:CGAffineTransformMakeTranslation(0, 568)];
    }completion:^(BOOL done){
    [self setupStoryScroll:yourArray];
        storyType.text = @"OPEN STORIES";
        typeSwitch = 1;
    }];
    }
}

- (IBAction)closedStoriesButton:(id)sender{
    NSArray *featuresArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
    if ([featuresArray containsObject:@"UNLOCKCLOSED99"]){
        if (typeSwitch != 4){
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
                [storyScrollBox setTransform:CGAffineTransformMakeTranslation(0, 568)];
            }completion:^(BOOL done){
                [self setupStoryScroll:closedArray];
                storyType.text = @"CLOSED STORIES";
                typeSwitch = 4;
            }];
        }
    }else{
        
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"Writing closed stories is a paid feature. Get it now?"];
        [alert addButtonWithTitle:@"Yes!" block:^{[purchase getProductInfo:@"UNLOCKCLOSED99" productType:2];}];
        [alert addButtonWithTitle:@"No" block:NULL];
        [alert show];
    }
    
}

- (IBAction)contributedButton:(id)sender{
    if (typeSwitch != 2){
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyScrollBox setTransform:CGAffineTransformMakeTranslation(0, 568)];
    }completion:^(BOOL done){
    [self setupStoryScroll:contributedArray];
        storyType.text = @"COLLABORATIVE STORIES";
        typeSwitch = 2;
    }];
    }
}

- (IBAction)featuredButton:(id)sender{
    if (typeSwitch != 3){
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyScrollBox setTransform:CGAffineTransformMakeTranslation(0, 568)];
    }completion:^(BOOL done){
        [self setupStoryScroll:yourFeaturedArray];
        storyType.text = @"DAILY STORIES";
        typeSwitch = 3;
    }];
    }
}

- (void)setupStoryScroll:(NSMutableArray*)array{
    
    [storyScrollContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [storyScrollContent removeFromSuperview];
    for (UIView *subview in colorBox.subviews) {
        [subview removeFromSuperview];
    }
    int countstories = (int)array.count;
    int storyIndicatorWidth = self.view.bounds.size.width / countstories;

    CGSize size = CGRectMake(320, 0, countstories*320, storyScrollView.frame.size.height).size;
    storyScrollContent.frame = CGRectMake(0, 0, size.width, size.height);
    
    int storyCounter = 0;
    for (NSDictionary *item in array){
        NSArray *colorarray = [[item objectForKey:@"story_color"] componentsSeparatedByString:@","];
        UIView *colorBlock = [[UIView alloc]initWithFrame:CGRectMake(storyIndicatorWidth*storyCounter, 0, storyIndicatorWidth, colorBox.frame.size.height)];
        CGRect innerBlockRect = CGRectMake(colorBlock.frame.size.width/10, colorBlock.frame.size.height/2, colorBlock.frame.size.width*.8, colorBlock.frame.size.height/2);
        
        if(storyCounter == 0){
            innerBlockRect = CGRectMake(colorBlock.frame.size.width/10, 0, colorBlock.frame.size.width*.8, colorBlock.frame.size.height);
        }
        UIButton *innerColorButton = [[UIButton alloc]initWithFrame:innerBlockRect];
        
        //UIView *innerColorBlock = [[UIView alloc]initWithFrame:innerBlockRect];
        if(colorarray.count > 1){
            innerColorButton.backgroundColor = [UIColor colorWithRed:([colorarray[0] floatValue]/255.0) green:([colorarray[1] floatValue]/255.0) blue:([colorarray[2] floatValue]/255.0) alpha:0.3];
            //innerColorBlock.backgroundColor = [UIColor colorWithRed:([colorarray[0] floatValue]/255.0) green:([colorarray[1] floatValue]/255.0) blue:([colorarray[2] floatValue]/255.0) alpha:0.3];
        }
        [colorBlock addSubview:innerColorButton];
        //[colorBlock addSubview:innerColorBlock];
        [colorBox addSubview:colorBlock];
        UIView *storyBox = [[UIView alloc]initWithFrame:CGRectMake((storyCounter+1)*320, 0, 320, size.height)];
        [storyScrollContent addSubview:storyBox];
        CGRectMake(storyCounter*320, 0, 320, size.height);
        storyBox.frame = CGRectMake((storyCounter)*320, 0, 320, size.height);
        
        [innerColorButton addTarget:self
                        action:@selector(scrollToStory:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [innerColorButton setTag:storyCounter];
        /*NSString *statusText = [[NSString alloc]init];
        if([[item objectForKey:@"own_story"] isEqualToString:@"1"]){
            statusText = @"YOURS";
        }else{
            statusText = @"NOT YOURS";
        } */
        
        
        UIButton *storyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, size.height)];
        int buttonId = (int)[[item objectForKey:@"story_id"]integerValue];
        [storyButton setTag:buttonId];
        if([[item objectForKey:@"own_story"] isEqualToString:@"1"] && [[item objectForKey:@"story_status"] isEqualToString:@"0"] && [[item objectForKey:@"story_user"] isEqualToString:userID]){
            [storyButton addTarget:self
                            action:@selector(closedStory:)
                  forControlEvents:UIControlEventTouchUpInside];

        }else{
        [storyButton addTarget:self
                   action:@selector(getSenderId:)
         forControlEvents:UIControlEventTouchUpInside];
        }
        storyButton.titleLabel.textColor = [UIColor whiteColor];
        storyButton.alpha = 0.7;
    
        UILabel *storyTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 304, 30)];
        storyTitleLabel.textAlignment = NSTextAlignmentCenter;
        
        storyTitleLabel.textColor = [UIColor whiteColor];
        storyTitleLabel.alpha = 0.6;
        storyTitleLabel.text = [[item objectForKey:@"story_name"]uppercaseString];
        [storyTitleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:16.0]];
        [storyTitleLabel setMinimumScaleFactor:0.5];
        storyTitleLabel.adjustsFontSizeToFitWidth = TRUE;
        
        UILabel *storyDate = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, 320, 30)];
        storyDate.textAlignment = NSTextAlignmentCenter;
        storyDate.textColor = [UIColor whiteColor];
        storyDate.text = [[item objectForKey:@"story_date"] uppercaseString];
        [storyDate setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        storyDate.alpha = 0.6;
        
        UILabel *storyGenre = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 320, 30)];
        storyGenre.textAlignment = NSTextAlignmentCenter;
        storyGenre.textColor = [UIColor whiteColor];
        storyGenre.text = [[item objectForKey:@"story_genre"] uppercaseString];
        [storyGenre setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        storyGenre.alpha = 0.6;
        
        [storyBox addSubview:storyDate];
        [storyBox addSubview:storyGenre];
        [storyBox addSubview:storyTitleLabel];
        [storyBox addSubview:storyButton];
        

        storyCounter++;
    }
    
    /*[aCell.itemImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.operationcmyk.com/phonetag/arsenalImages/%@_arsenal.png", [item objectForKey:@"id"]]]placeholderImage:nil
                             options:0
                            progress:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               
                           }];*/
    
    userProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    userProfileImage.clipsToBounds = YES;
    [userProfileImage.layer setCornerRadius:35];
    [userProfileImage.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", selectedUser]];
    [userProfileImage setImageWithURL:ImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
    }];
    [storyScrollView addSubview:storyScrollContent];
     storyScrollView.contentSize = size;
     storyScrollView.delegate = self;
        [self finishStoryScroll];
    
}

-(IBAction)scrollToStory:(id)sender{
    UIButton *temp = sender;
    int value = (int)temp.tag;
        [storyScrollView setContentOffset:CGPointMake(value * screenWidth, 0) animated:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (sender == storyScrollView){
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(storyScrollFinishedScrolling) withObject:nil afterDelay:0.1];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollerView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)storyScrollFinishedScrolling{
    float scrollX = storyScrollView.contentOffset.x;
    int colorBlockIndex = scrollX / self.view.frame.size.width;
    
    int currentBlock = 0;
    for (UIView *subview in colorBox.subviews) {
        UIView *innerView = [subview.subviews objectAtIndex:0];
        if(colorBlockIndex == currentBlock){
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
                [innerView setFrame:CGRectMake(subview.frame.size.width/10, 0, subview.frame.size.width*.8, subview.frame.size.height)];
            }completion:^(BOOL done){
            }];
        }else{
            if(innerView.frame.size.height == subview.frame.size.height){
                [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
                    [innerView setFrame:CGRectMake(subview.frame.size.width/10, subview.frame.size.height/2, subview.frame.size.width*.8, subview.frame.size.height/2)];
                }completion:^(BOOL done){
                }];
            }
        }
        currentBlock++;
    }
}

- (void)finishStoryScroll{
    loader.hidden = TRUE;
    [loader.spinner stopAnimating];
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyScrollBox setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }completion:^(BOOL done){
    }];
    if (scrollView.contentOffset.x != screenWidth * 2){
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [scrollView setContentOffset:CGPointMake(screenWidth * 2, 0) animated:NO];
        }completion:^(BOOL done){
        }];
        
    }
}

#pragma mark - Load Table Of Contents

- (void) getSenderId:(id)sender{
    UIButton *temp = sender;
    int value = (int)temp.tag;
    [self loadThisStory:value storyType:1];
}

- (void) closedStory:(id)sender{
    UIButton *temp = sender;
    int value = (int)temp.tag;
    selectedUser = userID;
    selectedStory = [NSString stringWithFormat:@"%d", value];
    NSArray *filtered = [closedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(story_id == %@)", selectedStory]];
    NSDictionary *closedItem = [filtered objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults]setObject:[closedItem objectForKey:@"story_name"] forKey:@"addChapterTitle"];
    
    
    [self.navigationController pushViewController:addChapterView animated:YES];
}

- (void) loadThisStory:(int)sid storyType:(int)type{
    
    [loader loadingmessage:@"loading story"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    publishStory.hidden = TRUE;
    buyButton.hidden = TRUE;
    pdfButton.hidden = TRUE;
    
    if(type == 1){
        currentStoryArray = storyArray;
    }
    //else if(type == 2){
      //  currentStoryArray = pullStoryArray;
    //}
    
    selectedStory = [NSString stringWithFormat:@"%d", sid];
    //[scrollView setContentOffset:CGPointMake(640, 0) animated:YES];
    NSDictionary *item = [[NSDictionary alloc]init];
    if (type == 1){
    NSArray *filtered = [currentStoryArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(story_id == %@)", selectedStory]];
    item = [filtered objectAtIndex:0];
    [storyNameLabel setText:[[item objectForKey:@"story_name"]uppercaseString]];
    }
    
    if(type == 3){
        [storyNameLabel setText:[mapStoryName uppercaseString]];
    }
    
    NSURLSession *getChapterSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *chapTask = [getChapterSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getchapters.php?story=%@",selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_sync(dispatch_get_main_queue(), ^{
            
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            chapterArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        
            if([[item objectForKey:@"story_status"]intValue] == 2){ // DAILY STORY
                storyswitch = 2;
                for (NSDictionary *dsItem in chapterArray){
                    selectedChapter = [dsItem objectForKey:@"chapter_id"];
                }
                
                [self showChapterText:0];
            }else if([[item objectForKey:@"story_status"]intValue] == 0 && type !=3){ // CLOSED STORY
                for (NSDictionary *dsItem in chapterArray){
                    selectedChapter = [dsItem objectForKey:@"chapter_id"];
                    [[NSUserDefaults standardUserDefaults]setObject:[item objectForKey:@"story_name"] forKey:@"addChapterTitle"];
                }
                
                [self.navigationController pushViewController:addChapterView animated:YES];
            }else{ // OPEN STORY
                tableOfContents.delegate = self;
                tableOfContents.dataSource = self;
                selectedChapterOrder = [NSString stringWithFormat:@"%d", (int)chapterArray.count];
                [tableOfContents reloadData];
                if (loadMapStorySwitch == 1){
                    [scrollView setContentOffset:CGPointMake(screenWidth*3, 0) animated:NO];
                }else{
                  [scrollView setContentOffset:CGPointMake(screenWidth*3, 0) animated:YES];
                }
                storyswitch = 1;
                NSMutableArray *idList = [[NSMutableArray alloc]init];

                for (NSDictionary *cItem in chapterArray){
                    [idList addObject:[cItem objectForKey:@"chapter_user"]];
                }

                    if(chapterArray.count > 1 && [[item objectForKey:@"complete"] isEqualToString: @"0"] && [selectedUser isEqualToString:userID]){
                        publishStory.hidden = FALSE;
                    }else if([[item objectForKey:@"complete"] isEqualToString: @"1"] && [selectedUser isEqualToString:userID] && [[item objectForKey:@"purchased"] intValue] != 1){
                        buyButton.hidden = FALSE;
                    }else if([[item objectForKey:@"complete"] isEqualToString: @"1"] && [selectedUser isEqualToString:userID] && [[item objectForKey:@"purchased"] intValue] == 1 ){
                        pdfButton.hidden = FALSE;
                    }
                [loader.spinner stopAnimating];
                loader.hidden = TRUE;
            }
        });
    }];
    
    [chapTask resume];
}

- (IBAction)publishStory:(id)sender{
    
    CCAlertView *alert = [[CCAlertView alloc]
                          initWithTitle:nil
                          message:@"Are you sure you want to publish this story? No additional chapters can be added once a story is published."];
    [alert addButtonWithTitle:@"Publish story" block:^{[self markComplete];}];
    [alert addButtonWithTitle:@"Cancel" block:NULL];
    [alert show];
    
}

- (void)markComplete{
    NSURLSession *publishSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *publishTask = [publishSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/publishstory.php?sid=%@", selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([datastring intValue] == 1){
                buyButton.hidden = FALSE;
                publishStory.hidden = TRUE;
            }
        });
    }];
    
    [publishTask resume];
}

- (IBAction)buyStory:(id)sender{
    NSString *userPoints = [[NSUserDefaults standardUserDefaults] objectForKey:@"userpoints"];
    NSString *storyPoints = [[NSUserDefaults standardUserDefaults] objectForKey:@"storypoints"];
    
    if ([userPoints intValue] >= [storyPoints intValue]){
    NSString *post = [NSString stringWithFormat: @"uid=%@&sid=%@&points=%@", userID, selectedStory, storyPoints];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/buystory.php";
    
    NSMutableURLRequest *buystoryRequest = [[NSMutableURLRequest alloc] init];
    [buystoryRequest setURL:[NSURL URLWithString:fullURL]];
    [buystoryRequest setHTTPMethod:@"POST"];
    [buystoryRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [buystoryRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [buystoryRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *buystorySession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *buystoryTask = [buystorySession dataTaskWithRequest:buystoryRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *url = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/stories/%@", datastring];
            //url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[
                                                                     NSURL URLWithString:url]];
            
            // Store the Data locally as PDF File
            NSString *resourceDocPath = [[NSString alloc] initWithString:[
                                                                          [[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent]
                                                                          stringByAppendingPathComponent:@"Documents"
                                                                          ]];
            
            NSString *filePath = [resourceDocPath 
                                  stringByAppendingPathComponent:datastring];
            [pdfData writeToFile:filePath atomically:YES];
            NSURL *pdfUrl = [NSURL fileURLWithPath:filePath];
            docController = [UIDocumentInteractionController interactionControllerWithURL:pdfUrl];
            docController.delegate = self;
            
            //BOOL isValid = [docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
            
        });
    }];
    
    [buystoryTask resume];

    }else{
        
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"Are you sure you want to publish this story? No additional chapters can be added once a story is published."];
        [alert addButtonWithTitle:@"Get points" block:^{[self presentViewController:pointsView animated:YES completion:nil];}];
        [alert addButtonWithTitle:@"Cancel" block:NULL];
        [alert show];
    }
}

- (IBAction)viewPDF:(id)sender{
    
}

#pragma mark - Add Chapter

/*- (void)showStory{
    [self storyBoxSlideDown];
}

- (void)chapterUploaded{
    [self storyBoxSlideDown];
    showHideButton.hidden = TRUE;
    UIAlertView *submitted = [[UIAlertView alloc] initWithTitle:Nil
                                                        message:@"Your chapter has been added!"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
    [submitted show];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)storyUploaded{
    [self storyBoxSlideDown];
    showHideButton.hidden = TRUE;
}*/

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tableOfContents){
        return chapterArray.count;
    }else{
        return feedInfoArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 60;
    if (tableView == feedTable){
        height = 76;
    }
    return height;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == tableOfContents){ // IF THIS IS THE TABLE OF CONTENTS TABLE
    UINib *nib = [UINib nibWithNibName:@"ChapterRow" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"chapterRow"];
    chapRow = [tableView dequeueReusableCellWithIdentifier:@"chapterRow" forIndexPath:indexPath];
    chapRow.backgroundColor = [UIColor clearColor];
    NSDictionary *item = [chapterArray objectAtIndex:indexPath.row];
    chapRow.chapterRowName.text = [[item objectForKey:@"chapter_name"] uppercaseString];
        NSString *chapAuth = [item objectForKey:@"chapter_author"];
        chapRow.chapterRowAuthor.text = [chapAuth uppercaseString];
    //NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[item objectForKey:@"chapter_user_image"] options:0];
    chapRow.backgroundColor=[UIColor clearColor];
    [chapRow.chapterRowUser.layer setCornerRadius:25];
    [chapRow.chapterRowUser.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"chapter_user"]]];
    
    [chapRow.chapterRowUser sd_setImageWithURL:ImageURL placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];
    
    chapRow.chapterRowUser.contentMode = UIViewContentModeScaleAspectFill;
    chapRow.chapterRowUser.clipsToBounds = YES;
    
    UIButton *profileButton = [[UIButton alloc]initWithFrame:CGRectMake(261, 6, 50, 50)];
    
    [profileButton addTarget:self
                    action:@selector(viewProfile:)
          forControlEvents:UIControlEventTouchUpInside];
    
    int buttonId = [[item objectForKey:@"chapter_user"]intValue];
    
    [profileButton setTag:buttonId];
    [chapRow.storyRowView insertSubview:profileButton aboveSubview:chapRow.chapterRowUser];
    
    if ([deleteButton isDescendantOfView:chapRow.storyRowView]){
        [deleteButton removeFromSuperview];
    }
    if (([[item objectForKey:@"chapter_order"] intValue] == (int)chapterArray.count) && ([[item objectForKey:@"chapter_user"] isEqualToString: userID])){
        
        deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(184, 37, 69, 21)];
        [deleteButton setTitle:@"delete" forState:UIControlStateNormal];
        deleteButton.titleLabel.textColor = [UIColor whiteColor];
        deleteButton.titleLabel.alpha = 0.8;
        [deleteButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
        [deleteButton addTarget:self
                          action:@selector(deleteChapter:)
                forControlEvents:UIControlEventTouchUpInside];
        
        int buttonId = [[item objectForKey:@"chapter_id"]intValue];
        
        [deleteButton setTag:buttonId];
        [chapRow.storyRowView insertSubview:deleteButton aboveSubview:chapRow.chapterRowUser];
    }
        
        return chapRow;
        
    }else{ // TABLE VIEW IS FEED TABLE
        UINib *nib = [UINib nibWithNibName:@"FeedRow" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:@"feedRow"];
        feedRow = [tableView dequeueReusableCellWithIdentifier:@"feedRow" forIndexPath:indexPath];
        feedRow.backgroundColor = [UIColor clearColor];
        NSArray *sortedArray = [feedInfoArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj2 valueForKey:@"uDate"] compare:[obj1 valueForKey:@"uDate"]];
        }];
        NSDictionary *item = [sortedArray objectAtIndex:indexPath.row];
        feedRow.feedRowAuthor.text = [[item objectForKey:@"userName"]uppercaseString];
        if([[item objectForKey:@"userId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]){
            feedRow.feedRowAuthor.text = @"YOU";
        }
        
        if ([[item objectForKey:@"type"] isEqualToString: @"add"]){
           feedRow.feedRowDetails.text = [NSString stringWithFormat:@"Added a chapter called %@",[item objectForKey:@"chapterName"]];
        }else if([[item objectForKey:@"type"]  isEqualToString:@"like"]){
            if ([[item objectForKey:@"likeeId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]){
                feedRow.feedRowDetails.text = [NSString stringWithFormat:@"Liked your chapter: %@", [item objectForKey:@"chapterName"]];
            }else{
                feedRow.feedRowDetails.text = [NSString stringWithFormat:@"Liked %@'s chapter: %@", [item objectForKey:@"likeeName"], [item objectForKey:@"chapterName"]];
            }
        }
        
        NSString *feedDate = [item objectForKey:@"date"];
        feedRow.feedRowDate.text = [feedDate uppercaseString];
        //NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[item objectForKey:@"chapter_user_image"] options:0];
        feedRow.backgroundColor=[UIColor clearColor];
        [feedRow.feedRowUser.layer setCornerRadius:25];
        [feedRow.feedRowUser.layer setMasksToBounds:YES];
        NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"userId"]]];
        
        [feedRow.feedRowUser sd_setImageWithURL:ImageURL placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];
        
        feedRow.feedRowUser.contentMode = UIViewContentModeScaleAspectFill;
        feedRow.feedRowUser.clipsToBounds = YES;
        
        UIButton *profileButton = [[UIButton alloc]initWithFrame:CGRectMake(261, 6, 50, 50)];
        
        [profileButton addTarget:self
                          action:@selector(viewProfile:)
                forControlEvents:UIControlEventTouchUpInside];
        
        int buttonId = [[item objectForKey:@"userId"]intValue];
        
        [profileButton setTag:buttonId];
        [feedRow.feedRowView insertSubview:profileButton aboveSubview:feedRow.feedRowUser];
        
        return feedRow;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != feedTable){
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
    }
    
}

- (void)deleteChapter:(id)sender{
    UIButton *temp = sender;
    int cidint = (int)temp.tag;
    deleteChapterId = [NSString stringWithFormat:@"%d", cidint];
    UIAlertView *deleteChap = [[UIAlertView alloc] initWithTitle:Nil
                                                        message:@"Are you sure you want to delete this chapter? You won't be able to see it or share it once it's been deleted."
                                                       delegate:self
                                              cancelButtonTitle:@"No, keep it!"
                                              otherButtonTitles: @"Yes, delete it.", nil];
    [deleteChap show];
    
    CCAlertView *alert = [[CCAlertView alloc]
                          initWithTitle:nil
                          message:@"Are you sure you want to delete this chapter? You won't be able to see it or share it once it's been deleted."];
    [alert addButtonWithTitle:@"Yes, delete it." block:^{[self reallyDeleteChapter];}];
    [alert addButtonWithTitle:@"Cancel" block:NULL];
    [alert show];
}

- (void) viewProfileFromLikes{
    if (self.isViewLoaded && self.view.window) {
        [profileBoxView addSubview:userProfile.view];
        [userProfile makeProfile:selectedUser type:2];
        userProfile.profileBio.font = [UIFont fontWithName:@"Heiti SC" size:16.0];
        
        
        [self profileBoxSlideUp];
    }
}

- (IBAction)viewProfile:(id)sender{
    if (self.isViewLoaded && self.view.window) {
    UIButton *temp = sender;
    int uidint = (int)temp.tag;
    NSString *uid = [NSString stringWithFormat:@"%d", uidint];
    
    [profileBoxView addSubview:userProfile.view];
        [userProfile makeProfile:uid type: 1];
    [self profileBoxSlideUp];
    }
}

/*- (void)storyBoxSlideDown{
 
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    }completion:^(BOOL done){
        storyBoxView.hidden = TRUE;
    }];
}

- (void)storyBoxSlideUp{
    storyBoxView.hidden = FALSE;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [storyBoxView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }completion:^(BOOL done){
    }];
}*/

- (void)profileBoxSlideDown{
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    }completion:^(BOOL done){
        [[profileBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        profileBoxView.hidden = TRUE;
    }];
    
    /*[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
     [profileBoxView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
     }completion:^(BOOL done){
     }];*/
}

- (void)profileBoxSlideUp{
    profileBoxView.hidden = FALSE;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [profileBoxView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    }completion:^(BOOL done){
    }];
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
    [scrollView setContentOffset:CGPointMake(screenWidth*4, 0) animated:YES];
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"fid"];
    [self getLikes];
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

- (void)getLikes{
    [likesBox.view removeFromSuperview];
    [likesBox getChapterLikes];
    [chapterTextView insertSubview:likesBox.view atIndex:999];
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 10; // For really wide spacing; pick your own value
}

- (IBAction)dailyStory:(id)sender{
    [self.navigationController pushViewController:dailyStoryView animated:YES];
}


- (IBAction)startStory:(id)sender{
    [[NSUserDefaults standardUserDefaults]setObject:@"new" forKey:@"storyType"];
    [self.navigationController pushViewController:startStoryView animated:YES];
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

- (IBAction)settings:(id)sender{
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (IBAction)backHome:(id)sender{
    [scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
}

- (IBAction)backToStories:(id)sender{
        if (loadMapStorySwitch == 1){
            [scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:YES];
        }else{
            [scrollView setContentOffset:CGPointMake(screenWidth*2, 0) animated:YES];
        }
}

- (IBAction)backToChapters:(id)sender{
    if(storyswitch == 2){
         [scrollView setContentOffset:CGPointMake(screenWidth*2, 0) animated:YES];
    }else{
         [scrollView setContentOffset:CGPointMake(screenWidth*3, 0) animated:YES];
    }
}

- (IBAction)checkForStory:(id)sender{
    checkAtStart = 2;
    [self askForStory: 2];
}

- (IBAction)goToStory:(id)sender{
    selectedUser = userID;
    [self loadPulledStory];
}

- (IBAction)seeAllStories:(id)sender{
    allStoriesLoadType = 1;
    loadMapStorySwitch = 0;
    selectedUser = userID;
    [self getAllStories:userID];
    
}

#pragma mark - Get Server Story

- (void)askForStory:(int)startOrButton{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
        
        if (lati.length != 0 && longi.length != 0){
            
        NSURLSession *askSession = [NSURLSession sharedSession];
        NSURL *fullURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/pulldownstory.php?user=%@&lati=%@&longi=%@", userID, lati, longi]];
        NSURLSessionDataTask *askTask = [askSession dataTaskWithURL:fullURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //NSString *chapterText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                // MAIN THREAD
                //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSLog(@"data: %@", fullURL);
                pullStoryArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                
                int check = (int)[NSString stringWithFormat:@"%lu", (unsigned long)pullStoryArray.count].integerValue;
                if(check > 0){
                    storyCheck.hidden = TRUE;
                    gotStory.hidden = FALSE;
                    int safetyCheck = 1;
                    NSString *newStoryId;
                    for (NSDictionary *item in pullStoryArray){
                        if (safetyCheck == 1){
                            newStoryId = [item objectForKey:@"story_id"];
                        }
                        safetyCheck++;
                    }
                    
                    if (![newStoryId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"newPulledId"] ]){
                   
                        CCAlertView *alert = [[CCAlertView alloc]
                                              initWithTitle:nil
                                              message:@"You have a new story waiting for you! Check it out?"];
                                [alert addButtonWithTitle:@"Yes" block:^{
                                    [self askForPushNotes];
                                    [self loadPulledStory];
                                }];
                        [alert addButtonWithTitle:@"Not now" block:^{
                            [self askForPushNotes];
                        }];
                        [alert show];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:newStoryId forKey:@"newPulledId"];
                    
                }else{
                    storyCheck.hidden = FALSE;
                    gotStory.hidden = TRUE;
                    if (checkAtStart == 2){
                        
                        CCAlertView *alert = [[CCAlertView alloc]
                                              initWithTitle:nil
                                              message:@"There are no stories available to you right now, but check back soon!"];
                            [alert addButtonWithTitle:@"Ok" block:^{
                                [self askForPushNotes];
                            }];
                        [alert show];
                    }else{

                    }
                }
                
                // MAIN THREAD
            });
        }];
        
        [askTask resume];
    }
    }else{
        if (startOrButton == 1){
            
        }else{
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"We need your location to check for nearby stories. Go to settings and enable location access for Open Story"];
        [alert addButtonWithTitle:@"Ok" block:NULL];
        [alert show];
        }
    }
}

- (void)askForPushNotes{

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){ // PUSH NOTES ARE
            
        }else{
            CCAlertView *alert = [[CCAlertView alloc]
                                  initWithTitle:nil
                                  message:@"Enable push notifications to get automatic alerts about some awesome stories nearby!"];
            [alert addButtonWithTitle:@"Ok" block:^{
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }];
            [alert show];
            
        }
    }else{
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types == UIRemoteNotificationTypeAlert){ // PUSH NOTES ARE ENABLED
           
        }else{
            CCAlertView *alert = [[CCAlertView alloc]
                                  initWithTitle:nil
                                  message:@"Enable push notifications to get automatic alerts about some awesome stories nearby!"];
            [alert addButtonWithTitle:@"Ok" block:^{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            }];
            [alert show];
        }
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{

    NSString *tokenString = [deviceToken description];
    
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"got token %@", tokenString);
    if(tokenString){
        
        
        NSLog(@"sending it");
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
            NSData *sendtoken = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/sendtoken.php?token=%@&id=%@", tokenString, [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]]];
            if(sendtoken){
                //TOKEN SENT.
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Report"])
    {
        [self reportChapter];
    }
}

- (void)closedUnlocked{
    if (self.isViewLoaded && self.view.window) {
        
            UIAlertView *upgradedClosed = [[UIAlertView alloc] initWithTitle:Nil
                                                                       message:@"You can now write closed stories!"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cool!"
                                                             otherButtonTitles:  nil];
            [upgradedClosed show];
    }
}

- (void) reallySkipIt{
    NSURLSession *skipSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *skipTask = [skipSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/skipchapter.php?uid=%@&sid=%@", userID, selectedStory]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            loadMapStorySwitch = 0;
            [scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:YES];

        });
    }];
    
    [skipTask resume];
}

- (void) reallyDeleteChapter{
    [loader loadingmessage:@"deleting story"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    NSURLSession *deleteSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *deleteTask = [deleteSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/deletechapter.php?chapterid=%@", deleteChapterId]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSString *chapterText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        dispatch_sync(dispatch_get_main_queue(), ^{
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            allStoriesLoadType = 2;
            [self getAllStories:userID];
        });
    }];
    
    [deleteTask resume];
}

- (void)loadPulledStory{
    int safetyCheck = 1;
    for (NSDictionary *item in pullStoryArray){
        if (safetyCheck == 1){
        selectedUser = userID;
        selectedStory = [item objectForKey:@"story_id"];
            [[NSUserDefaults standardUserDefaults]setObject:[item objectForKey:@"story_name"] forKey:@"addChapterTitle"];
            
            
            //[self loadThisStory:selectedStory.intValue storyType:2];
        }
        safetyCheck++;
    }
    [self.navigationController pushViewController:addChapterView animated:YES];
}

- (void)loadMapStory{
    
    loadMapStorySwitch = 1;
            [self loadThisStory:selectedStory.intValue storyType:3];
}

- (IBAction)addPhoto:(id)sender{
    [self cameraPopup];
}

- (void)cameraPopup{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take Photo",
                            @"Choose From Library",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 2){
        
    }else{
    [self openImagePicker:buttonIndex];
    }
}

- (void) openImagePicker: (NSInteger)type{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        switch (type) {
            case 0:
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            default:
                break;
        }
        imagePicker.delegate = self;
        imagePicker.allowsEditing = TRUE;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
   
    UIImage *mask = [UIImage imageNamed:@"mask.png"];
    UIImage *newImage = [self maskImage:image withMask:mask];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/uploadphoto.php?user=%@", userID];
    
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
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n",@"userimage"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [uploadRequest setHTTPBody:body];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *uploadSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *uploadTask = [uploadSession dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{

            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];
            
            if (settingsView.isViewLoaded && settingsView.view.window) {
                [settingsView placeImage];
            }
            if (signup.isViewLoaded && signup.view.window) {
                [signup placeImage:newImage];
            }
            
            
            userImage.contentMode = UIViewContentModeScaleAspectFill;
            userImage.clipsToBounds = YES;
            [userImage.layer setCornerRadius:35];
            [userImage.layer setMasksToBounds:YES];
            
            NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", userID]];
            [userImage setImageWithURL:ImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image){
                    addUserPhoto.hidden = TRUE;
                }else{
                    addUserPhoto.hidden = FALSE;
                }
            }];
        });
    }];
    
    [uploadTask resume];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
}

#pragma mark - Initialize view

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getProfileImage{
    
    userImage.contentMode = UIViewContentModeScaleAspectFill;
    userImage.clipsToBounds = YES;
    [userImage.layer setCornerRadius:35];
    [userImage.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", userID]];
    [userImage setImageWithURL:ImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image){
            addUserPhoto.hidden = TRUE;
        }else{
            addUserPhoto.hidden = FALSE;
        }
    }];
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

- (void)unlockMap{

    [self.navigationController pushViewController:mapView animated:NO];
}

- (IBAction)goToMap:(id)sender{
    NSArray *featuresArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"allFeatures"];
    if ([featuresArray containsObject:@"UNLOCKMAP99"]){
        [self.navigationController pushViewController:mapView animated:NO];
    }else{
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"The map is a paid feature. Get it now?"];
        [alert addButtonWithTitle:@"Yes!" block:^{[purchase getProductInfo:@"UNLOCKMAP99" productType:2];}];
        [alert addButtonWithTitle:@"No" block:NULL];
        [alert show];
    }
    
}

- (IBAction)goToFeed:(id)sender{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self getFeed];
}

- (void)getFeed{
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getfeed.php?user=%@", userID];
    
    NSURLSession *feedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *feedTask = [feedSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            feedInfoArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            //NSDictionary *feedDictionary = [feedInfoArray objectAtIndex:0];
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data: %@", datastring);
            feedTable.delegate = self;
            feedTable.dataSource = self;
            [feedTable reloadData];
            //NSString *feed = [feedDictionary objectForKey:@"points"];
            //NSMutableArray *features = [[NSMutableArray alloc]initWithArray:[feedDictionary objectForKey:@"features"]];
            //[[NSUserDefaults standardUserDefaults]setObject:features forKey:@"allFeatures"];
            //[[NSUserDefaults standardUserDefaults] setObject:feed forKey:@"userpoints"];
            //[[NSUserDefaults standardUserDefaults] setObject:[feedDictionary objectForKey:@"storypoints"] forKey:@"storypoints"];
        });
    }];
    
    [feedTask resume];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    screenHeight = [[UIScreen mainScreen] bounds].size.height;
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    
    
    purchase = [[PurchaseItem alloc]init];
    startStoryView = [[StartStory alloc]initWithNibName:@"StartStory" bundle:nil];
    addChapterView = [[AddChapter alloc]initWithNibName:@"AddChapter" bundle:nil];
    signup = [[SignupView alloc]initWithNibName:@"SignupView" bundle:nil];
    tutorial = [[Tutorial alloc]initWithNibName:@"Tutorial" bundle:nil];
    termsAndConditions = [[TermsView alloc]initWithNibName:@"TermsView" bundle:nil];
    pointsView = [[PointsPurchaseView alloc]initWithNibName:@"PointsPurchaseView" bundle:nil];
    
    typeSwitch = 1;
    
    loader = [[LoadingView alloc]init];
    [self.view insertSubview:loader atIndex:99999];
    loader.hidden = TRUE;
    
    userProfile = [[ProfileView alloc]initWithNibName:@"ProfileView" bundle:nil];
    dailyStoryView = [[DailyStory alloc]initWithNibName:@"DailyStory" bundle:nil];
    
        [profileBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
        [scrollView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        [scrollContent setFrame:CGRectMake(0, 0, screenWidth*5, screenHeight)];
        [homeView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
        [authorView setFrame:CGRectMake(screenWidth*2, 0, screenWidth, screenHeight)];
        [tableOfContentsView setFrame:CGRectMake(screenWidth*3, 0, screenWidth, screenHeight)];
        [chapterTextView setFrame:CGRectMake(screenWidth*4, 0, screenWidth, screenHeight)];

        [scrollView setContentOffset:CGPointMake(screenWidth, 0) animated:NO];
        [self updateViewConstraints];
    
    likesBox = [[LikesView alloc]initWithNibName:@"LikesView" bundle:nil];
    [likesBox.view setFrame:CGRectMake(0, screenHeight - likesBox.likesBoxBottom.frame.size.height - 10, likesBox.view.frame.size.width, likesBox.likesBoxBottom.frame.size.height)];
    
    [profileBoxView setFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];

    [cLocationManager stopUpdatingLocation];
    
    mapView = [[MapStories alloc]initWithNibName:@"MapStories" bundle:nil];
    
    
    /*allStories.alpha = 0.4f;
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionAutoreverse
                     animations:^
     {
         [UIView setAnimationRepeatCount:10.0f];
         allStories.alpha = 0.8f;
     }
                     completion:^(BOOL finished)
     {
         
     }];*/
    
    storyScrollContent = [[UIView alloc]init];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToSelectedUser)
                                                 name:@"goToSelectedUser" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewProfileFromLikes)
                                                 name:@"showUserProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMapStory)
                                                 name:@"mapStoryChosen" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraPopup)
                                                 name:@"startCam" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileBoxSlideDown)
                                                 name:@"closeProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLikesBox)
                                                 name:@"showLikes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeLikesBox)
                                                 name:@"hideLikes" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unlockMap)
                                                 name:@"UNLOCKMAP99" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewProfileFromLikes)
                                                 name:@"UNLOCKUSERSTORIES99" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closedUnlocked)
                                                 name:@"UNLOCKCLOSED99" object:nil];
    
    settingsView = [[Settings alloc]initWithNibName:@"Settings" bundle:nil];
    imagePicker = [[UIImagePickerController alloc]init];
    tableOfContents.backgroundColor = [UIColor clearColor];
    
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
    
    feedTable.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *feedGradient = [CAGradientLayer layer];
    feedGradient.frame = tableMaskView.bounds;
    feedGradient.colors = [NSArray arrayWithObjects:
                       (__bridge id)UIColor.clearColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.whiteColor.CGColor,
                       UIColor.clearColor.CGColor,
                       nil];
    feedGradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:1.0/16],
                          [NSNumber numberWithFloat:15.0/16],
                          [NSNumber numberWithFloat:1],
                          nil];
    feedMaskView.layer.mask = feedGradient;
    
    
    
    //storyNameLabel = [[UILabel alloc]init];
    [self configureScrollView];
    
    
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0){
    }else{
        [self setNeedsStatusBarAppearanceUpdate];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    checkWeatherCount = 1;
    checkAtStart = 1;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
        
        [self.navigationController pushViewController:signup animated:NO];
    }else{
        
    }
}

- (void)loadFirstStuff{
    [cLocationManager startUpdatingLocation];
    [self getPoints];
    [self getProfileImage];
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"askForStory"] isEqualToString:@"1"]){
        [self askForStory: 1];
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"askForStory"];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
        userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
        userNameLabel.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user name"] uppercaseString];
        if (![[NSUserDefaults standardUserDefaults]objectForKey:@"tandc"]){
            [self.navigationController pushViewController:termsAndConditions animated:NO];
        }else{
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"readTutorial"]){
                [self.navigationController pushViewController:tutorial animated:NO];
            }
        }
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tandc"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"readTutorial"]){
            [self checkForLocation];
        }
    }
}

- (void)checkForLocation{
    if([CLLocationManager locationServicesEnabled]){
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            
            CCAlertView *alert = [[CCAlertView alloc]
                                  initWithTitle:nil
                                  message:@"To write and receive stories, Open Story needs access to your location!"];
            [alert addButtonWithTitle:@"Ok" block:^{
                [self askForLocation];
                }];
            [alert show];
        }else{
            NSLog(@"have location");
            [self loadFirstStuff];
        }
    }else{
        [self loadFirstStuff];
    }
}

- (void)askForLocation{
    NSLog(@"home view loc");
    cLocationManager = [[CLLocationManager alloc] init];
    cLocationManager.delegate = self;
    cLocationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    cLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // 5 m
    lati = [NSString stringWithFormat:@"%f", cLocationManager.location.coordinate.latitude];
    longi = [NSString stringWithFormat:@"%f", cLocationManager.location.coordinate.longitude];
    [cLocationManager stopUpdatingLocation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [cLocationManager requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways ){
        
        
        [self loadFirstStuff];
    }else if( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ){
        CCAlertView *alert = [[CCAlertView alloc]
                              initWithTitle:nil
                              message:@"Give Open Story access to your location in your settings to receive and write stories."];
        [alert addButtonWithTitle:@"Ok" block:^{
            [self loadFirstStuff];
        }];
        [alert show];
    }
}



- (void)getPoints{

    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getpoints.php?user=%@", userID];
    
    NSURLSession *pointsSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *pointsTask = [pointsSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            NSArray *pointsInfoArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            NSDictionary *pointsDictionary = [pointsInfoArray objectAtIndex:0];
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *points = [pointsDictionary objectForKey:@"points"];
            NSMutableArray *features = [[NSMutableArray alloc]initWithArray:[pointsDictionary objectForKey:@"features"]];
            [[NSUserDefaults standardUserDefaults]setObject:features forKey:@"allFeatures"];
            [[NSUserDefaults standardUserDefaults] setObject:points forKey:@"userpoints"];
            [[NSUserDefaults standardUserDefaults] setObject:[pointsDictionary objectForKey:@"storypoints"] forKey:@"storypoints"];
            [pointCount setTitle:points forState:UIControlStateNormal];
        });
    }];
    
    [pointsTask resume];
}

- (void)getMorePoints:(id)sender{
    [self presentViewController:pointsView animated:YES completion:nil];
}
/*
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    lati = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    longi = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    
    if(checkWeatherCount == 1){
        
    //NSData *weatherData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://api.worldweatheronline.com/free/v1/weather.ashx?q=%@%@%@&format=json&key=usr9t7cvmagb3csysgmgzdkw", lati, @"%2C", longi]]];
    //NSError *error = nil;
    //NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
    
   // NSDictionary *conditionsDictionary = [[jsonDictionary objectForKey:@"data"] objectForKey:@"current_condition"];
        //NSDictionary *weatherDescription = [conditionsDictionary objectForKey:@"weatherDesc"];
        
        //NSLog(@"jsonDictionary is: %@", jsonDictionary);
    
        
    }
    
    checkWeatherCount = checkWeatherCount + 1;
    
}*/



- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender{
    
    CCAlertView *alert = [[CCAlertView alloc]
                          initWithTitle:nil
                          message:@"Are you sure you want to log out?"];
    [alert addButtonWithTitle:@"Log out" block:^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *fileName = @"profilePic.jpg";
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath: filePath error:NULL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user id"];
        [self.navigationController pushViewController:signup animated:NO];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        
        }];
    [alert addButtonWithTitle:@"No" block:NULL];
    [alert show];
}

- (IBAction)reportStory:(id)sender{
    NSURLSession *reportCheckSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *reportCheckTask = [reportCheckSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/reportcheck.php?cid=%@&uid=%@", selectedChapter, userID]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (void)reportChapter{
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/reportchapter.php?uid=%@&cid=%@", userID, selectedChapter];
    
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
