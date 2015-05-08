//
//  GenreCell.h
//  openStory
//
//  Created by Brandon Phillips on 2/18/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenreCell : UITableViewCell{

}
@property (nonatomic, strong) IBOutlet UIView *genreRowView;
@property (nonatomic, weak) IBOutlet UILabel *genreLabel;

@end
