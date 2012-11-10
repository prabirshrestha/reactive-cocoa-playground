//
//  TwitterSearchTableViewCell.m
//  reactive-cocoa-playground
//
//  Created by Prabir Shrestha on 11/10/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "TwitterSearchTableViewCell.h"

@interface TwitterSearchTableViewCell()

@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation TwitterSearchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return nil;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
