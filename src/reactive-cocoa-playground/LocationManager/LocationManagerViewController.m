//
//  LocationManagerViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/11/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "LocationManagerViewController.h"
#import "LocationManager.h"
#import <ReactiveCocoa.h>

@interface LocationManagerViewController ()

@end

@implementation LocationManagerViewController {
    RACDisposable *currentLocationDisposable;
}

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
    
    currentLocationDisposable = [[[LocationManager sharedManager]
         currentLocationSignal]
         subscribeNext:^(id x) {
             NSLog(@"%@", x);
         }
         error:^(NSError *error) {
             NSLog(@"%@", error);
         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // make sure we stop updating by callig dispose
    [currentLocationDisposable dispose];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
