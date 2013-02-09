//
//  LocationManager.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 2/9/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface LocationManager : NSObject

+(LocationManager*) sharedManager;

@property (strong, nonatomic) NSString *purpose;

@property (readonly, nonatomic) RACSignal *currentLocationSignal;

- (void) updateLocation;

@end
