//
//  TwitterSearchTableViewCell.h
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/10/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterSearchTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *tweet;

- (void)listenForChanges;

@end
