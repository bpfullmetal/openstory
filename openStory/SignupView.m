//
//  SignupView.m
//  openStory
//
//  Created by Brandon Phillips on 2/8/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "SignupView.h"
#import "UIImageView+WebCache.h"

@interface SignupView ()

@end

@implementation SignupView


#pragma mark - Login

- (IBAction)forgotUser:(id)sender{
    UIAlertView *alertUser = [[UIAlertView alloc]
                          initWithTitle:@"Enter the e-mail address associated with your account and your username will be sent to you."
                          message:nil
                          delegate:self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles:@"Request Username", nil ];
    
    alertUser.alertViewStyle = UIAlertViewStylePlainTextInput;
    forgotUserEmailField = [alertUser textFieldAtIndex:0];
    forgotUserEmailField.keyboardType = UIKeyboardTypeDefault;
    forgotUserEmailField.placeholder = @"Email Address";
    forgotUserEmailField.secureTextEntry = NO;
    
    [alertUser show];
}

- (IBAction)forgotPass:(id)sender{
    UIAlertView *alertPass = [[UIAlertView alloc]
                              initWithTitle:@"Enter the e-mail address associated with your account or your username to request a password reset."
                              message:nil
                              delegate:self
                              cancelButtonTitle: @"Cancel"
                              otherButtonTitles:@"Request Password Reset", nil ];
    
    alertPass.alertViewStyle = UIAlertViewStylePlainTextInput;
    forgotPasswordField = [alertPass textFieldAtIndex:0];
    forgotPasswordField.keyboardType = UIKeyboardTypeDefault;
    forgotPasswordField.placeholder = @"Email Address or Username";
    forgotPasswordField.secureTextEntry = NO;
    
    [alertPass show];
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

- (void)textViewDidBeginEditing:(UITextView *)textView{
    bioLabel.hidden = TRUE;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (bio.text.length == 0){
        bioLabel.hidden = FALSE;
    }else{
        bioLabel.hidden = TRUE;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Request Username"]){
        [self forgotUserNameQuery];
    }
    if([title isEqualToString:@"Request Password Reset"]){
        [self forgotPasswordQuery];
    }
    if([title isEqualToString:@"Submit"]){
        [self sendSuggestion];
    }
}

- (void)forgotUserNameQuery{
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/forgotusername.php"];
    
    NSString *post = [NSString stringWithFormat: @"info=%@", forgotUserEmailField.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *forgotUsernameRequest = [[NSMutableURLRequest alloc] init];
    
    [forgotUsernameRequest setURL:[NSURL URLWithString:fullURL]];
    [forgotUsernameRequest setHTTPMethod:@"POST"];
    [forgotUsernameRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [forgotUsernameRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [forgotUsernameRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *forgotUserSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *forgotUserTask = [forgotUserSession dataTaskWithRequest:forgotUsernameRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data string: %@", datastring);
            int dataNumber = [datastring intValue];
            switch (dataNumber)
            
            {
                case 1:
                {
                    UIAlertView *emailFormat = [[UIAlertView alloc] initWithTitle:Nil
                                                                        message:@"This is not in email format."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles: nil];
                    [emailFormat show];
                }
                    break;
                case 2:
                {
                    UIAlertView *noEmail = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message:@"We can't seem to find your email address in our records!"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles: nil];
                    [noEmail show];
                }
                    break;
                    
                case 3:
                {
                    UIAlertView *userSent = [[UIAlertView alloc] initWithTitle:Nil
                                                                      message:@"We have sent you an email with your username information!"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles: nil];
                    [userSent show];
                    
                }
                    break;
                    
                default:
                {
                    
                }
                    break;
                    
            }
            
        });
    }];
    
    [forgotUserTask resume];
}

- (void)forgotPasswordQuery{
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/forgotpassword.php";
    
    NSString *post = [NSString stringWithFormat: @"info=%@", forgotPasswordField.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *forgotPasswordRequest = [[NSMutableURLRequest alloc] init];
    
    [forgotPasswordRequest setURL:[NSURL URLWithString:fullURL]];
    [forgotPasswordRequest setHTTPMethod:@"POST"];
    [forgotPasswordRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [forgotPasswordRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [forgotPasswordRequest setHTTPBody:postData];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *forgotPassSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *forgotPassTask = [forgotPassSession dataTaskWithRequest:forgotPasswordRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int dataNumber = [datastring intValue];
            switch (dataNumber)
            
            {
                case 1:
                {
                    UIAlertView *noEmail = [[UIAlertView alloc] initWithTitle:Nil
                                                                          message:@"We can't seem to find your user information in our records!"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Ok"
                                                                otherButtonTitles: nil];
                    [noEmail show];
                }
                    break;
                case 2:
                {
                    UIAlertView *passSent = [[UIAlertView alloc] initWithTitle:Nil
                                                                      message:@"Your temporary password has been emailed to you!"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles: nil];
                    [passSent show];
                }
                    break;
                    
                default:
                {
                    
                }
                    break;
                    
            }
            
        });
    }];
    
    [forgotPassTask resume];
}

- (IBAction)loginSubmit:(id)sender{
    
    [self resignAll];
    
    [loader loadingmessage:@"logging in"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *userLogin = [NSString stringWithFormat:@"%@",loginUser.text];
    NSString *userPass = [NSString stringWithFormat:@"%@",loginPass.text];
    liresponse.hidden = TRUE;
    
    if (userLogin.length < 1 || userPass.length < 1){
        loader.hidden = TRUE;
        [loader.spinner stopAnimating];
        [liresponse setText:[NSString stringWithFormat: @"username and password can't be blank"]];
        liresponse.hidden = FALSE;
    }else{

    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/login.php";
    
        NSString *post = [NSString stringWithFormat: @"loginfo=%@&pass=%@&token=%@", userLogin, userPass, token];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSMutableURLRequest *loginRequest = [[NSMutableURLRequest alloc] init];
        
        [loginRequest setURL:[NSURL URLWithString:fullURL]];
        [loginRequest setHTTPMethod:@"POST"];
        [loginRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [loginRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [loginRequest setHTTPBody:postData];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *loginSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDataTask *loginTask = [loginSession dataTaskWithRequest:loginRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data string: %@", datastring);
            int dataNumber = [datastring intValue];
            switch (dataNumber)
            
            {
                case 0:
                {
                    [liresponse setText:[NSString stringWithFormat: @"incorrect user info or password"]];
                    liresponse.hidden = FALSE;
                }
                    break;
                case 1:
                {
                    [self submitToken:@"1"];
                }
                    break;
                    
                default:
                {
                    
                }
                    break;
                    
            }
            
        });
    }];
    
    [loginTask resume];
    }
    
}

- (void)submitToken:(NSString *)login{
    
    NSString *userEmail = signupEmail.text;
    if ([login isEqualToString:@"1"]){
        userEmail = loginUser.text;
    }
    NSString *post = [NSString stringWithFormat: @"email=%@", userEmail];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/getuserinfo.php";
        
        NSMutableURLRequest *userinfoRequest = [[NSMutableURLRequest alloc] init];
        
        [userinfoRequest setURL:[NSURL URLWithString:fullURL]];
        [userinfoRequest setHTTPMethod:@"POST"];
        [userinfoRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [userinfoRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [userinfoRequest setHTTPBody:postData];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *userInfoSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDataTask *userinfoTask = [userInfoSession dataTaskWithRequest:userinfoRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
    
                NSError *error = nil;
       
                NSArray *userInfoArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                NSDictionary *json = [userInfoArray objectAtIndex:0];
    [[NSUserDefaults standardUserDefaults]setObject:[json objectForKey:@"id"] forKey:@"user id"];
    [[NSUserDefaults standardUserDefaults]setObject:[json objectForKey:@"username"] forKey:@"user name"];
                userID = [json objectForKey:@"id"];
                
                NSLog(@"id: %@", [[NSUserDefaults standardUserDefaults]objectForKey:@"user id"]);
    if([json objectForKey:@"id"]){
        NSLog(@"id: %@", [json objectForKey:@"id"]);
        NSData *sendToken = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/sendtoken.php?id=%@&token=%@", [json objectForKey:@"id"], token]]];
        if(sendToken){
            // TOKEN SENT
        }
    }
                if ([login isEqualToString:@"1"]){
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"gotUserId" object:self];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    loginUser.text = @"";
                    loginPass.text = @"";
                }else if ([login isEqualToString:@"0"]){
                    [self getGenres];
                }
    
            });
        }];
    [userinfoTask resume];
}


