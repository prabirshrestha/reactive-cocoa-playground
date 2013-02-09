//
//  LocationManager.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 2/9/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) RACSubject *locationSubject;
@property (readwrite, nonatomic) int numberOfLocationSubscribers;

@end

@implementation LocationManager

+ (LocationManager*) sharedManager {
    static LocationManager *_locationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[LocationManager alloc] init];
    });
    
    return _locationManager;
}

- (id)init {
    self = [super init];
    if(!self) return nil;
    
    self.locationSubject = [RACReplaySubject subject];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    return self;
}

- (RACSignal *)currentLocationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @synchronized(self) {
            if(self.numberOfLocationSubscribers == 0) {
                [self.locationManager startUpdatingLocation];
            }
            ++self.numberOfLocationSubscribers;
            [self.locationSubject
             subscribeNext:^(id x) {
                 [subscriber sendNext:x];
             }
             error:^(NSError *error) {
                 [subscriber sendError:error];
             }
             completed:^{
                 [subscriber sendCompleted];
             }];
        }
        
        return [RACDisposable disposableWithBlock:^{
            @synchronized(self) {
                --self.numberOfLocationSubscribers;
                if(self.numberOfLocationSubscribers == 0) {
                    [self.locationManager stopUpdatingLocation];
                }
            }
        }];
    }];
}

- (void)updateLocation {
    [[[[self.currentLocationSignal
     takeUntil:[RACSignal interval:3]]
     takeLast:1]
     doNext:^(id x) {
         NSLog(@"location %@", x);
     }]
     subscribeCompleted:^{
         
     }];
}

# pragma mark - CLLocationManagerDelegate 

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationSubject sendNext:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationSubject sendError:error];
}

@end
