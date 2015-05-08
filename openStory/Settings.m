//
//  Settings.m
//  openStory
//
//  Created by Brandon Phillips on 2/21/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "Settings.h"
#import "UIImageView+WebCache.h"

@interface Settings ()

@end

@implementation Settings

// SIDE NAV

- (IBAction)closeSettings:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    [self selectCurrentMenuItem:1];
}

- (void)hideSideNav{
    [self replaceLeftConstraintOnView:sideNav withConstant:-152];
}

- (void)selectCurrentMenuItem: (int)buttonID{
    editBioButton.alpha = 1.0;
    changePasswordButton.alpha = 1.0;
    updateGenresButton.alpha = 1.0;
    changeUsernameButton.alpha = 1.0;
    switch (buttonID) {
        case 1:
            editBioButton.alpha = 0.6;
            break;
        case 2:
            changeUsernameButton.alpha = 0.6;
            break;
        case 3:
            changePasswordButton.alpha = 0.6;
            break;
        case 4:
            updateGenresButton.alpha = 0.6;
            break;
        default:
            break;
    }
}

- (IBAction)updateUserName:(id)sender{
    
    if (scrollView.contentOffset.x != 320){
        [scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            [self hideSideNav];
    }else{
            [self hideSideNav];
    }
    [self selectCurrentMenuItem:2];
}
- (IBAction)updateBio:(id)sender{
    if (scrollView.contentOffset.x != 0){
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self hideSideNav];
    }else{
            [self hideSideNav];
    }
    [self selectCurrentMenuItem:1];
}
- (IBAction)updateGenres:(id)sender{
    if (scrollView.contentOffset.x != 960){
            [self getGenres];
    }else{
            [self hideSideNav];
    }
    [self selectCurrentMenuItem:4];
}

- (IBAction)updatePassword:(id)sender{
    if (scrollView.contentOffset.x != 640){
        [scrollView setContentOffset:CGPointMake(640, 0) animated:YES];
            [self hideSideNav];
    }else{
            [self hideSideNav];
    }
    [self selectCurrentMenuItem:3];
}

- (IBAction)restorePurchases:(id)sender{
    purchase = [[PurchaseItem alloc]init];
    [purchase restorePreviousPurchases];
}

- (IBAction)termsAndCondiShawns:(id)sender{
    [self.navigationController pushViewController:condiShawns animated:YES];
}

- (IBAction)goToTutorial:(id)sender{
    [self.navigationController pushViewController:tutorialView animated:YES];
}