#pragma mark - Signup

- (IBAction)submitSignup: (id)sender{
    
    [self resignAll];
    
    [loader loadingmessage:@"creating account"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *suUser = [NSString stringWithFormat:@"%@",signupUsername.text];
    NSString *suEmail = [NSString stringWithFormat:@"%@",signupEmail.text];
    NSString *suPass = [NSString stringWithFormat:@"%@",signupPassword.text];
    
    suUserResponse.hidden = TRUE;
    suPassResponse.hidden = TRUE;
    suEmailResponse.hidden = TRUE;
    suresponse.hidden = TRUE;
    
    NSString *post = [NSString stringWithFormat: @"user=%@&email=%@&pass=%@&token=%@", suUser, suEmail, suPass, token];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    if(suPass.length >= 8 && suUser.length >= 8 && suEmail > 0){
    
    NSString *fullURL = @"http://www.fullmetalworkshop.com/openstory/signup.php";
        
        NSMutableURLRequest *uploadSignupRequest = [[NSMutableURLRequest alloc] init];
        
        [uploadSignupRequest setURL:[NSURL URLWithString:fullURL]];
        [uploadSignupRequest setHTTPMethod:@"POST"];
        [uploadSignupRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [uploadSignupRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [uploadSignupRequest setHTTPBody:postData];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *signupSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDataTask *signupTask = [signupSession dataTaskWithRequest:uploadSignupRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            int dataNumber = [datastring intValue];
            NSLog(@"%d",dataNumber);
            switch (dataNumber)
            
            {
                case 0:
                {
                    loader.hidden = TRUE;
                    [loader.spinner stopAnimating];
                    
                    [suresponse setText:[NSString stringWithFormat: @"you've already signed up."]];
                    suresponse.hidden = FALSE;
                }
                    break;
                case 1:
                {
                    loader.hidden = TRUE;
                    [loader.spinner stopAnimating];
                    
                    [suUserResponse setText:[NSString stringWithFormat: @"this username already exists."]];
                    suUserResponse.hidden = FALSE;
                }
                    break;
                    
                case 2:
                {
                    loader.hidden = TRUE;
                    [loader.spinner stopAnimating];
                    
                    [suEmailResponse setText:[NSString stringWithFormat: @"Invalid Email Address"]];
                    suEmailResponse.hidden = FALSE;
                }
                    break;
                    
                case 3:
                {
                    [self submitToken:@"0"];
                }
                    break;
                    
                case 4:
                {
                    loader.hidden = TRUE;
                    [loader.spinner stopAnimating];
                    
                    [suresponse setText:[NSString stringWithFormat: @"Something went wrong!"]];
                    suresponse.hidden = FALSE;
                }
                    break;
                    
                default:
                {
                    
                }
                    break;
                    
            }
        });
    }];
    
    [signupTask resume];
    }else{
        loader.hidden = TRUE;
        [loader.spinner stopAnimating];
        
        if(suPass.length < 8){
            [suPassResponse setText:[NSString stringWithFormat: @"Password should be at least 8 characters"]];
            suPassResponse.hidden = FALSE;
        }
        if(suUser.length < 8){
            [suUserResponse setText:[NSString stringWithFormat: @"Username should be at least 8 characters"]];
            suUserResponse.hidden = FALSE;
        }
        if(suEmail.length < 1){
            [suEmailResponse setText:[NSString stringWithFormat: @"We need your email to send user info"]];
            suEmailResponse.hidden = FALSE;
        }
    }
}


