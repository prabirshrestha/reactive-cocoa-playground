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
    
    RACSubscribable *keys =
    [[[self.searchTextField
     rac_subscribableForControlEvents:UIControlEventEditingChanged]
     throttle:0.5] // seconds
     select:^id(UITextField *x) {
         return x.text;
     }];
    
    [[keys
      deliverOn:[RACScheduler mainQueueScheduler]]
      subscribeNext:^(NSString *x) {
          self.searchingForLabel.text = [NSString stringWithFormat:@"Searching for ... %@", x];
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
    [super viewDidUnload];
}
@end
