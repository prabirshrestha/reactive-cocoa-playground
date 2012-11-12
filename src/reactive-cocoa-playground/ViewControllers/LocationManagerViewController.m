//
//  LocationManagerViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/11/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "LocationManagerViewController.h"
#import "RCLocationManager.h"
#import <ReactiveCocoa.h>

@interface LocationManagerViewController ()

@property (strong, nonatomic) RACDisposable *cancelLocationUpdate;

@end

@implementation LocationManagerViewController

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
    
    self.cancelLocationUpdate =
        [[self setupLocationUpdateNotifications]
         subscribeNext:^(id x) {
             CLLocationManager *locationManager = x[0];
             CLLocation *newLocation = x[1];
             CLLocation *oldLocation = x[2];
             NSLog(@"%@, %@, %@", locationManager, newLocation, oldLocation);
         }
         error:^(NSError *error) {
             NSLog(@"%@", error);
         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cancelLocationUpdate dispose];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (RACSubscribable*) setupLocationUpdateNotifications
{
    return [RACSubscribable createSubscribable:^RACDisposable *(id<RACSubscriber> subscriber) {
        __block RCLocationManager *locationManager = [RCLocationManager sharedManager];
        [locationManager setPurpose:@"App requires location permission"];
        
        [locationManager
         startUpdatingLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
             [subscriber sendNext:[RACTuple tupleWithObjects:manager, newLocation, oldLocation, nil]];
         }
         errorBlock:^(CLLocationManager *manager, NSError *error) {
             [subscriber sendError:error];
         }];
        
        return [RACDisposable disposableWithBlock:^{
            [locationManager stopUpdatingLocation];
        }];
        
    }];
}

@end
