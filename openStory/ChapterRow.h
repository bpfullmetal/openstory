//
//  ChapterRow.h
//  openStory
//
//  Created by Brandon Phillips on 2/9/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterRow : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *storyRowView;

@property (nonatomic, weak) IBOutlet UILabel *chapterRowName;
@property (nonatomic, weak) IBOutlet UILabel *chapterRowAuthor;
@property (nonatomic, weak) IBOutlet UIImageView *chapterRowUser;
//@property (nonatomic, weak) IBOutlet UIButton *chapterRowButton;

@end
