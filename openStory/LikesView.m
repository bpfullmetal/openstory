//
//  LikesView.m
//  openStory
//
//  Created by Brandon Phillips on 6/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "LikesView.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface LikesView ()

@end

@implementation LikesView

@synthesize likesTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)likesTable:(NSArray *)array{
    likesArray = array;
    [self.likesTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return likesArray.count;
    NSLog(@"likes array count: %d", (int)likesArray.count);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINib *nib = [UINib nibWithNibName:@"LikesRow" bundle:nil];
    [self.likesTable registerNib:nib forCellReuseIdentifier:@"likes"];
    lRow = [self.likesTable dequeueReusableCellWithIdentifier:@"likes" forIndexPath:indexPath];
    lRow.backgroundColor = [UIColor clearColor];
    NSDictionary *item = [likesArray objectAtIndex:indexPath.row];
    NSLog(@"liking: %@", item);
    lRow.likesLabel.text = [[item objectForKey:@"likesUser"] uppercaseString];

    //NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[item objectForKey:@"chapter_user_image"] options:0];
    lRow.backgroundColor=[UIColor clearColor];
    [lRow.likesUserImage.layer setCornerRadius:15];
    [lRow.likesUserImage.layer setMasksToBounds:YES];
    NSURL *ImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/userimages/%@_userimage.jpg", [item objectForKey:@"liker"]]];
    [lRow.likesUserImage sd_setImageWithURL:ImageURL placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];
    
    
    lRow.likesUserImage.contentMode = UIViewContentModeScaleAspectFill;
    lRow.likesUserImage.clipsToBounds = YES;
    
    return lRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *item = [likesArray objectAtIndex:indexPath.row];
    NSLog(@"clicked");
    selectedUser = [item objectForKey:@"liker"];
    //NSString *chapterOrder = [item objectForKey:@"chapter_order"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserProfile" object:self];
    
}

- (IBAction)likeChapter:(id)sender{
    if(likeIt.alpha == 1.0 ){
        [self unlike];
    }else{
        [self like];
    }
}

- (void)like{
    NSURLSession *likeSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *likeTask = [likeSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/like.php?cid=%@&uid=%@&fid=0", selectedChapter, userID]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"like data: %@", datastring);
            [likeIt setBackgroundImage:[UIImage imageNamed:@"likeon.png"] forState:UIControlStateNormal];
            likeIt.alpha = 1.0;
            [self getChapterLikes];
        });
    }];
    
    [likeTask resume];
}

- (void)unlike{
    NSURLSession *unlikeSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *unlikeTask = [unlikeSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/unlike.php?cid=%@&uid=%@", selectedChapter, userID]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [likeIt setBackgroundImage:[UIImage imageNamed:@"likeoff.png"] forState:UIControlStateNormal];
            likeIt.alpha = 0.4;
            [self getChapterLikes];
        });
    }];
    
    [unlikeTask resume];
}

- (IBAction)showLikesBox:(id)sender{
    if (likesArray.count > 0 && self.likesBoxView.hidden == TRUE){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showLikes" object:self];
    }
}

- (IBAction)closeLikes:(id)sender{
    NSLog(@"closing");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideLikes" object:self];
}

- (void)getChapterLikes{
    userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"user id"];
    NSURLSession *likesSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *likesTask = [likesSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.fullmetalworkshop.com/openstory/getlikes.php?id=%@", selectedChapter]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSError *error = nil;
            likesArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
            likeCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)likesArray.count];
            NSLog(@"likesArray: %@", likesArray);
            for(NSDictionary *item in likesArray){
                
                if ([[item objectForKey:@"liker"] isEqualToString:userID]){
                    [likeIt setBackgroundImage:[UIImage imageNamed:@"likeon.png"] forState:UIControlStateNormal];
                    likeIt.alpha = 1.0;
                }
            }
            [self.likesTable reloadData];
        });
    }];
    
    [likesTask resume];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
