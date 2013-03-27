//
//  ReachabilityViewController.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 3/27/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "ReachabilityViewController.h"
#import <Reachability.h>
#import <EXTScope.h>
#import <ReactiveCocoa.h>

@interface ReachabilityViewController()

@property (weak, nonatomic) IBOutlet UILabel *networkStatusLabel;
@property (strong, nonatomic) Reachability *reach;

@property (strong, nonatomic) RACSubject *reachSignal;

@end

@implementation ReachabilityViewController

- (void)viewDidLoad {
    @weakify(self);
    self.reachSignal = [RACReplaySubject subject];
    self.reach = [Reachability reachabilityForInternetConnection];
    
    [self.reach setUnreachableBlock:^(Reachability* reach) {
        @strongify(self);
        [self.reachSignal sendNext:reach];
    }];
    
    [self.reach setReachableBlock:^(Reachability *reach){
        @strongify(self);
        [self.reachSignal sendNext:reach];
    }];
    
    [self.reachSignal subscribeNext:^(Reachability *reach) {
        @strongify(self);
        self.networkStatusLabel.text = reach.isReachable ? @"Online" : @"Offline";
    }];
    
    [self.reachSignal sendNext:self.reach];    
    [self.reach startNotifier];
}


- (void)viewDidUnload {
    [self setNetworkStatusLabel:nil];
    [super viewDidUnload];
    self.reach = nil;
}
@end
