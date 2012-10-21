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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTakeButton:nil];
    [super viewDidUnload];
}

- (void) setupTake {
    [[self.takeButton
     rac_subscribableForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
        
         NSArray *array = @[ @1, @2, @3, @4, @5, @4, @3, @2, @1];
         
         RACSubscribable *subscribable =
             [[[array
              rac_toSubscribable]
              take:5]
              select:^id(id x) {
                  NSNumber *result = [NSNumber numberWithInt:[x intValue] * 10];
                  NSLog(@"%@", result);
                  return result;
              }];
         
         [subscribable
          subscribeNext:^(id x) {
              NSLog(@"%@", x);
          }];
         
         [subscribable subscribeCompleted:^{
             NSLog(@"completed");
         }];
         
     }];
}

@end
