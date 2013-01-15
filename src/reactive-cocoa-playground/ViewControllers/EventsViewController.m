//
//  EventsViewController.m
//  ReactiveCocoaPlayground
//
//  Created by Prabir Shrestha on 8/3/12.
//  Copyright (c) 2012 Prabir Shrestha. All rights reserved.
//

#import "EventsViewController.h"
#include <ReactiveCocoa/ReactiveCocoa.h>
#include <ReactiveCocoa/RACEventTrampoline.h>
#include <ReactiveCocoa/RACDelegateProxy.h>

@interface EventsViewController ()

@end

@implementation EventsViewController

@synthesize pushMeButton1 = _pushMeButton1;
@synthesize pushMeButton2 = _pushMeButton2;
@synthesize outputLabel = _outputLabel;
@synthesize textField1 = _textField1;

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
    
    self.textField1.delegate = self;
    
    [[self.pushMeButton1
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         self.outputLabel.text = @"Push Me (1)";
         NSLog(@"%@", self.outputLabel.text);
     }];
    
//    [[[self.pushMeButton2
//     rac_signalForControlEvents:UIControlEventTouchUpInside]
//     select:^id(UIButton *x) {
//         return x.titleLabel.text;
//     }]
//     subscribeNext:^(NSString *x) {
//         self.outputLabel.text = x;
//         NSLog(@"%@", x);
//     }];
    
//    [[[[[[self.textField1
//     rac_signalForControlEvents:UIControlEventEditingChanged]
//     select:^id(UITextField *x) {
//         return x.text;
//     }]
//     where:^BOOL(NSString *x) {
//         return [x stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 2;
//     }]
//     distinctUntilChanged]
//     throttle:.5]
//     subscribeNext:^(NSString *x) {
//         self.outputLabel.text = x;
//         NSLog(@"%@", x);
//     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload
{
    [self setPushMeButton2:nil];
    [self setPushMeButton1:nil];
    [self setOutputLabel:nil];
    [self setTextField1:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