- (IBAction)backToMain:(id)sender{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)submitNameChange:(id)sender{
    [loader loadingmessage:@"updating username"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    [newusername resignFirstResponder];
    [userpass resignFirstResponder];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/changeusername.php?userId=%@",uid];
    
    NSString *post = [NSString stringWithFormat: @"user=%@&pass=%@", newusername.text, userpass.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *userRequest = [[NSMutableURLRequest alloc] init];
    
    [userRequest setURL:[NSURL URLWithString:fullURL]];
    [userRequest setHTTPMethod:@"POST"];
    [userRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [userRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [userRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *userSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *userTask = [userSession dataTaskWithRequest:userRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int type = datastring.intValue;
            switch (type) {
                case 1:{
                    UIAlertView *nameTaken = [[UIAlertView alloc] initWithTitle:Nil
                                                                       message:@"This name is taken. Try a different one!"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles: nil];
                    [nameTaken show];
                }
                    break;
                case 2:{
                    UIAlertView *badPassword = [[UIAlertView alloc] initWithTitle:Nil
                                                                        message:@"Your password is incorrect!"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles: nil];
                    [badPassword show];
                }
                    break;
                case 3:{
                    UIAlertView *nameChanged = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message:@"Your username has been changed!"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles: nil];
                    [nameChanged show];
                    [username setTitle:newusername.text forState:normal];
                    [[NSUserDefaults standardUserDefaults] setObject:newusername.text forKey:@"user name"];
                    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                }
                    break;
                default:
                    break;
            }
        });
    }];

    [userTask resume];
}

- (IBAction)submitBioChange:(id)sender{
    [loader loadingmessage:@"updating bio"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *bioText = bio.text;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/uploadbio.php?userId=%@", userId ];
    
    NSMutableURLRequest *uploadBioRequest = [[NSMutableURLRequest alloc] init];
    [uploadBioRequest setURL:[NSURL URLWithString:fullURL]];
    [uploadBioRequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [uploadBioRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bio\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[bioText dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [uploadBioRequest setHTTPBody:body];
    
    //NSLog(@"body is: %@", request);
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *uploadBioSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *uploadBioTask = [uploadBioSession dataTaskWithRequest:uploadBioRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
            UIAlertView *bioupdated = [[UIAlertView alloc] initWithTitle:Nil
                                                                 message:@"Your information has been updated."
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles: nil];
            [bioupdated show];
    
        });
        
    }];
    
    [uploadBioTask resume];
}

- (IBAction)submitPasswordChange:(id)sender{
    passwordAlert.hidden = true;
    if(newPass.text.length > 8){
        
    [loader loadingmessage:@"updating password"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    [oldPass resignFirstResponder];
    [newPass resignFirstResponder];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/changepassword.php?userId=%@",uid ];
    
    NSString *post = [NSString stringWithFormat: @"pass=%@&newpass=%@", oldPass.text, newPass.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *passwordRequest = [[NSMutableURLRequest alloc] init];
    
    [passwordRequest setURL:[NSURL URLWithString:fullURL]];
    [passwordRequest setHTTPMethod:@"POST"];
    [passwordRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [passwordRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [passwordRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *passwordSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *passwordTask = [passwordSession dataTaskWithRequest:passwordRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int type = datastring.intValue;
            switch (type) {
                case 1:{
                    UIAlertView *wrongPass = [[UIAlertView alloc] initWithTitle:Nil
                                                                        message:@"Incorrect password"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles: nil];
                    [wrongPass show];
                }
                    break;
                case 2:{
                    UIAlertView *passChanged = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message:@"Your password has been changed"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles: nil];
                    [passChanged show];
                    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                }
                    break;
                default:
                    break;
            }
        });
    }];
    
    [passwordTask resume];
    }else{
        passwordAlert.hidden = false;
    }
}

- (IBAction)submitGenreChange:(id)sender{
    [loader loadingmessage:@"loading"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSMutableArray *genreDictionArray = [[NSMutableArray alloc]init];
    NSString *uId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    for(NSString *gString in addedGenres){
        NSDictionary *genreDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                         gString, @"genre",
                                         uId, @"user",
                                         @"1", @"action",
                                         nil];
        [genreDictionArray addObject:genreDictionary];
    }
    
    for(NSString *gString in removedGenres){
        NSDictionary *genreDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                         gString, @"genre",
                                         uId, @"user",
                                         @"0", @"action",
                                         nil];
        [genreDictionArray addObject:genreDictionary];
    }
    
    NSLog(@"%@", genreDictionArray);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"http://www.fullmetalworkshop.com/openstory/receivegenres.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:genreDictionArray options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
        loader.hidden = TRUE;
        [loader.spinner stopAnimating];
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        });
    }];
    
    [postDataTask resume];
}

#pragma mark - PROFILE IMAGE

