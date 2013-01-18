//
//  AFNetworkingViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 9/30/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "AFNetworkingViewController.h"
#include <ReactiveCocoa.h>
#include "Api.h"
#import <WBErrorNoticeView.h>

@interface AFNetworkingViewController ()

@end

@implementation AFNetworkingViewController {
    Api *api;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    api = [[Api alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textView.text = nil;
    
    [[api
     requestWithMethod:@"GET"
     path:@"https://graph.facebook.com/4"
     parameters:nil]
     subscribeNext:^(id x) {
         self.textView.text = x;
     }
     error:^(NSError *error) {
         WBErrorNoticeView *notice = [WBErrorNoticeView
                                      errorNoticeInView:self.view
                                      title:@"Network Error"
                                      message:@"Check your network connection."];
         notice.sticky = YES;
         [notice show];
     }
     completed:^{
         NSLog(@"completed");
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
