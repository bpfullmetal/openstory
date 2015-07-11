//
//  FeedRow.h
//  openStory
//
//  Created by Brandon Phillips on 6/28/15.
//  Copyright (c) 2015 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedRow : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *feedRowView;
@property (nonatomic, weak) IBOutlet UILabel *feedRowAuthor;
@property (nonatomic, weak) IBOutlet UILabel *feedRowDetails;
@property (nonatomic, weak) IBOutlet UILabel *feedRowDate;
@property (nonatomic, weak) IBOutlet UIImageView *feedRowUser;

@end
