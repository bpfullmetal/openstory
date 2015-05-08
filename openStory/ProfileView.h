//
//  ProfileView.h
//  openStory
//
//  Created by Brandon Phillips on 7/11/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseItem.h"

@interface ProfileView : UIViewController<UITextViewDelegate, NSLayoutManagerDelegate, UIAlertViewDelegate>{
    NSDictionary *profileItem;

    IBOutlet UIButton *twitterNameButton;
    IBOutlet UIButton *userStoriesButton;
    IBOutlet UILabel *profileAuthor;
    PurchaseItem *purchase;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UITextView *profileBio;
- (void)makeProfile: (NSString *)uid type: (int)type;
    
@end
