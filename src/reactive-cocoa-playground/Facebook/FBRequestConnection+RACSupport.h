//
//  FBRequestConnection+RACSupport.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 3/26/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import <FacebookSDK/FBRequestConnection.h>

@class RACSignal;

@interface FBRequestConnection (RACSupport)

+ (RACSignal*) rac_startWithGraphPath:(NSString*)graphPath
                           parameters:(NSDictionary*)parameters
                           HTTPMethod:(NSString*)HTTPMethod;

@end
