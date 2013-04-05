//
//  ScrollViewController.m
//  reactive-cocoa-playground
//
//  Created by Ash Furrow on 2013-04-05.
//  Copyright (c) 2013 Prabir Shrestha. All rights reserved.
//

#import "ScrollViewController.h"
#import <EXTScope.h>
#import <ReactiveCocoa.h>

@interface ScrollViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end

static const NSInteger kNumberOfPages = 3;

@implementation ScrollViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupScrollView];
    
    @weakify(self);
    // Create a signal for the next time the "Value Changed" control event is triggered.
    // Subscribe to it with a block.
    [[self.pageControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UIPageControl *pageControl) {
        @strongify(self);
        [self.scrollView scrollRectToVisible:CGRectMake(pageControl.currentPage * CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES];
    }];
    
    // Subscribe to the contentOffset property of our scroll view with a block
    [RACAble(self.scrollView.contentOffset) subscribeNext:^(NSNumber *contentOffset) {
        @strongify(self);
        
        NSInteger currentPage = [contentOffset CGPointValue].x / CGRectGetWidth(self.scrollView.frame);
        self.pageControl.currentPage = currentPage;
    }];
}

-(void)setupScrollView
{
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * kNumberOfPages, CGRectGetHeight(self.scrollView.bounds));
    
    for (NSInteger i = 0; i < kNumberOfPages; i++)
    {
        NSString *string = [NSString stringWithFormat:@"%d", i+1];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(self.scrollView.frame), 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
        label.text = string;
        label.font = [UIFont boldSystemFontOfSize:144];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:label];
    }
}


@end
