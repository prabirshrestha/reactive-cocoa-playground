//
//  EventsViewController.m
//  ReactiveCocoaPlayground
//
//  Created by Prabir Shrestha on 8/3/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "EventsViewController.h"
#include <ReactiveCocoa/ReactiveCocoa.h>

@interface EventsViewController ()

@end

@implementation EventsViewController

@synthesize pushMeButton1 = _pushMeButton1;
@synthesize outputLabel = _outputLabel;

@synthesize output = _output;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self == nil) return nil;
    
   
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[self.pushMeButton1
     rac_subscribableForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         self.outputLabel.text = @"Push me button 1";
         NSLog(@"%@", self.outputLabel.text);
     }];
    
     
}

- (void)viewDidUnload
{
    [self setOutputLabel:nil];
    [self setPushMeButton1:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
