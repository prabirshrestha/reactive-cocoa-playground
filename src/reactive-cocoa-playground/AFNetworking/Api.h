//
//  Api.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/1/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface Api : NSObject

- (RACSignal*) requestWithMethod:(NSString*)method
                                  path:(NSString*)path
                            parameters:(NSDictionary*) parameters;

- (RACSignal*) requestJSONWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

@end
