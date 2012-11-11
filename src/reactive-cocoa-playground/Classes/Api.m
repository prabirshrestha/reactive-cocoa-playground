//
//  Api.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/1/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "Api.h"
#import <ReactiveCocoa.h>
#import <AFNetworking.h>

@implementation Api {
    AFHTTPClient *client;
}

- (id)init {
    self = [super init];
    if(!self) return self;
    
    client = [[AFHTTPClient alloc] init];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (RACSubscribable *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    RACAsyncSubject* subject = [RACAsyncSubject subject];
    
    NSURLRequest *request = [client requestWithMethod:method path:path parameters:parameters];
    
    // note: add in app delegate [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    AFHTTPRequestOperation *operation =
        [client
         HTTPRequestOperationWithRequest:request
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
             [subject sendNext:operation.responseString];
             [subject sendCompleted];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
             [subject sendError:error];
         }];
    
    [operation start];
    
    return subject;
}

- (RACSubscribable *)requestJSONWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    RACAsyncSubject *subject = [RACAsyncSubject subject];
    
    [[self
     requestWithMethod:method
     path:path
     parameters:parameters]
     subscribeNext:^(NSString *JSONString) {
         NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
         
         NSError *error = nil;
         id JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
         if(error) {
             [subject sendError:error];
         } else {
             [subject sendNext:[RACTuple tupleWithObjects:JSON, data, nil]];
             [subject sendCompleted];
         }
     }
     error:^(NSError *error) {
         [subject sendError:error];
     }
     completed:^{
         // completed controlled by subscribeNext
//         [subject sendCompleted];
     }];
    
    return subject;
}

@end
