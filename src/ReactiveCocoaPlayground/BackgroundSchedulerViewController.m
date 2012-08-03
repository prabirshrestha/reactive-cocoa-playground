//
//  BackgroundSchedulerViewController.m
//  ReactiveCocoaPlayground
//
//  Created by Prabir Shrestha on 8/3/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "BackgroundSchedulerViewController.h"

@interface BackgroundSchedulerViewController ()

@end

@implementation BackgroundSchedulerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
