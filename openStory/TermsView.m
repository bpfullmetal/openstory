//
//  TermsView.m
//  openStory
//
//  Created by Brandon Phillips on 7/14/14.
//  Copyright (c) 2014 Full Metal Workshop. All rights reserved.
//

#import "TermsView.h"

@interface TermsView ()

@end

@implementation TermsView

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 5; // For really wide spacing; pick your own value
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

- (IBAction)agreeToTerms:(id)sender{
    if (agreed == FALSE){
        NSLog(@"agreeing");
        agreeBackground.image = [UIImage imageNamed:@"agreeClicked.png"];
        enterApp.alpha = 1.0;
        enterApp.userInteractionEnabled = TRUE;
        agreed = TRUE;
    }else{
        agreeBackground.image = [UIImage imageNamed:@"agreeEmpty.png"];
        enterApp.alpha = 0.4;
        enterApp.userInteractionEnabled = FALSE;
        agreed = FALSE;
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"tandc"];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults]objectForKey:@"tandc"]);
    }
}

- (IBAction)enterApp:(id)sender{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"tandc"];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"readTutorial"]){
        [self.navigationController pushViewController:tutorialView animated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //access your request
    acceptView.alpha = 1.0;
    acceptView.userInteractionEnabled = TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *fullURL = @"http://fullmetalworkshop.com/openstory/terms/";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [termsWeb setBackgroundColor:[UIColor clearColor]];
    [termsWeb setOpaque:NO];
    [termsWeb loadRequest:requestObj];
    termsWeb.scrollView.showsVerticalScrollIndicator = NO;
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"tandc"] isEqualToString:@"1"]){
        agreeBackground.image = [UIImage imageNamed:@"agreeClicked.png"];
        enterApp.alpha = 1.0;
        enterApp.userInteractionEnabled = TRUE;
        agreed = TRUE;
    }else{
        agreeBackground.image = [UIImage imageNamed:@"agreeEmpty.png"];
        enterApp.alpha = 0.4;
        enterApp.userInteractionEnabled = FALSE;
        agreed = FALSE;
    }
    
    tutorialView = [[Tutorial alloc]initWithNibName:@"Tutorial" bundle:nil];
    
    agreeButton = FALSE;
    termsText.layoutManager.delegate = self;
    agreeText.layoutManager.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
