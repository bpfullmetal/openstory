//
//  TermsView.h
//  openStory
//
//  Created by Brandon Phillips on 7/14/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tutorial.h"

@interface TermsView : UIViewController<NSLayoutManagerDelegate, UIWebViewDelegate>{
    
    Tutorial *tutorialView;
    
    BOOL agreed;
    IBOutlet UITextView *termsText;
    IBOutlet UIButton *agreeButton;
    IBOutlet UIImageView *agreeBackground;
    IBOutlet UIButton *enterApp;
    IBOutlet UITextView *agreeText;
    IBOutlet UIWebView *termsWeb;
    IBOutlet UIView *acceptView;
}

@end