#pragma mark - Genres


- (void) getGenres{
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/genres.php?id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    NSURLSession *genreSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *genreTask = [genreSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data string: %@", datastring);
            genreArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            
            self.genreTable.delegate = self;
            self.genreTable.dataSource = self;
            self.genreTable.userInteractionEnabled = YES;
            [self.genreTable reloadData];
            
            loader.hidden = TRUE;
            [loader.spinner stopAnimating];
            
            [signupScroll setContentOffset:CGPointMake(640, 0) animated:YES];
            
        });
    }];
    selectedGenres = [[NSMutableArray alloc]init];
    [genreTask resume];
}

- (IBAction)suggestGenre:(id)sender{
    
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
    NSString * encodedString = [suggestionField.text
                                stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *fullURL = [NSString stringWithFormat: @"http://www.fullmetalworkshop.com/openstory/suggestgenre.php?id=%@&genre=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"], encodedString];
    
    NSURLSession *suggestGenreSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *suggestGenreTask = [suggestGenreSession dataTaskWithURL:[NSURL URLWithString:fullURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"data string: %@", fullURL);
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

- (IBAction)login:(id)sender{
    [self resignAll];
    [signupScroll setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)signup:(id)sender{
    [self resignAll];
    [signupScroll setContentOffset:CGPointMake(320, 0) animated:YES];
}

- (void)configureScrollView {
    CGSize size = scrollContent.bounds.size;
    scrollContent.frame = CGRectMake(0, 0, size.width, size.height);
    [signupScroll addSubview:scrollContent];
    signupScroll.contentSize = size;
    signupScroll.delegate = self;
    signupScroll.alwaysBounceVertical = NO;
    
    // If you don't use self.contentView anywhere else, clear it here.
    scrollContent = nil;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
        [signupScroll setContentOffset:CGPointMake(320, 0) animated:NO];
    }
    
    [self.view insertSubview:loader aboveSubview:signupScroll];
    loader.hidden = TRUE;
    //load up stories
    
    // If you use it elsewhere, clear it in `dealloc` and `viewDidUnload`.
}

- (IBAction)skipGenre:(id)sender{
    [signupScroll setContentOffset:CGPointMake(960, 0) animated:YES];
}

- (IBAction)submitGenres:(id)sender{
    [loader loadingmessage:@"submitting genres"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSMutableArray *genreDictionArray = [[NSMutableArray alloc]init];
    NSString *uId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]];
    
    for(NSString *gString in selectedGenres){
        NSDictionary *genreDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            gString, @"genre",
                                            uId, @"user",
                                            @"1", @"action",
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
        
        NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"data string: %@", datastring);
        [signupScroll setContentOffset:CGPointMake(960, 0) animated:NO];
        });
    }];
    
    [postDataTask resume];
}

