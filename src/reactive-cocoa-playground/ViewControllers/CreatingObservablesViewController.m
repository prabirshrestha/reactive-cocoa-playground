//
//  CreatingObservablesViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/19/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "CreatingObservablesViewController.h"
#import <ReactiveCocoa.h>
@interface CreatingObservablesViewController ()

@end

@implementation CreatingObservablesViewController

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
    
    [self setupObservableWithReturn];
    [self setupObservableFromEmpty];
    [self setupObservableFromArray];
    [self setupObservableFromEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setObservableWithReturn:nil];
    [self setObservableFromEmpty:nil];
    [self setObservableFromArray:nil];
    [self setObservableFromEvent:nil];
    [super viewDidUnload];
}

# pragma mark - 

- (void) setupObservableWithReturn {
    [[self.observableWithReturn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         
        [[RACSignal return:[NSNumber numberWithInt:42]]
         subscribeNext:^(id x) {
             NSLog(@"%@", x);
         }
         completed:^{
             NSLog(@"completed");
         }];
         
     }];
}

- (void) setupObservableFromEmpty {
    [[self.observableFromEmpty rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        
        [[RACSignal empty]
        subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }
        completed:^{
            NSLog(@"completed");
        }];
        
    }];
}

- (void) setupObservableFromArray {
    [[self.observableFromArray
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         
         NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], nil];
         /*
         [[array
          rac_toSubscribable]
          subscribeNext:^(id x) {
              NSLog(@"%@", x);
          }
          completed:^{
              NSLog(@"completed");
          }];
         */
     }];
    
}

- (void) setupObservableFromEvent {
    
//    [[self.observableFromEvent
//      rac_subscribableForControlEvents:UIControlEventTouchUpInside]
//     subscribeNext:^(id x) {
//         NSLog(@"touch up inside");
//     }];
    
}

@end
