//
//  RxOperatorsViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/21/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "RxOperatorsViewController.h"
#import <ReactiveCocoa.h>

@interface RxOperatorsViewController ()

@end

@implementation RxOperatorsViewController

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
    
    [self setupTake];
    [self setupSkip];
    [self setupDistinct];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTakeButton:nil];
    [self setSkipButton:nil];
    [self setDistinctButton:nil];
    [super viewDidUnload];
}

- (void) setupTake {
    [[self.takeButton
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         RACSignal *input = [[@[ @1, @2, @3, @4, @5, @4, @3, @2, @1] rac_sequence] signal];
         
         RACSignal *output =
            [[input
             take:5]
             map:^id(id x) {
                 return [NSNumber numberWithInt:[x intValue] * 10];
             }];
         
         [output
          subscribeNext:^(id x) {
              NSLog(@"%@", x);
          }
          completed:^{
              NSLog(@"completed");
          }];
     }];
}

- (void) setupSkip {
    [[self.skipButton
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         RACSignal *input = [[@[ @1, @2, @3, @4, @5, @4, @3, @2, @1] rac_sequence] signal];
         
         RACSignal *output =
            [[input
             skip:6]
             map:^id(id x) {
                 return [NSNumber numberWithInt:[x intValue] * 10];
             }];
         
         [output
          subscribeNext:^(id x) {
              NSLog(@"%@", x);
          }];
     }];
}

- (void) setupDistinct {
    [[self.distinctButton
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         
         [[[UIAlertView
          alloc]
          initWithTitle:@"Not Available"
          message:@"ReactiveCocoa does not support distinct"
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil, nil]
          show];
         
     }];
}

@end
