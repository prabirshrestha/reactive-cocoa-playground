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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setObservableWithReturn:nil];
    [self setObservableFromEmpty:nil];
    [super viewDidUnload];
}

# pragma mark - 

- (void) setupObservableWithReturn {
    [[self.observableWithReturn rac_subscribableForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         
         [[RACSubscribable return:[NSNumber numberWithInt:42]]
         subscribeNext:^(id x) {
             NSLog(@"%@", x);
         }];
         
     }];
}

- (void) setupObservableFromEmpty {
    [[self.observableFromEmpty rac_subscribableForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        
        [[RACSubscribable empty]
        subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }
        completed:^{
            NSLog(@"completed");
        }];
        
    }];
}

@end
