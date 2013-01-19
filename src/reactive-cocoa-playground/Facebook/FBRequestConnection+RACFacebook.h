//
//  FBRequestConnection+RACFacebook.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "Facebook.h"
#import "ReactiveCocoa.h"

@interface FBRequestConnection (RACFacebook)

+ (RACSignal*) rac_startWithGraphPath:(NSString*)graphPath
                           parameters:(NSDictionary*)parameters
                           HTTPMethod:(NSString*)HTTPMethod;

@end
