//
//  LikesView.h
//  openStory
//
//  Created by Brandon Phillips on 6/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikesRow.h"

@interface LikesView : UIViewController<UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate>{
    
    LikesRow *lRow;
    IBOutlet UIButton *showLikes;
    IBOutlet UIButton *closeLikesButton;
    IBOutlet UIButton *likeIt;
    IBOutlet UILabel *likeCount;
}

@property (nonatomic, weak) IBOutlet UITableView *likesTable;
@property (nonatomic, weak) IBOutlet UIView *likesBoxView;
@property (nonatomic, weak) IBOutlet UIView *likesBoxBottom;

- (void)getChapterLikes;

- (IBAction)likeChapter:(id)sender;
- (IBAction)closeLikes:(id)sender;
- (IBAction)showLikesBox:(id)sender;

@end
