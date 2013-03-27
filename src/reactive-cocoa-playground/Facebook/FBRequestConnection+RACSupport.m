//
//  FBRequestConnection+RACSupport.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 3/26/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "FBRequestConnection+RACSupport.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation FBRequestConnection (RACSupport)

+ (RACSignal *)rac_startWithGraphPath:(NSString *)graphPath
                           parameters:(NSDictionary *)parameters
                           HTTPMethod:(NSString *)HTTPMethod {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [FBRequestConnection
         startWithGraphPath:graphPath
         parameters:parameters
         HTTPMethod:HTTPMethod
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if(error) {
                 NSMutableDictionary *userInfo = [error.userInfo mutableCopy] ?: [NSMutableDictionary dictionary];
                 [userInfo setObject:connection forKey:@"FBRequestConnection"];
                 [subscriber sendError:[NSError errorWithDomain:error.domain code:error.code userInfo:userInfo]];
             } else {
                 [subscriber sendNext:RACTuplePack((id)connection, result)];
                 [subscriber sendCompleted];
             }
         }];
        
        return [RACDisposable disposableWithBlock:nil];
    }];
}

@end