- (IBAction)skipBio:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)submitBio:(id)sender{
    [loader loadingmessage:@"submitting bio"];
    loader.hidden = FALSE;
    [loader.spinner startAnimating];
    
    NSString *bioText = bio.text;
    NSString *siteText = site.text;
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
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"website\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[siteText dataUsingEncoding:NSUTF8StringEncoding]];
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
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        });
        
    }];
    
    [uploadBioTask resume];
}

#pragma mark - Table view setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return genreArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"GenreCell" bundle:nil];
    [self.genreTable registerNib:nib forCellReuseIdentifier:@"genreReuse"];
    genreRow = [self.genreTable dequeueReusableCellWithIdentifier:@"genreReuse" forIndexPath:indexPath];
    genreRow.backgroundColor = [UIColor clearColor];
    NSDictionary *item = [genreArray objectAtIndex:indexPath.row];
    genreRow.genreLabel.text = [[item objectForKey:@"genre_name"] uppercaseString];
    self.genreTable.separatorColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.3];
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
        [selectedGenres removeObject:genreId];
    }else{
        [selectedGenres addObject:genreId];
    }
    
    [self.genreTable reloadData];
    NSLog(@"selected genres: %@", selectedGenres);
}

- (IBAction)addPhoto:(id)sender{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"startCam" object:self];
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
            
            [userImage setImage:image];
            
            
            userImage.contentMode = UIViewContentModeScaleAspectFill;
            userImage.clipsToBounds = YES;
            [userImage.layer setCornerRadius:42];
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

- (void)placeImage:(UIImage *)image{
    [userImage setImage:image];
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imagePicker = [[UIImagePickerController alloc]init];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;

    loader = [[LoadingView alloc]init];
    
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
    
    token = [[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    
    UITapGestureRecognizer *bioTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [bioView addGestureRecognizer:bioTap];
    
    UITapGestureRecognizer *signupTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [signupView addGestureRecognizer:signupTap];
    
    UITapGestureRecognizer *loginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    
    [loginView addGestureRecognizer:loginTap];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 7.0){
    }else{
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    self.genreTable.backgroundColor = [UIColor clearColor];
    self.genreTable.rowHeight = 44;
    [scrollContent setFrame:CGRectMake(0, 0, screenWidth*4, screenHeight)];
    [loginView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [signupView setFrame:CGRectMake(screenWidth, 0, screenWidth, screenHeight)];
    [genreView setFrame:CGRectMake(screenWidth*2, 0, screenWidth, screenHeight)];
    [bioView setFrame:CGRectMake(screenWidth*3, 0, screenWidth, screenHeight)];
    
    NSLog(@"scroll view height: %f", signupScroll.frame.size.height);
    [self updateViewConstraints];
    [self configureScrollView];

    // Do any additional setup after loading the view from its nib.
    NSLog(@"load");

}

- (void)viewDidAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"user id"]){
        [self dismissViewControllerAnimated:NO completion:nil];
    }else{
        [signupScroll setContentOffset:CGPointMake(320, 0) animated:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 140;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == signupUsername){
        int limit = 20;
        return !([textField.text length]>limit && [string length] > range.length);
    }else if(textField == signupPassword || textField == loginPass){
        int limit = 50;
        return !([textField.text length]>limit && [string length] > range.length);
    }else if(textField == loginUser){
        int limit = 200;
        return !([textField.text length]>limit && [string length] > range.length);
    }
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self resignAll];
    
    return YES;
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    NSLog(@"tapped");
    [self resignAll];
}

- (void)resignAll{
    [bio resignFirstResponder];
    [site resignFirstResponder];
    [signupUsername resignFirstResponder];
    [signupEmail resignFirstResponder];
    [signupPassword resignFirstResponder];
    [loginUser resignFirstResponder];
    [loginPass resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