- (void)getProfileImage{
    /*NSLog(@"getting pic");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *fileName = @"profilePic.jpg";
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    if(!imageData){
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // 3
        NSString *imageUrl = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
        NSURLSession *session =
        [NSURLSession sessionWithConfiguration:sessionConfig
                                      delegate:self
                                 delegateQueue:nil];
        NSURLSessionDownloadTask *getImageTask =
        [session downloadTaskWithURL:[NSURL URLWithString:imageUrl]
         
                   completionHandler:^(NSURL *location,
                                       NSURLResponse *response,
                                       NSError *error) {
                       // 2
                       UIImage *downloadedImage =
                       [UIImage imageWithData:
                        [NSData dataWithContentsOfURL:location]];
                       if(!downloadedImage){
                           addUserPhoto.hidden = FALSE;
                       }
                       
                       
                       //3
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(downloadedImage){
                           NSLog(@"settings image");
                           UIImage *mask = [UIImage imageNamed:@"mask.png"];
                           NSLog(@"image size %f", mask.size.width);
                           UIImage *newImage = [self maskImage:downloadedImage withMask:mask];
                           userImage.contentMode = UIViewContentModeScaleAspectFill;
                           userImage.clipsToBounds = YES;
                           [userImage setImage:newImage];
                           NSLog(@"image width %f height %f", downloadedImage.size.width, downloadedImage.size.height);
                           }
                       });
                   }];
        
        // 4
        [getImageTask resume];
    }else{
        UIImage *profileImage = [UIImage imageWithData:imageData];
        UIImage *mask = [UIImage imageNamed:@"mask.png"];
        NSLog(@"image size %f", mask.size.width);
        UIImage *newImage = [self maskImage:profileImage withMask:mask];
        userImage.contentMode = UIViewContentModeScaleAspectFill;
        userImage.clipsToBounds = YES;
        [userImage setImage:newImage];
        [addUserPhoto setTitle:@"change photo" forState:UIControlStateNormal];
        NSLog(@"profile size %f, %f", profileImage.size.height, profileImage.size.width);
    }*/
    userImage.contentMode = UIViewContentModeScaleAspectFill;
    userImage.clipsToBounds = YES;
    [userImage.layer setCornerRadius:35];
    [userImage.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]]];
    [userImage setImageWithURL:ImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image){
            [addUserPhoto setTitle:@"change photo" forState:UIControlStateNormal];
        }else{
            [addUserPhoto setTitle:@"add image" forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)addPhoto:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCam" object:self];
}

- (void)placeImage{
    [self getProfileImage];
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

- (void)configureScrollView {
    CGSize size = scrollContent.bounds.size;
    scrollContent.frame = CGRectMake(0, 0, size.width, size.height);
    [scrollView addSubview:scrollContent];
    scrollView.contentSize = size;
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = NO;
    // If you don't use self.contentView anywhere else, clear it here.
    scrollContent = nil;
    
    [scrollView insertSubview:loader aboveSubview:sideNav];
    loader.hidden = TRUE;
    
    // If you use it elsewhere, clear it in `dealloc` and `viewDidUnload`.
}

#pragma mark - Table view setup

- (void) getGenres{
    [loader loadingmessage:@"loading"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/genres.php?id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    NSURLSession *genreSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *genreTask = [genreSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            genreArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            previouslySelectedGenres = [[NSMutableArray alloc]init];
            removedGenres = [[NSMutableArray alloc]init];
            selectedGenres = [[NSMutableArray alloc]init];
            addedGenres = [[NSMutableArray alloc]init];
            
            for(NSDictionary *item in genreArray){
                if([[item objectForKey:@"genre_check"] isEqualToString:@"on"]){
                    [previouslySelectedGenres addObject:[item objectForKey:@"genre_id"]];
                    [selectedGenres addObject:[item objectForKey:@"genre_id"]];
                }
            }
            
            self.genreTable.delegate = self;
            self.genreTable.dataSource = self;
            self.genreTable.backgroundColor = [UIColor clearColor];
            [self.genreTable reloadData];
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
                [scrollView setContentOffset:CGPointMake(960, 0) animated:YES];
                [self hideSideNav];
        });
    }];
    
    [genreTask resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return genreArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"GenreCell" bundle:nil];
    [self.genreTable registerNib:nib forCellReuseIdentifier:@"genreReuse"];
    genreRow = [self.genreTable dequeueReusableCellWithIdentifier:@"genreReuse" forIndexPath:indexPath];
    genreRow.backgroundColor = [UIColor clearColor];
    self.genreTable.separatorColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.3];
    NSDictionary *item = [genreArray objectAtIndex:indexPath.row];
    genreRow.genreLabel.text = [[item objectForKey:@"genre_name"] uppercaseString];
    
    NSString *currentRowId = [item objectForKey:@"genre_id"];
    
    if([selectedGenres containsObject:currentRowId])
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
    NSString *genreId = [item objectForKey:@"genre_id"];
    
    if ( [selectedGenres containsObject:genreId] ){
        if([previouslySelectedGenres containsObject:genreId]){
            [removedGenres addObject:genreId];
        }
        [selectedGenres removeObject:genreId];
        [addedGenres removeObject:genreId];
    }else{
        if([removedGenres containsObject:genreId]){
            [removedGenres removeObject:genreId];
        }
        if(![previouslySelectedGenres containsObject:genreId]){
            [addedGenres addObject:genreId];
        }
        [selectedGenres addObject:genreId];
    }
    
    [self.genreTable reloadData];
    NSLog(@"selected genres: %@", selectedGenres);
    NSLog(@"removed genres: %@", removedGenres);
    NSLog(@"added genres: %@", addedGenres);
}

