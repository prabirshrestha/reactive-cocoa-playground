//
//  TwitterInstantSearchModel.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterInstantSearchModel : NSObject

- (id)init;
- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *text;

@end
