//
//  WikipediaSearchViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/19/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "WikipediaSearchViewController.h"
#import <ReactiveCocoa.h>

@interface WikipediaSearchViewController ()

@end

@implementation WikipediaSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    self.activityIndicator.hidden = YES;
    
    RACSubscribable *keys =
    [[[self.searchTextField
     rac_subscribableForControlEvents:UIControlEventEditingChanged]
     throttle:0.5] // seconds
     select:^id(UITextField *x) {
         return x.text;
     }];
    
    [[keys
      deliverOn:[RACScheduler mainQueueScheduler]]
      subscribeNext:^(NSString *searchText) {
          self.activityIndicator.hidden = NO;
          [self.activityIndicator startAnimating];
          self.searchingForLabel.text = [NSString stringWithFormat:@"Searching for ... %@", searchText];
          
          NSURLRequest *request = [NSURLRequest
                                   requestWithURL:[NSURL URLWithString:
                                                   [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", searchText]]];
          [self.webView loadRequest:request];
      }];
    
    [[keys
     deliverOn:[RACScheduler mainQueueScheduler]]
     subscribeNext:^(NSString *x) {
         NSLog(@"%@", x);
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [self setSearchingForLabel:nil];
    [self setWebView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

# pragma mark - UIWebViewDelegate 

- (void)stopAnimation {
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self stopAnimation];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self stopAnimation];
}

@end
