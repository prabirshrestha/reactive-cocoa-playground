//
//  Api.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 10/1/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSubscribable;

@interface Api : NSObject

- (RACSubscribable*) requestWithMethod:(NSString*)method
                                  path:(NSString*)path
                            parameters:(NSDictionary*) parameters;

- (RACSubscribable*) requestJSONWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

@end