- (void)getBio{
    [loader loadingmessage:@"loading"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/getbio.php?id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    NSURLSession *bioSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *bioTask = [bioSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            NSArray *bioArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            //NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            for(NSDictionary *item in bioArray){
                if(![[item objectForKey:@"bio"] isEqualToString:@""]){
                    bio.text = [item objectForKey:@"bio"];
                    bioPlaceholder.hidden = TRUE;
                }else{
                    bioPlaceholder.hidden = FALSE;
                }
                NSLog(@"item: %@", item);
                [loader.spinner stopAnimating];
                loader.hidden = TRUE;
            }
            
        });
    }];
    
    [bioTask resume];
}

#pragma mark - Suggest a genre

- (IBAction)suggestAGenre:(id)sender{
    
    UIAlertView *suggestionBox = [[UIAlertView alloc]
                                  initWithTitle:@"Enter a genre and click submit. We'll review your suggestion for consideration to add to our list. Thanks!"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle: @"Cancel"
                                  otherButtonTitles:@"Submit", nil ];
    
    suggestionBox.alertViewStyle = UIAlertViewStylePlainTextInput;
    suggestionField = [suggestionBox textFieldAtIndex:0];
    suggestionField.keyboardType = UIKeyboardTypeASCIICapable;
    suggestionField.placeholder = @"Genre Suggestion";
    suggestionField.secureTextEntry = NO;
    
    [suggestionBox show];
}

- (void)sendSuggestion{
    [loader loadingmessage:@"submitting suggestion"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString * encodedString = [suggestionField.text
                                stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/suggestgenre.php?id=%@&genre=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"], encodedString];
    
    NSURLSession *suggestGenreSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *suggestGenreTask = [suggestGenreSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([datastring isEqualToString:@"1"]){
                
                UIAlertView *suggestionSent = [[UIAlertView alloc]
                                               initWithTitle:@"Thanks for the suggestion! We'll look it over soon."
                                               message:nil
                                               delegate:self
                                               cancelButtonTitle: @"Ok"
                                               otherButtonTitles: nil ];
                
                [suggestionSent show];
                
            }else if([datastring isEqualToString:@"2"]){
                
                UIAlertView *alreadyThere = [[UIAlertView alloc]
                                             initWithTitle:@"It looks like your suggestion is already in the list."
                                             message:nil
                                             delegate:self
                                             cancelButtonTitle: @"Ok"
                                             otherButtonTitles: nil ];
                
                [alreadyThere show];
                
            }else{
                
                UIAlertView *unable = [[UIAlertView alloc]
                                       initWithTitle:@"We were unable to send your request. Try again later."
                                       message:nil
                                       delegate:self
                                       cancelButtonTitle: @"Ok"
                                       otherButtonTitles: nil ];
                
                [unable show];
                
            }
        });
    }];
    [suggestGenreTask resume];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Submit"]){
        [self sendSuggestion];
    }
}


- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [bio resignFirstResponder];
    [site resignFirstResponder];
    if(sideNav.frame.origin.x == -1){
        [self replaceLeftConstraintOnView:sideNav withConstant:-152];
        [self animateSlow];
    }else{
        [self replaceLeftConstraintOnView:sideNav withConstant:-1];
        [self animateSlow];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 140;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    int limit = 10;
    
    return !([textField.text length]>limit && [string length] > range.length);
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    bioPlaceholder.hidden = TRUE;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (bio.text.length == 0){
        bioPlaceholder.hidden = FALSE;
    }else{
        bioPlaceholder.hidden = TRUE;
    }
}

- (IBAction)twitterSwitchChanged:(id)sender{
    UISegmentedControl *segment=(UISegmentedControl*)sender;
    
    NSLog(@"sender: %@", segment);
    switch (segment.selectedSegmentIndex) {
        case 0:
            NSLog(@"5d selected. Index: %ld", (long)self.twitterSelect.selectedSegmentIndex);
            [self removeTwitter];
            break;
        case 1:
            NSLog(@"3m selected. Index: %ld", (long)self.twitterSelect.selectedSegmentIndex);
            [self addTwitter];
            break;
        default:
            break;
    }
}

- (void)addTwitter{
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [self.accountStore
                                         accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    
    dispatch_async(dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSArray *twitterAccounts = [self.accountStore
                                             accountsWithAccountType:twitterAccountType];
                 NSDictionary *item = [twitterAccounts objectAtIndex:0];
                 NSLog(@"twitter account info: %@", item);
                 NSDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:
                                           [twitterAccounts dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"username"]]];
                 NSDictionary *twitterIdDict = [[NSMutableDictionary alloc] initWithDictionary:
                                           [twitterAccounts dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]]];
                 NSArray *tempUsername = [tempDict objectForKey:@"username"];
                 NSArray *tempUserId = [twitterIdDict objectForKey:@"properties"];
                 NSString *twitterID = @"";
                 for (NSDictionary *tItem in tempUserId){
                     twitterID = [tItem objectForKey:@"user_id"];
                 }
                 [self sendTwitterId:twitterID sendTwitterName:tempUsername[0]];
             }
             else
             {
                 UIAlertView *nameTaken = [[UIAlertView alloc] initWithTitle:Nil
                                                                     message:@"We'll need access to your twitter account to display your twitter handle on your profile for your fans to see. Allow Open Story permission in your phones settings."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles: nil];
                 [nameTaken show];
                 self.twitterSelect.selectedSegmentIndex = 0;
             }
         }];
    });
}

- (void)sendTwitterId:(NSString*) twitterid sendTwitterName:(NSString*) twittername{
    [loader loadingmessage:@"adding twitter"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/sendtwitter.php?userId=%@&tid=%@&tname=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"], twitterid, twittername];
    
    NSURLSession *sendTwitterSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *sendTwitterTask = [sendTwitterSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:twittername forKey:@"twittername"];
            NSLog(@"twitter added %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"twittername"]);
            self.twitterSelect.selectedSegmentIndex = 1;
            twitterLabel.text = [twittername uppercaseString];
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
        });
    }];
    
    [sendTwitterTask resume];
}

