//
//  TwitterInstantSearchModel.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 1/18/13.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "TwitterInstantSearchModel.h"

@interface TwitterInstantSearchModel()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TwitterInstantSearchModel

- (id)init {
    self = [super init];
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(!self) return nil;
    
    self.text = [self objectOrNilForKey:@"text" fromDictionary:dict];
    
    return self;
}

#pragma mark - Helper Method

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
