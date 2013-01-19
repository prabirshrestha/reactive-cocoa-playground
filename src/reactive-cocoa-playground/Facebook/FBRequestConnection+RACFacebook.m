//
//  FBRequestConnection+RACFacebook.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "FBRequestConnection+RACFacebook.h"

@implementation FBRequestConnection (RACFacebook)

+ (RACSignal *) rac_startWithGraphPath:(NSString *)graphPath
                           parameters:(NSDictionary *)parameters
                           HTTPMethod:(NSString *)HTTPMethod {
    
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    [FBRequestConnection
     startWithGraphPath:graphPath
     parameters:parameters
     HTTPMethod:HTTPMethod
     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if(error) {
             [subject sendError:error];
         } else {
             [subject sendNext:result];
             [subject sendCompleted];
         }
     }];
    
    return subject;
}

@end