- (void)removeTwitter{
    [loader loadingmessage:@"removing twitter"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/removetwitter.php?userId=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    NSURLSession *sendTwitterSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *sendTwitterTask = [sendTwitterSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"twittername"];
            NSLog(@"twitter removed %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"twittername"]);
            self.twitterSelect.selectedSegmentIndex = 0;
            twitterLabel.text = @"";
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
        });
    }];
    
    [sendTwitterTask resume];
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
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"something");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    tutorialView = [[Tutorial alloc]initWithNibName:@"Tutorial" bundle:nil];
    condiShawns = [[TermsView alloc]initWithNibName:@"TermsView" bundle:nil];
    
    loader = [[LoadingView alloc]init];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"]){
        self.twitterSelect.selectedSegmentIndex = 1;
        twitterLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
    }else{
        self.twitterSelect.selectedSegmentIndex = 0;
        twitterLabel.text = @"";
    }
    
    
    
    /*if([[UIScreen mainScreen] bounds].size.height != 568){
     
        [tableHolder setFrame:CGRectMake(tableHolder.frame.origin.x, tableHolder.frame.origin.y, tableHolder.frame.size.width, tableHolder.frame.size.height-90)];
        [self.genreTable setFrame:CGRectMake(self.genreTable.frame.origin.x, self.genreTable.frame.origin.y, self.genreTable.frame.size.width, self.genreTable.frame.size.height)];
        [suggestG setFrame:CGRectMake(suggestG.frame.origin.x, suggestG.frame.origin.y - 90, suggestG.frame.size.width, suggestG.frame.size.height)];
        [submitGenreButton setFrame:CGRectMake(submitGenreButton.frame.origin.x, submitGenreButton.frame.origin.y - 90, submitGenreButton.frame.size.width, submitGenreButton.frame.size.height)];
       
    }*/
    
    [scrollContent setFrame:CGRectMake(0, 0, screenWidth*4, screenHeight)];
    [bioView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [userView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [passwordView setFrame:CGRectMake(screenWidth*2, 0, screenWidth, screenHeight)];
    [genreView setFrame:CGRectMake(screenWidth*3, 0, screenWidth, screenHeight)];
    
    [self.view updateConstraints];
    [self replaceBottomConstraintOnView:submitBioButton withConstant:20];
    [self.view layoutIfNeeded];
    
    UITapGestureRecognizer *bioTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [bioView addGestureRecognizer:bioTap];
    
    UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [userView addGestureRecognizer:userTap];
    
    UITapGestureRecognizer *passwordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [passwordView addGestureRecognizer:passwordTap];
    
    UITapGestureRecognizer *slideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [sideNav addGestureRecognizer:slideTap];
    
    [self getBio];

    
     //[sideNav addGestureRecognizer:oneFingerSwipeRight];
     //[sideNav addGestureRecognizer:oneFingerSwipeLeft];
    
    
        
    
    [username setTitle:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user name"] uppercaseString] forState:normal];
    [self getProfileImage];
    [self configureScrollView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = tableHolder.bounds;
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
    tableHolder.layer.mask = gradient;
    
    // Do any additional setup after loading the view from its nib.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    if (CGRectContainsPoint([sideNavInner frame], touchLocation)) {
        isDragging = YES;
        
    } else {
        return;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (isDragging) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self.view];
        NSLog(@"dragging");
        if (sideNav.frame.origin.x >= -153 && sideNav.frame.origin.x < -75){
 [self replaceLeftConstraintOnView:sideNav withConstant:touchLocation.x - (sideNav.frame.size.width -10)];
            [self animateSettings];
        NSLog(@"touch: %f", screenWidth- touchLocation.x);
        }else if (sideNav.frame.origin.x >= -75 && sideNav.frame.origin.x <= 0){
 [self replaceLeftConstraintOnView:sideNav withConstant:touchLocation.x - (sideNav.frame.size.width -10)];
            [self animateSettings];
        }
        if (touchLocation.x > lastPoint.x){
            slideDirection = @"right";
        }else{
            slideDirection = @"left";
        }
        lastPoint.x = touchLocation.x;
        
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    if(sideNav.frame.origin.x >= 0 || [slideDirection isEqualToString: @"right"]){
        [self replaceLeftConstraintOnView:sideNav withConstant:-1];
        [self animateSettings];
    }else if (sideNav.frame.origin.x <= -153 || [slideDirection isEqualToString:@"left"]){
        [self replaceLeftConstraintOnView:sideNav withConstant:-152];
        [self animateSettings];
    }
    NSLog(@"frame origin: %f", sideNav.frame.origin.x);
}

- (void)replaceLeftConstraintOnView:(UIView *)view withConstant:(float)constant
{
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == view) && (constraint.firstAttribute == NSLayoutAttributeLeading)) {
            constraint.constant = constant;
            
        }
    }];
}

- (void)replaceBottomConstraintOnView:(UIView *)view withConstant:(float)constant
{
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == view) && (constraint.firstAttribute == NSLayoutAttributeBottom)) {
            constraint.constant = constant;
            [self.view layoutIfNeeded];
        }
    }];
}

- (void)animateSettings
{
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void)animateSlow
{
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
