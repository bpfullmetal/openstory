//
//  LikesRow.h
//  openStory
//
//  Created by Brandon Phillips on 6/1/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikesRow : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *likesRowView;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UIImageView *likesUserImage;

@end
